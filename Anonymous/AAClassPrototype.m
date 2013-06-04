//
//  AAClassProtocol.m
//  Anonymous
//
//  Created by Adam Sharp on 4/06/13.
//  Copyright (c) 2013 Adam Sharp. All rights reserved.
//

#import "AAClassPrototype.h"
#import <objc/runtime.h>

#define AA_CLASS_NAME_FORMAT @"AA_CLASSES__%@_%d"

@interface AAClassPrototype ()

- (void)registerClassPair;
- (void)implementDealloc;
- (NSString *)nextClassName;

@property (nonatomic, unsafe_unretained) Protocol *protocol;
@property (nonatomic, unsafe_unretained) Class prototypeClass;

@property (nonatomic, retain) NSMutableDictionary *protocolSubclassCounts;

@end

@implementation AAClassPrototype

- (id)initWithProtocol:(Protocol *)protocol
{
    self = [super init];
    if (self) {
        _protocol = protocol;
        _protocolSubclassCounts = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)new
{
    // TODO: Fail if new is called twice
    [self registerClassPair];
    [self implementDealloc];
    return [self.prototypeClass new];
}

- (void)registerClassPair
{
    const char *className = [self nextClassName].UTF8String;
    self.prototypeClass = objc_allocateClassPair([NSObject class], className, 0);
    if (self.prototypeClass) {
        class_addProtocol(self.prototypeClass, self.protocol);
        objc_registerClassPair(self.prototypeClass);
    }
}

- (void)implementDealloc
{
    IMP dealloc_imp = imp_implementationWithBlock(^(id self){
        objc_disposeClassPair(_prototypeClass);
    });
    class_addMethod(self.prototypeClass, @selector(dealloc), dealloc_imp, "v@:");
}

- (NSString *)nextClassName
{
    NSString *protocolKey = NSStringFromProtocol(self.protocol);

    NSUInteger count;
    @synchronized (self) {
        count = [self.protocolSubclassCounts[protocolKey] integerValue];
        self.protocolSubclassCounts[protocolKey] = @(++count);
    }

    return [NSString stringWithFormat:AA_CLASS_NAME_FORMAT, protocolKey, count];
}

- (void)dealloc
{
    [_protocolSubclassCounts release];
    [super dealloc];
}

@end
