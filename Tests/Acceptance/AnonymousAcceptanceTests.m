#import <Kiwi.h>
#import "Anonymous.h"

@protocol Foo <NSObject>
@end

SPEC_BEGIN(AnonymousAcceptanceTests)

describe(@"instanceOf", ^{

    it(@"creates an anonymous subclass of a protocol and returns a new instance", ^{
        id fooInstance = instanceOf(@protocol(Foo), nil);

        [[fooInstance should] conformToProtocol:@protocol(Foo)];
        [[fooInstance should] beKindOfClass:[NSObject class]];
    });

});

SPEC_END
