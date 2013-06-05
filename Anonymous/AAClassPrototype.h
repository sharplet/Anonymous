//
//  AAClassProtocol.h
//  Anonymous
//
//  Created by Adam Sharp on 4/06/13.
//  Copyright (c) 2013 Adam Sharp. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Provides an object-oriented API to the Objective-C runtime for creating
 "anonymous" classes that implement an existing interface. The class
 can be used to instantiate a new object that conforms to a protocol.

 The classes that are generated are anonymous in that they are
 dynamically allocated and registered with the runtime, and their
 lifetime is restricted to the lifetime of the object instantiated from
 the prototype (that is, the class is disposed of from the runtime
 automatically when the instance is deallocated).
 */
@interface AAClassPrototype : NSObject

/**
 Create a class prototype based on the given protocol.

 @param protocol The protocol to base the class prototype on.
 @param definitionBlock A block that should implement methods on the
     prototype's class, using `define:withBlock:`.
 */
- (id)initWithProtocol:(Protocol *)protocol definition:(void (^)(void))definitionBlock;

/**
 Get an instance of the prototype. This should only be called once.
 Instantiating a second instance from a prototype is illegal and will
 raise an exception.

 @return An instance of a new anonymous NSObject subclass described by
     this prototype.
 */
- (id)new;

/**
 Get the class prototype for the currently executing definition block.
 If called outside the context of a definition block, returns nil.

 @return The class prototype for the currently executing definition
     block, or nil.
 */
+ (instancetype)current;

/**
 Add a method to the class. Type information for the IMP is looked up
 from the prototype's protocol.

 @param sel The selector to implement.
 @param imp A block implementing the selector. It's first parameter
     must be `self`, with the remaining parameters being those defined
     by the selector.
 */
- (void)define:(SEL)sel withBlock:(id)imp;

@property (nonatomic, readonly) Protocol *protocol;
@property (nonatomic, readonly) Class prototypeClass;
@property (nonatomic, readonly, copy) void (^definitionBlock)(void);

@end
