//
//  PhraseElements.h
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

/*
 这个文件中的方法几乎不需要手动调用
 正常的情况下你不需要使用任何其中的方法
 */

#import <Foundation/Foundation.h>

@interface ParseElements : NSObject

+(NSArray *) taskPageData:(NSString *)orignData;

+(NSString *) taskName:(NSString *)taskContent;
+(NSString *) taskSize:(NSString *)taskContent;
+(NSString *) taskLoadProcess:(NSString *)taskContent;
+(NSString *) taskRetainDays:(NSString *)taskContent;
+(NSString *) taskAddTime:(NSString *)taskContent;
+(NSString *) taskDownlaodNormalURL:(NSString *)taskContent;
+(NSString *) GDriveID:(NSString *) orignData;
+(NSString *) taskType:(NSString *)taskContent;
+(NSString *) DCID:(NSString *)taskContent;
+(NSString *) GCID:(NSString *)taskDownLoadURL;
+(NSMutableDictionary *)taskInfo:(NSString *)taskContent;
+(NSString*) nextPageSubURL:(NSString *) currentPageData;
@end
