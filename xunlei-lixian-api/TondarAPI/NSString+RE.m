//
//  NSString+RE.m
//  TondarAPI
//
//  Created by liuchao on 10/8/12.
//
//

#import "NSString+RE.h"

@implementation NSString (RE)

-(NSArray*) arrayOfCaptureComponentsMatchedByRegex:(NSString*) regex{
    NSMutableArray *result=[NSMutableArray arrayWithCapacity:0];
    //    NSString *htmlString = @"A long string containing Name:</td><td>A name here</td> amongst other things";
    NSRegularExpression *nameExpression = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionSearch error:nil];
    
    NSArray *matches = [nameExpression matchesInString:self
                                               options:0
                                                 range:NSMakeRange(0, [self length])];
    for (NSTextCheckingResult *match in matches) {
        NSMutableArray *subResult=[NSMutableArray arrayWithCapacity:0];
        for(int i=0;i<[match numberOfRanges];i++){
            NSRange matchRange = [match rangeAtIndex:i];
            NSString *matchString = [self substringWithRange:matchRange];
            [subResult addObject:matchString];
        }
//        NSLog(@"%@", subResult);
        [result addObject:subResult];
    }
    return result;
}
- (NSArray *) captureComponentsMatchedByRegex:(NSString *)regex{
    return [self captureComponentsMatchedByRegex:regex capture:0];
}
- (NSArray *) captureComponentsMatchedByRegex:(NSString *)regex capture:(NSInteger) capture{
    NSMutableArray *result=[NSMutableArray arrayWithCapacity:0];
    //    NSString *htmlString = @"A long string containing Name:</td><td>A name here</td> amongst other things";
    NSRegularExpression *nameExpression = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionSearch error:nil];
    
    NSArray *matches = [nameExpression matchesInString:self
                                               options:0
                                                 range:NSMakeRange(0, [self length])];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match rangeAtIndex:capture];
        NSString *matchString = [self substringWithRange:matchRange];
//        NSLog(@"%@", matchString);
        [result addObject:matchString];
    }
    return result;
    
}
- (NSString *) stringByMatching:(NSString *)regex capture:(NSInteger)capture{
    NSString *result=nil;
//    NSString *htmlString = @"A long string containing Name:</td><td>A name here</td> amongst other things";
    NSRegularExpression *nameExpression = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionSearch error:nil];
    
    NSArray *matches = [nameExpression matchesInString:self
                                               options:0
                                                 range:NSMakeRange(0, [self length])];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match rangeAtIndex:capture];
        NSString *matchString = @"";
        @try {
            matchString=[self substringWithRange:matchRange];
        }
        @catch (NSException *exception) {
//            NSLog(@"found exception!!");
            result=nil;
        }
        @finally {
        }
        //        NSLog(@"%@", matchString);
        result=matchString;
        break;
    }
    return result;
}
@end
