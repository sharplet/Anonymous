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

#define AA_CLASS_PROTOTYPE_EXCEPTION \
    @"AAClassPrototypeException"
#define AA_CLASS_PROTOTYPE_EXCEPTION_REASON_SECOND_INSTANCE \
    @"Instantiating more than one instance from a class prototype is forbidden."

@interface AAClassPrototype ()

- (void)registerClassPair;
- (void)implementDealloc;
- (NSString *)nextClassName;

@property (nonatomic, unsafe_unretained) Protocol *protocol;
@property (nonatomic, unsafe_unretained) Class prototypeClass;

@property (nonatomic, strong) NSMutableDictionary *protocolSubclassCounts;
@property (atomic, readonly) BOOL instanceCreated;

@end

@implementation AAClassPrototype

@synthesize instanceCreated = _instanceCreated;

- (id)initWithProtocol:(Protocol *)protocol
{
    self = [super init];
    if (self) {
        _protocol = protocol;
        _protocolSubclassCounts = [NSMutableDictionary new];
        _instanceCreated = NO;
    }
    return self;
}

- (id)new
{
    if (!self.instanceCreated) {
        [self registerClassPair];
        [self implementDealloc];
        return [self.prototypeClass new];
    }
    else {
        @throw [NSException exceptionWithName:AA_CLASS_PROTOTYPE_EXCEPTION
                                       reason:AA_CLASS_PROTOTYPE_EXCEPTION_REASON_SECOND_INSTANCE
                                     userInfo:nil];
    }
}
- (BOOL)instanceCreated
{
    @synchronized (self) {
        if (!_instanceCreated) {
            _instanceCreated = YES;
            return NO;
        }
        else {
            return YES;
        }
    }
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
    class_addMethod(self.prototypeClass, NSSelectorFromString(@"dealloc"), dealloc_imp, "v@:");
}

- (NSString *)nextClassName
{
    NSString *protocolKey = NSStringFromProtocol(self.protocol);

    NSUInteger count;
    count = [self.protocolSubclassCounts[protocolKey] integerValue];
    self.protocolSubclassCounts[protocolKey] = @(++count);

    return [NSString stringWithFormat:AA_CLASS_NAME_FORMAT, protocolKey, count];
}

@end
