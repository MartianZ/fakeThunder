//
//  NSString+RE.h
//  TondarAPI
//
//  Created by liuchao on 10/8/12.
//
//

#import <Foundation/Foundation.h>

@interface NSString (RE)
-(NSArray*) arrayOfCaptureComponentsMatchedByRegex:(NSString*) regex;
- (NSArray *) captureComponentsMatchedByRegex:(NSString *)regex capture:(NSInteger)capture;
- (NSArray *) captureComponentsMatchedByRegex:(NSString *)regex;
- (NSString *) stringByMatching:(NSString *)regex capture:(NSInteger)capture;

@end
