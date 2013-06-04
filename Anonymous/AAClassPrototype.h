//
//  AAClassProtocol.h
//  Anonymous
//
//  Created by Adam Sharp on 4/06/13.
//  Copyright (c) 2013 Adam Sharp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAClassPrototype : NSObject

- (id)initWithProtocol:(Protocol *)protocol;
- (id)new;

@property (nonatomic, readonly) Protocol *protocol;
@property (nonatomic, readonly) Class prototypeClass;

@end
