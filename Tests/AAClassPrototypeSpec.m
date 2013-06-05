#import <Kiwi.h>
#import <objc/runtime.h>
#import "AAClassPrototype.h"

@protocol AAClassPrototypeSpec <NSObject>
@end

SPEC_BEGIN(AAClassPrototypeSpec)

describe(@"AAClassPrototype", ^{

    describe(@"-initWithProtocol:", ^{

        __block AAClassPrototype *proto;
        void (^def)(void) = ^{};
        beforeEach(^{
            proto = [[AAClassPrototype alloc] initWithProtocol:@protocol(NSObject) definition:def];
        });

        specify(^{ [[(id)proto.protocol should] beIdenticalTo:@protocol(NSObject)]; });
        specify(^{ [proto.prototypeClass shouldBeNil]; });
        specify(^{ [[proto.definitionBlock should] equal:def]; });

        it(@"doesn't execute the definition block", ^{
            __block BOOL called = NO;
            proto = [[AAClassPrototype alloc] initWithProtocol:@protocol(NSObject) definition:^{
                called = YES;
            }];
            [[theValue(called) should] equal:theValue(NO)];
        });

    });

    describe(@"-new", ^{

        it(@"returns an instance of the class", ^{
            AAClassPrototype *proto = [[AAClassPrototype alloc] initWithProtocol:@protocol(AAClassPrototypeSpec) definition:nil];
            id instance = [proto new];
            [[NSStringFromClass([instance class]) should] matchPattern:@"AA_CLASSES__AAClassPrototypeSpec_\\d+"];
        });

        it(@"creates a new subclass of NSObject", ^{
            AAClassPrototype *proto = [[AAClassPrototype alloc] initWithProtocol:@protocol(AAClassPrototypeSpec) definition:nil];

            // need to retain the instance so the class pair is not
            // disposed of before the test completes
            id instance = [proto new];
            [[proto.prototypeClass should] beKindOfClass:[NSObject class]];

            // clean up
            instance = nil;
        });

        it(@"raises AAClassPrototypeException if a second instance is requested", ^{
            AAClassPrototype *proto = [[AAClassPrototype alloc] initWithProtocol:@protocol(AAClassPrototypeSpec) definition:nil];

            __block id instance1 = nil, instance2 = nil;
            [[theBlock(^{
                instance1 = [proto new];
                instance2 = [proto new];
            }) should] raiseWithName:@"AAClassPrototypeException"];
        });

        it(@"executes the definition block", ^{
            __block BOOL called = NO;
            AAClassPrototype *proto = [[AAClassPrototype alloc] initWithProtocol:@protocol(AAClassPrototypeSpec) definition:^{
                called = YES;
            }];

            [proto new];
            [[theValue(called) should] equal:theValue(YES)];
        });

    });

    describe(@"cleanup", ^{

        it(@"disposes of the class when the instance is freed", ^{
            AAClassPrototype *proto = [[AAClassPrototype alloc] initWithProtocol:@protocol(AAClassPrototypeSpec) definition:nil];
            id instance = [proto new];
            NSString *classString = NSStringFromClass([instance class]);

            instance = nil;
            [NSClassFromString(classString) shouldBeNil];
        });

    });

    describe(@"-current", ^{

        it(@"returns nil when called outside the context of a definition block", ^{
            [[AAClassPrototype current] shouldBeNil];
        });

        it(@"returns the correct class prototype when called from within a definition block", ^{
            __block AAClassPrototype *currentPrototype;
            AAClassPrototype *proto = [[AAClassPrototype alloc] initWithProtocol:@protocol(AAClassPrototypeSpec) definition:^{
                currentPrototype = [AAClassPrototype current];
            }];

            [proto new];
            [[currentPrototype should] equal:proto];
        });

    });

});

SPEC_END
