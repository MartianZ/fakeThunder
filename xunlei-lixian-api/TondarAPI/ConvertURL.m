//
//  ConvertURL.m
//  TondarAPI
//
//  Created by liuchao on 8/21/12.
//  Copyright (c) 2012 MartianZ. All rights reserved.
//

#import "ConvertURL.h"
#import "NSString+Base64.h"
#import "NSData+Base64.h"

@implementation ConvertURL

-(NSString*) thunderURLEncode:(NSString*) urlString{
    //set up data
    NSString *t=[NSString stringWithFormat:@"AA%@ZZ",urlString];
    NSData *inputData = [t dataUsingEncoding:NSUTF8StringEncoding];
    
    //encode
    NSString *encodedString = [inputData base64EncodedString];
    NSString *url=[NSString stringWithFormat:@"thunder://%@",encodedString];
    return url;
}
-(NSString*) thunderURLDecode:(NSString*) encodedString{
    NSString* returnString=nil;
    if ([encodedString hasPrefix:@"thunder://"]) {
        NSData *outputData = [NSData dataWithBase64EncodedString:[encodedString substringFromIndex:10]];
        NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        if([outputString hasPrefix:@"AA"]&&[outputString hasSuffix:@"ZZ"]){
            returnString=[outputString substringWithRange:NSMakeRange(2, outputString.length-4)];
        }
    }
    return returnString;
}

-(NSString*) qqURLEncode:(NSString*) urlString{
    //set up data;
    NSData *inputData = [urlString dataUsingEncoding:NSUTF8StringEncoding];
    
    //encode
    NSString *encodedString = [inputData base64EncodedString];
    NSString *url=[NSString stringWithFormat:@"qqdl://%@",encodedString];
    return url;
}
-(NSString*) qqURLDecode:(NSString*) encodedString{
    NSString* returnString=nil;
    if ([encodedString hasPrefix:@"qqdl://"]) {
        NSData *outputData = [NSData dataWithBase64EncodedString:[encodedString substringFromIndex:7]];
        NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        returnString=outputString;
    }
    return returnString;
}
-(NSString*) flashgetURLEncode:(NSString*) urlString{
    //set up data
    NSString *t=[NSString stringWithFormat:@"[FLASHGET]%@[FLASHGET]",urlString];
    NSData *inputData = [t dataUsingEncoding:NSUTF8StringEncoding];
    
    //encode
    NSString *encodedString = [inputData base64EncodedString];
    NSString *url=[NSString stringWithFormat:@"Flashget://%@",encodedString];
    return url;
}
-(NSString*) flashgetURLDecode:(NSString*) encodedString{
    NSString* returnString=nil;
    if ([encodedString hasPrefix:@"Flashget://"]) {
        NSData *outputData = [NSData dataWithBase64EncodedString:[encodedString substringFromIndex:11]];
        NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        if([outputString hasPrefix:@"[FLASHGET]"]&&[outputString hasSuffix:@"[FLASHGET]"]){
            returnString=[outputString substringWithRange:NSMakeRange(10, outputString.length-20)];
        }
    }
    return returnString;
}

-(NSString*) urlUnmask:(NSString*) urlString{
    NSString* returnString=nil;
    if([urlString hasPrefix:@"thunder://"]){
        returnString=[self thunderURLDecode:urlString];
    }else if ([urlString hasPrefix:@"qqdl://"]){
        returnString=[self qqURLDecode:urlString];
    }else if ([urlString hasPrefix:@"Flashget://"]){
        returnString=[self flashgetURLDecode:urlString];
    }else{
        returnString=urlString;
    }
    return returnString;
}

@end
