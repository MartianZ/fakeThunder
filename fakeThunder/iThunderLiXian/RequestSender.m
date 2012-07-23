//
//  RequestSender.m
//  MusicSeeker
//
//  Created by Martian on 11-6-3.
//  Copyright 2011 Martian. All rights reserved.
//

#import "RequestSender.h"


@implementation RequestSender

+ (NSString*)sendRequest:(NSString*)url
{
	NSString *urlString = url;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"GET"];
    NSString *contentType = [NSString stringWithFormat:@"text/xml"];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request addValue:@"MACOSX" forHTTPHeaderField:@"User-agent"];
	NSHTTPURLResponse* urlResponse = nil;  
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:NULL];  
	NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    //0x80000632 gb2312

    if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300) 
		return result;
    
	return @"NULL";
}

+ (NSString*)postRequest:(NSString*)url withBody:(NSString *)data
{
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
    [request addValue:@"MACOSX" forHTTPHeaderField:@"User-agent"];
    NSData *requestData = [NSData dataWithBytes: [data UTF8String] length: [data length]];
    [request setHTTPBody:requestData];
    
	NSHTTPURLResponse* urlResponse = nil;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:NULL];
	NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    //0x80000632 gb2312
    
    if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300)
		return result;
    
	return @"NULL";
}

@end

