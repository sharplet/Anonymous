#import <Kiwi.h>
#import "Anonymous.h"

@protocol Foo <NSObject>
@end

@protocol FooBar <NSObject>
- (void)doFooBar;
@end

@protocol ComplexFooBar <NSObject>
- (int)doNumericFooBarWithArgument:(int)arg;
@end

@protocol StatefulFooBar <NSObject>
@property (nonatomic, strong) NSString *nickname;
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

    it(@"allows an instance method with arguments and return value to be defined", ^{
        id<ComplexFooBar> fooBar = instanceOf(@protocol(ComplexFooBar), ^{
            implement(@selector(doNumericFooBarWithArgument:), ^(id self, int arg){
                return arg * arg;
            });
        });

        [[theValue([fooBar doNumericFooBarWithArgument:5]) should] equal:theValue(25)];
    });

    it(@"allows you to build anonymous classes with state", ^{
        id<StatefulFooBar> fooBar = instanceOf(@protocol(StatefulFooBar), ^{

            // @property nickname
            __block NSString *_nickname;
            implement(@selector(nickname), ^(id self){
                return _nickname;
            });
            implement(@selector(setNickname:), ^(id self, NSString *nickname){
                _nickname = nickname;
            });

            // -description
            implement(@selector(description), ^(id<StatefulFooBar> self){
                return [NSString stringWithFormat:@"They call me '%@'", self.nickname];
            });

        });

        fooBar.nickname = @"Hello, world!";
        [[fooBar.description should] equal:@"They call me 'Hello, world!'"];
    });

});

SPEC_END
