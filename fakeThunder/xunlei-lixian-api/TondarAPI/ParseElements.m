//
//  PhraseElements.m
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


#import "ParseElements.h"
#import "NSString+RE.h"

@implementation ParseElements

+(NSArray *) taskPageData:(NSString *)orignData{
    //获得已经完成和已经过期Task列表汇总信息
    NSString *listBoxRex=@"<div\\sclass=\"rw_list\"\\sid=\"\\w+\"\\staskid=\"(\\d+)\"[^>]*>([\\s\\S]+?<input\\s+id=\"openformat\\d+\"[^>]+?>)";
    NSString *outofDateListBoxRex=@"<div\\sclass=\"rw_list\"\\staskid=[\"']?(\\d+)[\"']?\\sid=[\"']?\\w+[\"']?[^>]*>([\\s\\S]+?)<input\\s+id=[\"']?d_tasktype\\d+[\"']?[^>]+?>";
    
    NSArray *completeTaskArray=[orignData arrayOfCaptureComponentsMatchedByRegex:listBoxRex];
    NSArray *outOfDateTaskArray=[orignData arrayOfCaptureComponentsMatchedByRegex:outofDateListBoxRex];
    NSMutableArray *allTaskArray=[NSMutableArray arrayWithArray:completeTaskArray];
    [allTaskArray addObjectsFromArray:outOfDateTaskArray];
    
    return allTaskArray;
}

+(NSString *) taskName:(NSString *)taskContent{
    NSString *re=@"<span\\s+[^>]*taskid=[\"']?\\d+[\"']?[^>]*title=[\"']?([^\"]*)[\"']?.*?</span>";
    NSString *result=[taskContent stringByMatching:re capture:1];
    if(result){
        return result;
    }else {
        return @"未知信息";
    }
}
+(NSString *) taskSize:(NSString *)taskContent{
    NSString *re=@"<span\\s+class=\"rw_gray\"[^>]*?>([^<]+)</span>";
    NSString *result=[taskContent stringByMatching:re capture:1];
    if(result){
        return result;
    }else {
        return @"未知信息";
    }
}
//读取下载进度
+(NSString *) taskLoadProcess:(NSString *)taskContent{
    NSString *re=@"<em\\s+class=\"loadnum\">([^<]+)</em>";
    NSString *result=[taskContent stringByMatching:re capture:1];
    if(result.length>1){
        return (result);
    }else {
        return (@"已经过期或已经删除");
    }
}
//提取保留时间
+(NSString *) taskRetainDays:(NSString *)taskContent{
    NSString *re=@"<div\\s*class=\"sub_barinfo\">\\s*<em[^>]*>([^<]+)</em>";
    NSString *result=[taskContent stringByMatching:re capture:1];
    if(result){
        return result;
    }else {
        return @"未知信息";
    }
}
//任务添加时间
+(NSString *) taskAddTime:(NSString *)taskContent{
    NSString *re=@"<span\\s+class=\"c_addtime\">([^<]+)</span>";
    NSString *result=[taskContent stringByMatching:re capture:1];
    if(result){
        return result;
    }else {
        return @"未知信息";
    }}
//链接地址
+(NSString *) taskDownlaodNormalURL:(NSString *)taskContent{
    //NSString *re=@"<input\\s+id=\"dl_url\\d+\"\\s+type=\"\\w+\"\\s+value=[\"']?([^\"'>]+)[\"']?>";
    NSString *re=@"<input\\s+id=\"dl_url\\d*\"\\s+type=\"hidden\"\\s+value=\"([^>]*)\"";
    NSString *result=[taskContent stringByMatching:re capture:1];
    if(result){
        return result;
    }else {
        return @"未知信息";
    }
}

//获取GdriveID
+(NSString *) GDriveID:(NSString *) taskHTMLOrignData{
    NSString *gdriveidRex=@"id=\"cok\"\\svalue=\"([^\"]+)\"";
    NSString *gdriveID=[taskHTMLOrignData stringByMatching:gdriveidRex capture:1];
    NSLog(@"GDRIVEID:%@",gdriveID);
    return gdriveID;
}

//获取DCID（也是BT HASHID） 
+(NSString *) DCID:(NSString *)taskContent{
    NSString *re=@"<input\\s+id=\"dcid\\d+\".*?value=\"([^\"]*)\"\\s+/>";
    NSString *result=[taskContent stringByMatching:re capture:1];
    if(result){
        return result;
    }else {
        return @"未知信息";
    }
}


//文件类型（BT/MOVIE/PDF/...)
+(NSString *) taskType:(NSString *)taskContent{
    NSString *re=@"<input\\s+id=['\"]?openformat\\d+['\"]?.*?value=['\"]?([^'\"]+)?['\"]?\\s*/>";
    NSString *result=[taskContent stringByMatching:re capture:1];
    if(result){
        //如果result结果是other就代表bt文件
        return result;
    }else {
        return @"未知类型";
    }
}

+(NSMutableDictionary *)taskInfo:(NSString *)taskContent{
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithCapacity:0];
    NSString *re0=@"<input\\s+id=['\"]?([^0-9]+)(\\d+)['\"]?.*?value=?['\"]?([^\">]*)['\"]?";
    NSArray *data=[taskContent arrayOfCaptureComponentsMatchedByRegex:re0];
    NSArray *data1=[data objectAtIndex:0];
    [dic setObject:[data1 objectAtIndex:2] forKey:@"id"];
    for(NSArray *d in data){
        NSString *tmp;
        if(![d objectAtIndex:3]){
            tmp=@"";
        }else {
            tmp=[d objectAtIndex:3];
        }
        [dic setObject:tmp forKey:[d objectAtIndex:1]];
    }
    return dic;
}

//取得GCID
+(NSString *) GCID:(NSString *)taskDownLoadURL{
    NSString *rex=@"&g=([^&]*)&";
    NSString *r=[taskDownLoadURL stringByMatching:rex capture:1];
    return r;
}

//获得下一页部分URL
/*
 href="/user_task?userid=642109&st=4&p=2&stype=0"
 */
+(NSString*) nextPageSubURL:(NSString *) currentPageData{
    NSString *rex=@"<li\\s*class=\"next\"><a\\s*href=\"([^\"]+)\">[^<>]*</a></li>";
    NSString *r=[currentPageData stringByMatching:rex capture:1];
    return r;
}
@end
