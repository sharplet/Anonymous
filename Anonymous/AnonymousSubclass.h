//
//  Anonymous.h
//  Anonymous
//
//  Created by Adam Sharp on 4/06/13.
//  Copyright (c) 2013 Adam Sharp. All rights reserved.
//

#import <Foundation/Foundation.h>

id aa_instanceOf(Protocol *p, void (^def)(void));

void aa_implement(SEL sel, id imp_block);
