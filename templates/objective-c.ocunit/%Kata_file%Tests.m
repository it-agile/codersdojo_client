// Adapt the code to your code kata %kata_file%.

#import <Cocoa/Cocoa.h>
#import <SenTestingKit/SenTestingKit.h>

@interface %Kata_file% : NSObject {
}
-(NSString*) %kata_file%;	
@end

@implementation %Kata_file%
-(NSString*) %kata_file% {
	return @"fixme";
}
@end


@interface %Kata_file%Tests : SenTestCase {
}
@end

@implementation %Kata_file%Tests

-(void) test%Kata_file% {
	%Kata_file% *%kata_file% = [[%Kata_file% alloc] init];
	STAssertEqualObjects(@"foo", [%kata_file% %kata_file%], nil);
	[%kata_file% release];
}

@end
