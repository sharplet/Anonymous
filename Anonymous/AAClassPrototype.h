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
 the prototype.
 */
@interface AAClassPrototype : NSObject

/**
 Create a class prototype based on the given protocol.

 @param protocol The protocol to base the class prototype on.
 */
- (id)initWithProtocol:(Protocol *)protocol;

/**
 Get an instance of the prototype. This should only be called once.
 Instantiating a second instance from a prototype is illegal and will
 raise an exception.

 @return An instance of a new anonymous NSObject subclass described by
     this prototype.
 */
- (id)new;

@property (nonatomic, readonly) Protocol *protocol;
@property (nonatomic, readonly) Class prototypeClass;

@end
