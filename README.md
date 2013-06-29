# Anonymous — Anonymous inner classes in Objective-C

While reading [Growing Object-Oriented Software Guided by Tests][goos],
I was inspired by the authors' use of Java [anonymous inner classes][java]
to try and achieve the same thing using the Objective-C runtime. This
is the result.

 [goos]: http://www.growing-object-oriented-software.com/
 [java]: http://docs.oracle.com/javase/tutorial/java/javaOO/anonymousclasses.html

To illustrate, here's a couple of Kiwi test cases:

    @protocol FooBar <NSObject>
    - (void)doFooBar;
    @end

    it(@"allows an instance method with no arguments and no return value to be defined", ^{
        __block BOOL called = NO;

        id<FooBar> fooBar = aa_instanceOf(@protocol(FooBar), ^{
            aa_implement(@selector(doFooBar), ^(id self){
                called = YES;
            });
        });
        [fooBar doFooBar];

        [[theValue(called) should] equal:theValue(YES)];
    });

    @protocol StatefulFooBar <NSObject>
    @property (nonatomic, strong) NSString *nickname;
    @end

    it(@"allows you to build anonymous classes with state", ^{
        id<StatefulFooBar> fooBar = aa_instanceOf(@protocol(StatefulFooBar), ^{

            // @property nickname
            __block NSString *_nickname;
            aa_implement(@selector(nickname), ^(id self){
                return _nickname;
            });
            aa_implement(@selector(setNickname:), ^(id self, NSString *nickname){
                _nickname = nickname;
            });

            // -description
            aa_implement(@selector(description), ^(id<StatefulFooBar> self){
                return [NSString stringWithFormat:@"They call me '%@'", self.nickname];
            });

        });

        fooBar.nickname = @"Hello, world!";
        [[fooBar.description should] equal:@"They call me 'Hello, world!'"];
    });
