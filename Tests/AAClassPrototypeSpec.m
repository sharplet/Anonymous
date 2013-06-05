#import <Kiwi.h>
#import <objc/runtime.h>
#import "AAClassPrototype.h"

@protocol AAClassPrototypeSpec <NSObject>
@end

SPEC_BEGIN(AAClassPrototypeSpec)

describe(@"AAClassPrototype", ^{

    describe(@"-initWithProtocol:", ^{

        __block AAClassPrototype *proto;
        beforeEach(^{
            proto = [[AAClassPrototype alloc] initWithProtocol:@protocol(NSObject)];
        });

        specify(^{ [[(id)proto.protocol should] beIdenticalTo:@protocol(NSObject)]; });
        specify(^{ [proto.prototypeClass shouldBeNil]; });

    });

    describe(@"-new", ^{

        it(@"returns an instance of the class", ^{
            AAClassPrototype *proto = [[AAClassPrototype alloc] initWithProtocol:@protocol(AAClassPrototypeSpec)];
            id instance = [proto new];
            [[NSStringFromClass([instance class]) should] matchPattern:@"AA_CLASSES__AAClassPrototypeSpec_\\d+"];
        });

        it(@"creates a new subclass of NSObject", ^{
            AAClassPrototype *proto = [[AAClassPrototype alloc] initWithProtocol:@protocol(AAClassPrototypeSpec)];

            // need to retain the instance so the class pair is not
            // disposed of before the test completes
            id instance = [proto new];
            [[proto.prototypeClass should] beKindOfClass:[NSObject class]];

            // clean up
            instance = nil;
        });

        it(@"raises AAClassPrototypeException if a second instance is requested", ^{
            AAClassPrototype *proto = [[AAClassPrototype alloc] initWithProtocol:@protocol(AAClassPrototypeSpec)];

            __block id instance1 = nil, instance2 = nil;
            [[theBlock(^{
                instance1 = [proto new];
                instance2 = [proto new];
            }) should] raiseWithName:@"AAClassPrototypeException"];
        });

    });

    describe(@"cleanup", ^{

        it(@"disposes of the class when the instance is freed", ^{
            AAClassPrototype *proto = [[AAClassPrototype alloc] initWithProtocol:@protocol(AAClassPrototypeSpec)];
            id instance = [proto new];
            NSString *classString = NSStringFromClass([instance class]);

            instance = nil;
            [NSClassFromString(classString) shouldBeNil];
        });

    });

});

SPEC_END
