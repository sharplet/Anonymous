//
//  AAClassProtocol.m
//  Anonymous
//
//  Created by Adam Sharp on 4/06/13.
//  Copyright (c) 2013 Adam Sharp. All rights reserved.
//

#import "AAClassPrototype.h"
#import <objc/runtime.h>


#define AA_CLASS_PROTOTYPE_CLASS_NAME_FORMAT @"AA_CLASSES__%@_%d"

#define AA_CLASS_PROTOTYPE_EXCEPTION \
    @"AAClassPrototypeException"
#define AA_CLASS_PROTOTYPE_EXCEPTION_REASON_SECOND_INSTANCE \
    @"Instantiating more than one instance from a class prototype is forbidden."


#pragma mark -


@interface AAClassPrototype ()

// redeclare these properties as read/write
@property (nonatomic, unsafe_unretained) Protocol *protocol;
@property (nonatomic, unsafe_unretained) Class prototypeClass;

// used by -nextClassName to generate unique class names
+ (NSMutableDictionary *)protocolSubclassCounts;

// instance creation
@property (nonatomic) BOOL instanceCreated;

- (void)registerClassPair;
- (void)implementDealloc;
- (NSString *)nextClassName;

@end


@implementation AAClassPrototype

+ (NSMutableDictionary *)protocolSubclassCounts
{
    static NSMutableDictionary *protocolSubclassCounts;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        protocolSubclassCounts = [NSMutableDictionary new];
    });
    return protocolSubclassCounts;
}

#pragma mark Initialisation

- (id)initWithProtocol:(Protocol *)protocol
{
    self = [super init];
    if (self) {
        _protocol = protocol;
        _instanceCreated = NO;
    }
    return self;
}

#pragma mark Instantiating the prototype

- (id)new
{
    @synchronized (self) {
        if (!self.instanceCreated) {
            self.instanceCreated = YES;
        }
        else {
            @throw [NSException exceptionWithName:AA_CLASS_PROTOTYPE_EXCEPTION
                                           reason:AA_CLASS_PROTOTYPE_EXCEPTION_REASON_SECOND_INSTANCE
                                         userInfo:nil];
        }
    }

    // this will be executed only once
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
    class_addMethod(self.prototypeClass, NSSelectorFromString(@"dealloc"), dealloc_imp, "v@:");
}

- (NSString *)nextClassName
{
    NSUInteger count;
    NSString *protocolKey = NSStringFromProtocol(self.protocol);

    @synchronized (self.protocol) {
        count = [AAClassPrototype.protocolSubclassCounts[protocolKey] integerValue];
        AAClassPrototype.protocolSubclassCounts[protocolKey] = @(++count);
    }

    return [NSString stringWithFormat:AA_CLASS_PROTOTYPE_CLASS_NAME_FORMAT, protocolKey, count];
}

@end
