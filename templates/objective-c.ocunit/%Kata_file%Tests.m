// Adapt the code to your code kata %kata_file%.
// Important: Test and production code has to be
//            completely in this file.

#import <SenTestingKit/SenTestingKit.h>

@interface %Kata_file%Tests : SenTestCase {
}
@end

@implementation %Kata_file%Tests

-(void) test%Kata_file% {
	%Kata_file% *%kata_file% = [[%Kata_file% alloc] init];
	STAssertEqualObjects(@"foo", [%kata_file% %kata_file%], nil);
	[%kata_file% release]
}

@end

@interface %Kata_file% {
}
-(NSString*) %kata_file%;	
@end

@implementation %Kata_file%
-(NSString*) %kata_file% {
  return "fixme"
}
@end
