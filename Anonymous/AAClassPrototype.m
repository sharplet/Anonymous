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
@property (nonatomic, copy) void (^definitionBlock)(void);

// used by -nextClassName to generate unique class names
+ (NSMutableDictionary *)protocolSubclassCounts;

// executing class definition blocks
@property (nonatomic, strong) NSOperationQueue *queue;

+ (NSMutableDictionary *)prototypes;
- (struct objc_method_description)methodDescriptionForSelector:(SEL)sel;

// instance creation
@property (nonatomic, weak) id instance;

- (void)registerClassPair;
- (void)implementDealloc;
- (void)executeDefinition;
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

+ (NSMutableDictionary *)prototypes
{
    static NSMutableDictionary *prototypeQueues;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        prototypeQueues = [NSMutableDictionary new];
    });
    return prototypeQueues;
}

#pragma mark Initialisation

- (id)initWithProtocol:(Protocol *)protocol definition:(void (^)(void))definitionBlock
{
    self = [super init];
    if (self) {
        self.protocol = protocol;
        self.definitionBlock = definitionBlock;

        self.queue = [NSOperationQueue new];
        self.queue.name = self.description;
        AAClassPrototype.prototypes[self.description] = self;
    }
    return self;
}

#pragma mark Defining methods

+ (instancetype)current
{
    NSString *current = [NSOperationQueue.currentQueue name];
    return AAClassPrototype.prototypes[current];
}

- (void)executeDefinition
{
    if (self.definitionBlock) {
        NSOperation *definitionOperation = [NSBlockOperation blockOperationWithBlock:self.definitionBlock];
        [self.queue addOperations:@[definitionOperation] waitUntilFinished:YES];
    }
}

- (void)define:(SEL)sel withBlock:(id)imp
{
    struct objc_method_description desc = [self methodDescriptionForSelector:sel];
    if (desc.name != NULL && desc.types != NULL) {
        class_addMethod(self.prototypeClass, sel, imp_implementationWithBlock(imp), desc.types);
    }
}

/**
 Get the method description from the protocol so we have access to
 the type encoding. First, look for a required method for the
 selector, and if one doesn't exist, look for an optional method.

 Currently, we only look for instance methods. This may not change.
 */
- (struct objc_method_description)methodDescriptionForSelector:(SEL)sel
{
    struct objc_method_description desc = protocol_getMethodDescription(self.protocol, sel, YES, YES);
    if (desc.name == NULL && desc.types == NULL) {
        desc = protocol_getMethodDescription(self.protocol, sel, NO, YES);
    }
    return desc;
}

#pragma mark Instantiating the prototype

- (id)new
{
    id instance;

    @synchronized (self) {
        if (self.instance) {
            @throw [NSException exceptionWithName:AA_CLASS_PROTOTYPE_EXCEPTION
                                           reason:AA_CLASS_PROTOTYPE_EXCEPTION_REASON_SECOND_INSTANCE
                                         userInfo:nil];
        }
        else {
            [self registerClassPair];
            [self implementDealloc];
            [self executeDefinition];

            instance = [self.prototypeClass new];
            self.instance = instance;
        }
    }

    return instance;
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

#pragma mark Dealloc

- (void)dealloc
{
    [AAClassPrototype.prototypes removeObjectForKey:_queue.name];
}

@end
