//
//  URlEncode.m
//  XunleiLixian-API
//
//  Created by Liu Chao on 6/10/12.
//  Copyright (c) 2012 HwaYing. All rights reserved.
//
/*This file is part of XunleiLixian-API.
 
 XunleiLixian-API is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Foobar is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */


#import "URlEncode.h"

@implementation URlEncode

+ (NSString *)encodeToPercentEscapeString: (NSString *) input  
{  
    // Encode all the reserved characters, per RFC 3986  
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    NSString *outputStr =
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,  
                                            (__bridge CFStringRef)input,  
                                            NULL,  
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",  
                                            kCFStringEncodingUTF8));
    return outputStr;  
}  

+ (NSString *)decodeFromPercentEscapeString: (NSString *) input  
{  
    NSMutableString *outputStr = [NSMutableString stringWithString:input];  
    [outputStr replaceOccurrencesOfString:@"+"  
                               withString:@" "  
                                  options:NSLiteralSearch  
                                    range:NSMakeRange(0, [outputStr length])];  
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  
}  

@end
