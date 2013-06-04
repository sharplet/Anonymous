//
//  Anonymous.m
//  Anonymous
//
//  Created by Adam Sharp on 4/06/13.
//  Copyright (c) 2013 Adam Sharp. All rights reserved.
//

#import "Anonymous.h"
#import "AAClassPrototype.h"


id instanceOf(Protocol *p, void (^def)(void))
{
    AAClassPrototype *proto = [[AAClassPrototype alloc] initWithProtocol:p];
    return [proto new];
}

void implement(SEL sel, id imp_block)
{
}
