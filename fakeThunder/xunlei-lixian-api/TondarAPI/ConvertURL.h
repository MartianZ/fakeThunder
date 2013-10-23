//
//  ConvertURL.h
//  TondarAPI
//
//  Created by liuchao on 8/21/12.
//  Copyright (c) 2012 MartianZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConvertURL : NSObject
-(NSString*) thunderURLEncode:(NSString*) urlString;
-(NSString*) thunderURLDecode:(NSString*) urlString;
-(NSString*) qqURLEncode:(NSString*) urlString;
-(NSString*) qqURLDecode:(NSString*) encodedString;
-(NSString*) flashgetURLEncode:(NSString*) urlString;
-(NSString*) flashgetURLDecode:(NSString*) encodedString;
//一个通用方法，可以转换thunder,qq,flashget几种
-(NSString*) urlUnmask:(NSString*) urlString;
@end
