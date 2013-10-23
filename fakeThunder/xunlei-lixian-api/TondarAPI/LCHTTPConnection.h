//
//  LCHTTPConnection.h
//  TondarAPI
//
//  Created by Martian on 12-9-29.
//  Copyright (c) 2012年 LiuChao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCHTTPConnection : NSObject <NSURLConnectionDelegate>

@property NSMutableArray* responseCookies;
+ (LCHTTPConnection *)sharedZZHTTPConnection;
- (NSString *)get:(NSString *)urlString;
- (NSString*)post:(NSString*)urlString withBody:(NSString *)bodyData;
-(NSString*) post:(NSString*) urlString;
-(void) setPostValue:(NSString*) key forKey:(NSString*) value;
- (NSString*)postBTFile:(NSString*)filePath;
@end
