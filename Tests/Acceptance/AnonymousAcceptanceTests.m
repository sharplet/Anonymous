#import <Kiwi.h>
#import "Anonymous.h"

@protocol Foo <NSObject>
@end

@protocol FooBar <NSObject>
- (void)doFooBar;
@end

SPEC_BEGIN(AnonymousAcceptanceTests)

describe(@"instanceOf", ^{

    it(@"creates an anonymous subclass of a protocol and returns a new instance", ^{
        id fooInstance = instanceOf(@protocol(Foo), nil);

        [[fooInstance should] conformToProtocol:@protocol(Foo)];
        [[fooInstance should] beKindOfClass:[NSObject class]];
    });

    it(@"allows an instance method with no arguments and no return value to be defined", ^{
        __block BOOL called = NO;

        id<FooBar> fooBar = instanceOf(@protocol(FooBar), ^{
            implement(@selector(doFooBar), ^(id self){
                called = YES;
            });
        });
        [fooBar doFooBar];

        [[theValue(called) should] equal:theValue(YES)];
    });

});

SPEC_END
