//
//  HWXunleiLixianAPI.m
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
 
 XunleiLixian-API is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */


#import "HYXunleiLixianAPI.h"
#import "md5.h"
#import "ParseElements.h"
#import "JSONKit.h"
#import "NSString+RE.h"
#import "URlEncode.h"
#import "XunleiItemInfo.h"
#import "Kuai.h"
#import "ConvertURL.h"
#import "LCHTTPConnection.h"

typedef enum {
    TLTAll,
    TLTDownloadding,
    TLTComplete,
    TLTOutofDate,
    TLTDeleted
} TaskListType;

@implementation HYXunleiLixianAPI

#define LoginURL @"http://login.xunlei.com/sec2login/"
#define DEFAULT_USER_AGENT  @"User-Agent:Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.106 Safari/535.2"
#define DEFAULT_REFERER @"http://lixian.vip.xunlei.com/"

#pragma mark - Login/LogOut Methods
/**
 *  登陆方法
 */
-(BOOL) loginWithUsername:(NSString *) aName Password:(NSString *) aPassword isPasswordEncode:(BOOL)passwordEncode{
    NSString *vCode=[self _verifyCode:aName];
    if ([vCode compare:@"0"]==NSOrderedSame) {
        return NO;
    }
    
    NSString *enPassword=passwordEncode ? [md5 md5HexDigestwithString:[NSString stringWithFormat:@"%@%@",aPassword,[vCode uppercaseString]]] : [self _encodePassword:aPassword withVerifyCode:vCode];
    
    //第一步登陆，验证用户名密码
    NSURL *url = [NSURL URLWithString:LoginURL];
    LCHTTPConnection *request=[LCHTTPConnection new];
    [request setPostValue:aName forKey:@"u"];
    [request setPostValue:enPassword forKey:@"p"];
    [request setPostValue:vCode forKey:@"verifycode"];
    [request setPostValue:@"0" forKey:@"login_enable"];
    [request setPostValue:@"720" forKey:@"login_hour"];
    [request post:[url absoluteString]];
    //把response中的Cookie添加到CookieStorage
    NSLog(@"%@", [request responseCookies]);

    [self _addResponseCookietoCookieStorage:[request responseCookies]];
    
    //完善所需要的cookies，并收到302响应跳转
    NSString *timeStamp=[self _currentTimeString];
    NSURL *redirectUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://dynamic.lixian.vip.xunlei.com/login?cachetime=%@&cachetime=%@&from=0",timeStamp,timeStamp]];
    LCHTTPConnection* redirectURLrequest = [LCHTTPConnection new];
    NSString *temp = [redirectURLrequest get:[redirectUrl absoluteString]];
    
    NSString *re=@"id=\"cok\" value=\"([^\"]+)\"";
    NSString *s=[temp stringByMatching:re capture:1];

    [self setGdriveID:s];

    //把response中的Cookie添加到CookieStorage

    
    [self _addResponseCookietoCookieStorage:[redirectURLrequest responseCookies]];
    //验证是否登陆成功
    NSString *userid=[self userID];
    if(userid.length>1){
        return YES;
    }else {
        return NO;
    }
}

-(NSString *)encodePasswordTwiceMD5:(NSString *)aPassword {
    return [md5 md5HexDigestwithString:([md5 md5HexDigestwithString:aPassword])];
}

//加密密码
-(NSString *) _encodePassword:(NSString *) aPassword withVerifyCode:(NSString *) aVerifyCode{
    NSString *enPwd_tmp=[md5 md5HexDigestwithString:([md5 md5HexDigestwithString:aPassword])];
    NSString *upperVerifyCode=[aVerifyCode uppercaseString];
    //join the two strings
    enPwd_tmp=[NSString stringWithFormat:@"%@%@",enPwd_tmp,upperVerifyCode];
    NSString *pwd=[md5 md5HexDigestwithString:enPwd_tmp];
    NSLog(@"%@",pwd);
    return pwd;
}

//获取验证码
-(NSString *) _verifyCode:(NSString *) aUserName{
    NSHTTPCookieStorage *cookieJar=[NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookieJar setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    NSString *currentTime=[self _currentTimeString];
    //NSLog(@"%@",currentTime);
    NSString *checkUrlString=[NSString stringWithFormat:@"http://login.xunlei.com/check?u=%@&cachetime=%@",aUserName,currentTime];
    
    LCHTTPConnection *request=[LCHTTPConnection new];
    [request get:checkUrlString];
    //把response中的Cookie添加到CookieStorage
    [self _addResponseCookietoCookieStorage:[request responseCookies]];
    
    NSString *vCode;
    vCode=[self cookieValueWithName:@"check_result"];
    //判断是否取得合法VerifyCode
    NSRange range;
    range=[vCode rangeOfString:@":"];
    if(range.location==NSNotFound){
        NSLog(@"Maybe something wrong when get verifyCode");
        return 0;
    }else {
        vCode=[[vCode componentsSeparatedByString:@":"] objectAtIndex:1];
        NSLog(@"%@",vCode);
        
    }
    return vCode;
}


/*
 *迅雷的登陆会过期，有时需要检验一下是否登陆。
 *现在采用的方法比较“重”，效率可能会低一些，但更稳妥直接
 *现在备选的两种方法，第一同样访问taskPage然后检查页面大小判断是否真的登陆
 *第二种方法检查Cookies，但是还未找到判断哪个Cookie
 */
-(BOOL) isLogin{
    BOOL result=NO;
    if([self _tasksWithStatus:TLTComplete]){
        NSLog(@"Thunder Login Successfully");
        result=YES;
    }
    return result;
}

/*
 *有两种方法可以实现logout
 *第一种清空Cookies，第二种访问http://dynamic.vip.xunlei.com/login/indexlogin_contr/logout/，本方法采用了第一种速度快，现在也没发现什么问题。
 */
-(void)logOut{
    NSArray* keys=@[@"vip_isvip",@"lx_sessionid",@"vip_level",@"lx_login",@"dl_enable",@"in_xl",@"ucid",@"lixian_section",@"sessionid",@"usrname",@"nickname",@"usernewno",@"userid",@"gdriveid"];
    for(NSString* i in keys){
        [self setCookieWithKey:i Value:@""];
    }
}

#pragma mark - GDriveID
//GdriveID是一个关键Cookie，在下载文件的时候需要用它进行验证
-(NSString*)GDriveID{
    return [self cookieValueWithName:@"gdriveid"];
}
-(BOOL) isGDriveIDInCookie{
    BOOL result=NO;
    if([self GDriveID]){
        result=YES;
    }
    return result;
}

-(void) setGdriveID:(NSString*) gdriveid{
    [self setCookieWithKey:@"gdriveid" Value:gdriveid];
}


#pragma mark - Referer
//获得Referer
-(NSString*) refererWithStringFormat{
    NSString* urlString=[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/user_task?userid=%@",[self userID]];
    return urlString;
}
-(NSURL*) refererWithURLFormat{
    return [NSURL URLWithString:[self refererWithStringFormat]];
}

#pragma mark - Cookies Methods
//从cookies中取得指定名称的值
-(NSString *) cookieValueWithName:(NSString *)aName{
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSString *value=nil;
    for(NSHTTPCookie *cookie in [cookieJar cookies]){
        if([cookie.domain hasSuffix:@".xunlei.com"]){
//                NSLog(@"%@",cookie);
        if([aName isEqualToString:@"gdriveid"] && [cookie.domain hasSuffix:@".xunlei.com"] && [cookie.name compare:aName]==NSOrderedSame){
            value=cookie.value;
        }
        if([cookie.name compare:aName]==NSOrderedSame){
            value=cookie.value;
            //            NSLog(@"%@:%@",aName,value);
        }}
    }
    return value;
}

//设置Cookies
-(NSHTTPCookie *) setCookieWithKey:(NSString *) key Value:(NSString *) value{
    
    if (key == nil || value == nil) {
        return nil;
    }
    //创建一个cookie
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setObject:value forKey:NSHTTPCookieValue];
    [properties setObject:key forKey:NSHTTPCookieName];
    [properties setObject:@".xunlei.com" forKey:NSHTTPCookieDomain];
    [properties setObject:@"/" forKey:NSHTTPCookiePath];
    [properties setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
    //这里是关键，不要写成@"FALSE",而是应该直接写成TRUE 或者 FALSE，否则会默认为TRUE
    [properties setValue:FALSE forKey:NSHTTPCookieSecure];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    NSHTTPCookieStorage *cookieStorage=[NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    [cookieStorage setCookie:cookie];
    
    
    
    return cookie;
}
//查询Cookie是否存在
-(BOOL) hasCookie:(NSString*) aKey{
    BOOL result=NO;
    if([self cookieValueWithName:aKey]){
        result=YES;
    }
    return result;
}


#pragma mark - UserID,UserNmae
//获取当前UserID
-(NSString *)userID{
    return ([self cookieValueWithName:@"userid"]);
}

-(NSString *)userName{
    return ([self cookieValueWithName:@"usernewno"]);
}




#pragma mark - Public Normal Task Methods
//获取主任务页内容
//公共方法
-(NSMutableArray*) readTasksWithPage:(NSUInteger) pg{
    return [self _tasksWithStatus:TLTAll andPage:pg retIfHasNextPage:NULL];
}
-(NSMutableArray*) readAllTasks1{
    return [self _readAllTasksWithStat:TLTAll];
}
-(NSMutableArray*) readAllCompleteTasks{
    return [self _readAllTasksWithStat:TLTComplete];
}
-(NSMutableArray*) readCompleteTasksWithPage:(NSUInteger) pg{
    return [self _tasksWithStatus:TLTComplete andPage:pg retIfHasNextPage:NULL];
}
-(NSMutableArray*) readAllDownloadingTasks{
    return [self _readAllTasksWithStat:TLTDownloadding];
}
-(NSMutableArray*) readDownloadingTasksWithPage:(NSUInteger) pg{
    return [self _tasksWithStatus:TLTDownloadding andPage:pg  retIfHasNextPage:NULL];
}
-(NSMutableArray *) readAllOutofDateTasks{
    return [self _readAllTasksWithStat:TLTOutofDate];
}
-(NSMutableArray *) readOutofDateTasksWithPage:(NSUInteger) pg{
    return [self _tasksWithStatus:TLTOutofDate andPage:pg  retIfHasNextPage:NULL];
}
-(NSMutableArray*) readAllDeletedTasks{
    return [self _readAllTasksWithStat:TLTDeleted];
}
-(NSMutableArray*) readDeletedTasksWithPage:(NSUInteger) pg{
    return [self _tasksWithStatus:TLTDeleted andPage:pg  retIfHasNextPage:NULL];
}
#pragma mark - Private Normal Task Methods
//私有方法
-(NSMutableArray *) _tasksWithStatus:(TaskListType) listType{
    NSString* userid=[self userID];
    NSURL *url;
    switch (listType) {
        case TLTAll:
            url=[NSURL URLWithString:[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/user_task?userid=%@&st=4",userid]];
            break;
        case TLTComplete:
            url=[NSURL URLWithString:[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/user_task?userid=%@&st=2",userid]];
            break;
        case TLTDownloadding:
            url=[NSURL URLWithString:[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/user_task?userid=%@&st=1",userid]];
            break;
        case TLTOutofDate:
            url=[NSURL URLWithString:[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/user_history?type=1&userid=%@",userid]];
            break;
        case TLTDeleted:
            url=[NSURL URLWithString:[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/user_history?type=0userid=%@",userid]];
            break;
        default:
            break;
    }
    return [self _tasksWithURL:url retIfHasNextPage:NULL listType:listType];
}
-(NSMutableArray *) _tasksWithStatus:(TaskListType) listType andPage:(NSUInteger) pg retIfHasNextPage:(BOOL *) hasNextPage{
    NSString* userid=[self userID];
    NSURL *url;
    switch (listType) {
        case TLTAll:
            
            url=[NSURL URLWithString:[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/interface/showtask_unfresh?type_id=4&page=%lu&tasknum=30",(unsigned long)pg]];

            break;
        case TLTComplete:
            url=[NSURL URLWithString:[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/user_task?userid=%@&st=2&p=%lu",userid,(unsigned long)pg]];
            break;
        case TLTDownloadding:
            url=[NSURL URLWithString:[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/user_task?userid=%@&st=1&p=%lu",userid,(unsigned long)pg]];
            break;
        case TLTOutofDate:
            url=[NSURL URLWithString:[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/user_history?type=1&userid=%@&p=%lu",userid,(unsigned long)pg]];
            break;
        case TLTDeleted:
            url=[NSURL URLWithString:[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/user_history?type=0&userid=%@&p=%lu",userid,(unsigned long)pg]];
            break;
        default:
            break;
    }
    NSLog(@"%@",url);
    return [self _tasksWithURL:url retIfHasNextPage:hasNextPage listType:listType];
}
-(NSMutableArray *) _readAllTasksWithStat:(TaskListType) listType{
    NSUInteger pg=1;
    BOOL hasNP=NO;
    NSMutableArray *allTaskArray=[NSMutableArray arrayWithCapacity:0];
    NSMutableArray *mArray=nil;
    do {
        mArray=[self _tasksWithStatus:listType andPage:pg retIfHasNextPage:&hasNP];
        [allTaskArray addObjectsFromArray:mArray];
        pg++;
    } while (0); // hasNP
    return allTaskArray;
}
//只适用于“已过期”，“已删除”任务

//通用方法
-(NSURL*) _getNextPageURL:(NSString *) currentPageData{
    NSString *tmp=[ParseElements nextPageSubURL:currentPageData];
    NSURL *url=nil;
    if(tmp){
        NSString *u=[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com%@",tmp];
        url=[NSURL URLWithString:u];
    }
    return url;
}
-(BOOL) _hasNextPage:(NSString*) currrentPageData{
    BOOL result=NO;
    if([self _getNextPageURL:currrentPageData]){
        result=YES;
    }
    return result;
}
-(NSMutableArray *) _tasksWithURL:(NSURL *) taskURL retIfHasNextPage:(BOOL *) hasNextPageBool listType:(TaskListType) listtype{
    NSString *siteData;
    //初始化返回Array
    NSMutableArray *elements=[[NSMutableArray alloc] initWithCapacity:0];
    //设置lx_nf_all Cookie
    //不得不喷一下这个东西了，不设置这个Cookie，返回网页有问题，不是没有内容，而是他妈的不全，太傻逼了，浪费了我一个小时的时间
    //而且这个东西只是再查询“已经删除”和“已经过期”才会用，如果在非这两种状态下使用这个Cookies也会出现显示网页不全的问题。
    //迅雷离线的网页怎么做的，飘忽不定
    if(listtype==TLTOutofDate||listtype==TLTDeleted){
        [self setCookieWithKey:@"lx_nf_all" Value:@"page_check_all%3Dhistory%26fltask_all_guoqi%3D1%26class_check%3D0%26page_check%3Dtask%26fl_page_id%3D0%26class_check_new%3D0%26set_tab_status%3D11"];
    }else{
        [self setCookieWithKey:@"lx_nf_all" Value:@""];
    }
    
    if(![self cookieValueWithName:@"lx_login"]){
        //完善所需要的cookies，并收到302响应跳转
        NSString *timeStamp=[self _currentTimeString];
        NSURL *redirectUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/login?cachetime=%@&cachetime=%@&from=0",timeStamp,timeStamp]];
        LCHTTPConnection* redirectURLrequest = [LCHTTPConnection new];
        [redirectURLrequest get:[redirectUrl absoluteString]];
        //获取task页面内容
        LCHTTPConnection *request=[LCHTTPConnection new];
        siteData=[request get:[taskURL absoluteString]];
    }else {
        //获取task页面内容
        LCHTTPConnection *request=[LCHTTPConnection new];
        siteData=[request get:[taskURL absoluteString]];
    }
//    NSLog(@"data:%@",siteData);
    //当得到返回数据且得到真实可用的列表信息（不是502等错误页面）时进行下一步
    //NSString *gdriveid=[ParseElements GDriveID:siteData];
    if (siteData) {
        //设置Gdriveid
        /*
         *===============
         *Parse Html
         *===============
         */
        //检查是否还有下一页
        /*
        if(hasNextPageBool){
            *hasNextPageBool=[self _hasNextPage:siteData];
        }
        NSString *re1=@"<div\\s*class=\"rwbox\"([\\s\\S]*)?<!--rwbox-->";
        NSString *tmpD1=[siteData stringByMatching:re1 capture:1];
        NSString *re2=nil;
        if(listtype==TLTAll|listtype==TLTComplete|listtype==TLTDownloadding){
            re2=@"<div\\s*class=\"rw_list\"[\\s\\S]*?<!--\\s*rw_list\\s*-->";
        }else if (listtype==TLTOutofDate|listtype==TLTDeleted){
            re2=@"<div\\s*class=\"rw_list\"[\\s\\S]*?<input\\s*id=\"d_tasktype\\d+\"\\s*type=\"hidden\"\\s*value=[^>]*>";
        }
        NSArray *allTaskArray=[tmpD1 arrayOfCaptureComponentsMatchedByRegex:re2];*/
        
        //原作者这里直接用正则分析html……可惜迅雷现在用ajax载入任务了……操……重新写吧…………FUCK XUNLEI!
        
        
        
        siteData = [siteData stringByReplacingOccurrencesOfString:@"rebuild(" withString:@""];
        siteData = [siteData substringToIndex:[siteData length] - 1];
        NSLog(@"%@", siteData);

        NSArray *arr=[[[siteData objectFromJSONString] objectForKey:@"info"] objectForKey:@"tasks"];

        NSLog(@"%@", arr);
        
        for(NSDictionary *tmp in arr){
            
            
            //初始化XunleiItemInfo
            XunleiItemInfo *info=[XunleiItemInfo new];
            
            NSLog(@"%@", [tmp objectForKey:@"progress"]);
            //NSString *taskContent=[tmp objectAtIndex:0];
            //            NSLog(@"content:%@",taskContent);
            //NSMutableDictionary *taskInfoDic=[ParseElements taskInfo:taskContent];
            //NSString* taskLoadingProcess=[ParseElements taskLoadProcess:taskContent];
            //NSString* taskRetainDays=[ParseElements taskRetainDays:taskContent];
            //NSString* taskAddTime=[ParseElements taskAddTime:taskContent];
            //NSString* taskType=[ParseElements taskType:taskContent];
            //NSString* taskReadableSize=[ParseElements taskSize:taskContent];
            
            
            
            info.taskid=[tmp objectForKey:@"id"];
            info.dcid = [tmp objectForKey:@"cid"];
            info.name=[tmp objectForKey:@"taskname"];
            info.size=[tmp objectForKey:@"ysfilesize"];
            info.readableSize=[tmp objectForKey:@"filesize"];
            info.downloadPercent=[tmp objectForKey:@"progress"];
            
            info.addDate=[tmp objectForKey:@"dt_committed"];
            info.downloadURL=[tmp objectForKey:@"lixian_url"];
            info.type=[tmp objectForKey:@"ext"];
            info.isBT=[tmp objectForKey:@"tasktype"];
            //info.dcid=[taskInfoDic objectForKey:@"dcid"];
            //info.status=[[taskInfoDic objectForKey:@"d_status"] integerValue];
            //info.originalURL=[taskInfoDic objectForKey:@"f_url"];
            info.ifvod=[tmp objectForKey:@"vod"];
            
            [elements addObject:info];
        }
        //return info
        
        return elements;
    }else {
        return nil;
    }
    //NSLog(@"%@",elements);
}

#pragma mark - BT Task
-(NSMutableArray *) readAllBTTaskListWithTaskID:(NSString *) taskid hashID:(NSString *)dcid{
    NSUInteger pg=1;
    BOOL hasNP=NO;
    NSMutableArray *allTaskArray=[NSMutableArray arrayWithCapacity:0];
    NSMutableArray *mArray=nil;
    do {
        mArray=[self readSingleBTTaskListWithTaskID:taskid hashID:dcid andPageNumber:pg];
        if(mArray){
            hasNP=YES;
            [allTaskArray addObjectsFromArray:mArray];
            pg++;
        }else{
            hasNP=NO;
        }
    } while (hasNP);
    return allTaskArray;
}
//获取BT页面内容(hashid 也就是dcid)
-(NSMutableArray *) readSingleBTTaskListWithTaskID:(NSString *) taskid hashID:(NSString *)dcid andPageNumber:(NSUInteger) pg{
    NSMutableArray *elements=[[NSMutableArray alloc] initWithCapacity:0];
    NSString *userid=[self userID];
    NSString *currentTimeStamp=[self _currentTimeString];
    NSString *urlString=[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/interface/fill_bt_list?callback=fill_bt_list&tid=%@&infoid=%@&g_net=1&p=%lu&uid=%@&noCacheIE=%@",taskid,dcid,(unsigned long)pg,userid,currentTimeStamp];
    NSURL *url=[NSURL URLWithString:urlString];
    //获取BT task页面内容
    LCHTTPConnection *request=[LCHTTPConnection new];
    NSString* siteData=[request get:[url absoluteString]];
    if (siteData) {
        NSString *re=@"^fill_bt_list\\((.+)\\)\\s*$";
        NSString *s=[siteData stringByMatching:re capture:1];
        
        NSDictionary *dic=[s objectFromJSONString];
        NSDictionary *result=[dic objectForKey:@"Result"];
        //dcid Value
        //NSString *dcid=[result objectForKey:@"Infoid"];
        NSArray *record=[result objectForKey:@"Record"];
        
        for(NSDictionary *task in record){
            XunleiItemInfo *info=[XunleiItemInfo new];

            info.taskid=taskid;
            info.name=[task objectForKey:@"title"];
            info.size=[task objectForKey:@"filesize"];
            info.retainDays=[task objectForKey:@"livetime"];
            info.addDate=@"";
            info.downloadURL=[task objectForKey:@"downurl"];
            info.originalURL=[task objectForKey:@"url"];
            info.isBT=@"1";
            info.type=[task objectForKey:@"openformat"];
            info.dcid=[task objectForKey:@"cid"];
            info.ifvod=[task objectForKey:@"vod"];
            info.status=[[task objectForKey:@"download_status"] integerValue];
            info.readableSize=[task objectForKey:@"size"];
            info.downloadPercent=[task objectForKey:@"percent"];
            [elements addObject:info];
        }
        if([elements count]>0){
            return elements;
        }else {
            return nil;
        }
    }else {
        return nil;
    }
    //NSLog(@"%@",elements);
    //return elements;
}

#pragma mark - YunZhuanMa Methods
-(NSMutableArray*) readAllYunTasks{
    NSUInteger pg=1;
    BOOL hasNP=NO;
    NSMutableArray *allTaskArray=[NSMutableArray arrayWithCapacity:0];
    NSMutableArray *mArray=nil;
    
    do {
        mArray=[self readYunTasksWithPage:pg retIfHasNextPage:&hasNP];
        [allTaskArray addObjectsFromArray:mArray];
        pg++;
    } while (hasNP);
    return allTaskArray;
}

//获取云转码页面信息
-(NSMutableArray *) readYunTasksWithPage:(NSUInteger) pg retIfHasNextPage:(BOOL *) hasNextPageBool{
    NSString* aUserID=[self userID];
    //初始化返回Array
    NSMutableArray *elements=[[NSMutableArray alloc] initWithCapacity:0];
    NSURL *requestURL=[NSURL URLWithString:[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/cloud?userid=%@&p=%ld",aUserID,(unsigned long)pg]];
    LCHTTPConnection *request=[LCHTTPConnection new];
    NSString* data=[request get:[requestURL absoluteString]];
    if(data){
        if(hasNextPageBool){
            //检查是否还有下一页
            *hasNextPageBool=[self _hasNextPage:data];
        }
        NSString *re1=@"<div\\s*class=\"rwbox\"([\\s\\S]*)?<!--rwbox-->";
        NSString *tmpD1=[data stringByMatching:re1 capture:1];
        NSString *re2=@"<div\\s*class=\"rw_list\"[\\s\\S]*?<!--\\s*rw_list\\s*-->";
        NSArray *allTaskArray=[tmpD1 arrayOfCaptureComponentsMatchedByRegex:re2];
        for(NSArray *tmp in allTaskArray){
            //初始化XunleiItemInfo
            XunleiItemInfo *info=[XunleiItemInfo new];
            NSString *taskContent=[tmp objectAtIndex:0];
            
            NSMutableDictionary *taskInfoDic=[ParseElements taskInfo:taskContent];
            NSString* taskLoadingProcess=[ParseElements taskLoadProcess:taskContent];
            NSString* taskRetainDays=[ParseElements taskRetainDays:taskContent];
            NSString* taskAddTime=[ParseElements taskAddTime:taskContent];
            NSString* taskType=[ParseElements taskType:taskContent];
            NSString* taskReadableSize=[ParseElements taskSize:taskContent];
            
            info.taskid=[taskInfoDic objectForKey:@"id"];
            info.name=[taskInfoDic objectForKey:@"cloud_taskname"];
            info.size=[taskInfoDic objectForKey:@"ysfilesize"];
            info.readableSize=taskReadableSize;
            info.downloadPercent=taskLoadingProcess;
            info.retainDays=taskRetainDays;
            info.addDate=taskAddTime;
            info.downloadURL=[taskInfoDic objectForKey:@"cloud_dl_url"];
            info.type=taskType;
            info.isBT=[taskInfoDic objectForKey:@"d_tasktype"];
            info.dcid=[taskInfoDic objectForKey:@"dcid"];
            info.status=[[taskInfoDic objectForKey:@"cloud_d_status"] integerValue];
            //info.originalURL=[taskInfoDic objectForKey:@"f_url"];
            //info.ifvod=[taskInfoDic objectForKey:@"ifvod"];
            //NSLog(@"Yun Name:%@",info.name);
            [elements addObject:info];
        }
        //return info
        return elements;
    }else {
        return nil;
    }
}

#pragma mark - Add BT
//本来不想加最后那个param的。。但是貌似重复上传文件但没有后续操作会导致添加文件失败。所以就加了这个。获取数据后，把dictionary填到最后一个位置就可以了
//请注意selection的这个array里面存着的是findex

- (NSString *)addBTTask:(NSString *)filePath selection:(NSArray *)array hasFetchedFileList:(NSDictionary *)dataField {
    if (array.count > 0) {
        if (dataField == nil) {
            dataField = [self fetchBTFileList:filePath];
            if (dataField == nil) {
                return nil;
            }
        }
        
        
        
        int ret_value = [dataField[@"ret_value"] intValue];
        
        // ret value等于0就是失败啊，目前只看到出现过1，不知道会不会有别的值。所以这里先用不等于0作为判断。
        
        if (ret_value != 0) {
            
            NSString *dcid = dataField[@"infoid"];
            NSString *tsize = dataField[@"btsize"];
            NSString *btname = dataField[@"ftitle"];
            NSArray *fileList = dataField[@"filelist"];
            //    NSString *random = dataField[@"random"];
            //
            
            //提交任务
            NSURL *commitURL = [NSURL URLWithString:@"http://dynamic.cloud.vip.xunlei.com/interface/bt_task_commit"];
            LCHTTPConnection* commitRequest = [LCHTTPConnection new];
            
            NSArray *subSizes = [fileList valueForKey:@"subsize"];
            
            NSMutableArray *sizeArray = [[NSMutableArray alloc] init];
            for (NSString *select in array) {
                NSInteger index = [[fileList valueForKey:@"findex"] indexOfObject:select];
                [sizeArray addObject:subSizes[index]];
            }
            
            [commitRequest setPostValue:[self userID] forKey:@"uid"];
            [commitRequest setPostValue:[URlEncode encodeToPercentEscapeString:btname] forKey:@"btname"];
            [commitRequest setPostValue:dcid forKey:@"cid"];
            [commitRequest setPostValue:@"0" forKey:@"goldbean"];
            [commitRequest setPostValue:@"0" forKey:@"silverbean"];
            [commitRequest setPostValue:tsize forKey:@"tsize"];
            [commitRequest setPostValue:[array componentsJoinedByString:@"_"] forKey:@"findex"];
            [commitRequest setPostValue:[sizeArray componentsJoinedByString:@"_"] forKey:@"size"];
            [commitRequest setPostValue:@"0" forKey:@"o_taskid"];
            [commitRequest setPostValue:@"task" forKey:@"o_page"];
            [commitRequest setPostValue:@"0" forKey:@"class_id"];
            [commitRequest setPostValue:@"task" forKey:@"interfrom"];
            [commitRequest post:[commitURL absoluteString]];
            return dcid;
            
        }
    }
    
    return nil;
}

- (NSDictionary *)fetchBTFileList:(NSString *)filePath {
    
    LCHTTPConnection *request=[LCHTTPConnection new];
    NSString *postResult = [request postBTFile:filePath];
    
    postResult = [postResult stringByReplacingOccurrencesOfString:@"<script>document.domain=\"xunlei.com\";var btResult =" withString:@""];
    postResult = [postResult stringByReplacingOccurrencesOfString:@";var btRtcode = 0</script>" withString:@""];
    postResult = [postResult stringByReplacingOccurrencesOfString:@";</script>" withString:@""];

    if ([postResult dataUsingEncoding:NSUTF8StringEncoding] == nil) {
        return nil;
    }
    
    NSDictionary *dataField = [NSJSONSerialization JSONObjectWithData:[postResult dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
    
    return dataField;
}

- (NSString *)fileSize:(float)size {
    int counter = 0;
    while (size > 1000) {
        size /= 1000;
        counter++;
    }
    
    NSString *size_type = @"Bytes";
    switch (counter) {
        case 1:
            size_type = @"KB";
            break;
            
        case 2:
            size_type = @"MB";
            break;
            
        case 3:
            size_type = @"GB";
            break;
            
        case 4:
            size_type = @"TB";
            break;
            
        case 5:
            size_type = @"PB";
            break;
            
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%.2f %@", size, size_type];
}


#pragma mark - Add Task
//add megnet task
//返回dcid作为文件标示
-(NSString *) addMegnetTask:(NSString *) url{
    NSString *dcid;
    NSString *tsize;
    NSString *btname;
    NSString *findex;
    NSString *sindex;
    NSString *enUrl=[URlEncode encodeToPercentEscapeString:url];
    NSString *timestamp=[self _currentTimeString];
    NSString *callURLString=[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/interface/url_query?callback=queryUrl&u=%@&random=%@",enUrl,timestamp];
    NSURL *callURL=[NSURL URLWithString:callURLString];
    LCHTTPConnection *request=[LCHTTPConnection new];
    NSString* data=[request get:[callURL absoluteString]];
    NSString *re=@"queryUrl(\\(1,.*\\))\\s*$";
    NSString *sucsess=[data stringByMatching:re capture:1];
    if(sucsess){
        //NSLog(sucsess);
        NSArray *array=[sucsess componentsSeparatedByString:@"new Array"];
        //first data
        NSString *dataGroup1=[array objectAtIndex:0];
        //last data
        NSString *dataGroup2=[array objectAtIndex:([array count]-1)];
        //last fourth data
        NSString *dataGroup3=[array objectAtIndex:([array count]-4)];
        NSString *re1=@"['\"]?([^'\"]*)['\"]?";
        dcid=[[[dataGroup1 componentsSeparatedByString:@","] objectAtIndex:1] stringByMatching:re1 capture:1];
        //NSLog(cid);
        tsize=[[[dataGroup1 componentsSeparatedByString:@","] objectAtIndex:2] stringByMatching:re1 capture:1];
        //NSLog(tsize);
        btname=[[[dataGroup1 componentsSeparatedByString:@","] objectAtIndex:3] stringByMatching:re1 capture:1];
        //NSLog(btname);
        
        //findex
        NSString *re2=@"\\(([^\\)]*)\\)";
        NSString *preString0=[dataGroup2 stringByMatching:re2 capture:1];
        NSString *re3=@"'([^']*)'";
        NSArray *preArray0=[preString0 arrayOfCaptureComponentsMatchedByRegex:re3];
        NSMutableArray *preMutableArray=[NSMutableArray arrayWithCapacity:0];
        for(NSArray *a in preArray0){
            [preMutableArray addObject:[a objectAtIndex:1]];
        }
        findex=[preMutableArray componentsJoinedByString:@"_"];
        //NSLog(@"%@",findex);
        
        //size index
        preString0=[dataGroup3 stringByMatching:re2 capture:1];
        preArray0=[preString0 arrayOfCaptureComponentsMatchedByRegex:re3];
        NSMutableArray *preMutableArray1=[NSMutableArray arrayWithCapacity:0];
        for(NSArray *a in preArray0){
            [preMutableArray1 addObject:[a objectAtIndex:1]];
        }
        sindex=[preMutableArray1 componentsJoinedByString:@"_"];
        //NSLog(@"%@",sindex);
        
        //提交任务
        NSURL *commitURL = [NSURL URLWithString:@"http://dynamic.cloud.vip.xunlei.com/interface/bt_task_commit"];
        LCHTTPConnection* commitRequest = [LCHTTPConnection new];

        [commitRequest setPostValue:[self userID] forKey:@"uid"];
        [commitRequest setPostValue:btname forKey:@"btname"];
        [commitRequest setPostValue:dcid forKey:@"cid"];
        [commitRequest setPostValue:tsize forKey:@"tsize"];
        [commitRequest setPostValue:findex forKey:@"findex"];
        [commitRequest setPostValue:sindex forKey:@"size"];
        [commitRequest setPostValue:@"0" forKey:@"from"];
        [commitRequest post:[commitURL absoluteString]];
    }else {
        NSString *re1=@"queryUrl\\(-1,'([^']{40})";
        dcid=[data stringByMatching:re1 capture:1];
    }
    //NSLog(@"%@",cid);
    return dcid;
}


//add normal task(http,ed2k...)
//返回dcid作为文件标示
-(NSString *) addNormalTask:(NSString *)url{
    ConvertURL *curl=[ConvertURL new];
    NSString *decodeurl=[curl urlUnmask:url];
    NSString *enUrl=[URlEncode encodeToPercentEscapeString:decodeurl];
    NSString *timestamp=[self _currentTimeString];
    NSString *callURLString=[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/interface/task_check?callback=queryCid&url=%@&random=%@&tcache=%@",enUrl,timestamp,timestamp];
//    NSURL *callURL=[NSURL URLWithString:callURLString];
    LCHTTPConnection *request=[LCHTTPConnection new];
    NSString *dataRaw=[request get:callURLString];
    
    NSString *dcid=@"";
    NSString *gcid=@"";
    NSString *size=@"";
    NSString *filename=@"";
    NSString *goldbeen=@"";
    NSString *silverbeen=@"";
    NSString *is_full=@"";
    NSString *random=@"";
    NSString *ext=@"";
    NSString *someKey=@"";
    NSString *taskType=@"";
    NSString *userid=@"";
    NSString *noCacheIE = @"";
    NSString *unknownData = @"";
    
    userid=[self userID];
    
    
    if(([url rangeOfString:@"http://" options:NSCaseInsensitiveSearch].length>0)||([url rangeOfString:@"ftp://" options:NSCaseInsensitiveSearch].length>0)){
        taskType=@"0";
    }else if([url rangeOfString:@"ed2k://" options:NSCaseInsensitiveSearch].length>0){
        taskType=@"2";
    }
    
    NSString *re=@"queryCid\\((.+)\\)\\s*$";
    NSString *sucsess=[dataRaw stringByMatching:re capture:1];
    NSArray *data=[sucsess componentsSeparatedByString:@","];
    NSMutableArray *newData=[NSMutableArray arrayWithCapacity:0];
    for(NSString *i in data){
        NSString *re1=@"\\s*['\"]?([^']*)['\"]?";
        NSString *d=[i stringByMatching:re1 capture:1];
        if(!d){
            d=@"";
        }
        [newData addObject:d];
        NSLog(@"%@",d);
    }
    if(8==data.count){
        dcid=[newData objectAtIndex:0];
        gcid=[newData objectAtIndex:1];
        size=[newData objectAtIndex:2];
        filename=[newData objectAtIndex:3];
        goldbeen=[newData objectAtIndex:4];
        silverbeen=[newData objectAtIndex:5];
        is_full=[newData objectAtIndex:6];
        random=[newData objectAtIndex:7];
    }
    else if(9==data.count){
        dcid=[newData objectAtIndex:0];
        gcid=[newData objectAtIndex:1];
        size=[newData objectAtIndex:2];
        filename=[newData objectAtIndex:3];
        goldbeen=[newData objectAtIndex:4];
        silverbeen=[newData objectAtIndex:5];
        is_full=[newData objectAtIndex:6];
        random=[newData objectAtIndex:7];
        ext=[newData objectAtIndex:8];
    }else if(10==data.count){
        dcid=[newData objectAtIndex:0];
        gcid=[newData objectAtIndex:1];
        size=[newData objectAtIndex:2];
        someKey=[newData objectAtIndex:3];
        filename=[newData objectAtIndex:4];
        goldbeen=[newData objectAtIndex:5];
        silverbeen=[newData objectAtIndex:6];
        is_full=[newData objectAtIndex:7];
        random=[newData objectAtIndex:8];
        ext=[newData objectAtIndex:9];
    } else if (data.count == 11) {
        dcid=[newData objectAtIndex:0];
        gcid=[newData objectAtIndex:1];
        size=[newData objectAtIndex:2];
        someKey=[newData objectAtIndex:3];
        filename=[newData objectAtIndex:4];
        goldbeen=[newData objectAtIndex:5];
        silverbeen=[newData objectAtIndex:6];
        is_full=[newData objectAtIndex:7];
        noCacheIE=[newData objectAtIndex:8];
        ext=[newData objectAtIndex:9];
        unknownData = newData[10];
        
    }
    //filename如果是中文放到URL中会有编码问题，需要转码
    NSString *newFilename=[URlEncode encodeToPercentEscapeString:filename];
    
    double UTCTime=[[NSDate date] timeIntervalSince1970];
    NSString *currentTime=[NSString stringWithFormat:@"%f",UTCTime*1000];
    
    NSString *commitString1 = [NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/interface/task_check?callback=queryCid&url=%@&interfrom=task&random=%@&tcache=%@", enUrl, currentTime,timestamp];
    
    NSString *commitString2 = [NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/interface/task_commit?callback=ret_task&uid=%@&cid=%@&gcid=%@&size=%@&goldbean=%@&silverbean=%@&t=%@&url=%@&type=%@&o_page=history&o_taskid=0&class_id=0&database=undefined&interfrom=task&noCacheIE=%@",userid,dcid,gcid,size,goldbeen,silverbeen,newFilename,enUrl,taskType,timestamp];

    //NSLog(@"%@",commitString);
    //NSURL *commitURL1=[NSURL URLWithString:commitString1];
    //NSLog(@"%@",commitURL1);
    LCHTTPConnection *commitRequest1=[LCHTTPConnection new];
    [commitRequest1 get:commitString1];
    
    //NSLog(@"%@",commitString);
    //NSURL *commitURL2=[NSURL URLWithString:commitString2];
    //NSLog(@"%@",commitURL2);
    LCHTTPConnection *commitRequest2=[LCHTTPConnection new];
    [commitRequest2 get:commitString2];
    
    return dcid;
}

-(unsigned long long)getRandomNumberBetween:(unsigned long long)from to:(unsigned long long)to {
    
    return (unsigned long long)from + arc4random() % (to-from+1);
}

#pragma mark - Delete Task
//Delete tasks
-(BOOL) deleteSingleTaskByID:(NSString*) id{
    BOOL result=NO;
    result=[self deleteTasksByArray:@[id]];
    return result;
}
-(BOOL) deleteTasksByIDArray:(NSArray *)ids{
    BOOL result=NO;
    result=[self deleteTasksByArray:ids];
    return result;
}
-(BOOL) deleteSingleTaskByXunleiItemInfo:(XunleiItemInfo*) aInfo{
    BOOL result=NO;
    result=[self deleteTasksByArray:@[aInfo]];
    return result;
}
-(BOOL) deleteTasksByXunleiItemInfoArray:(NSArray *)ids{
    BOOL result=NO;
    result=[self deleteTasksByArray:ids];
    return result;
}
-(BOOL) deleteTasksByArray:(NSArray *)ids{
    BOOL returnResult=NO;
    NSMutableString *idString=[NSMutableString string];
    for(id i in ids){
        if([i isKindOfClass:[XunleiItemInfo class]]){
            [idString appendString:[(XunleiItemInfo*)i taskid]];
        }else if([i isKindOfClass:[NSString class]]){
            [idString appendString:i];
        }else{
            NSLog(@"Warning!!deleteTasksByArray:UnKnown Type!");
            //[idString appendString:i];
        }
        [idString appendString:@","];
    }
    NSString *jsonString=[NSString stringWithFormat:@"jsonp%@",[self _currentTimeString]];
    NSString *urlString=[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/interface/task_delete?callback=%@&type=2",jsonString];
    NSLog(@"%@",urlString);
    NSURL *url=[NSURL URLWithString:urlString];
    LCHTTPConnection *request=[LCHTTPConnection new];
    NSMutableString *IDs_postdata=[[ids componentsJoinedByString:@","] mutableCopy];
    [IDs_postdata appendString:@","];
    NSString *databasesID_postdata=@"0,";
    [request setPostValue:IDs_postdata forKey:@"taskids"];
    [request setPostValue:databasesID_postdata forKey:@"databases"];
    NSString *requestString=[request post:[url absoluteString]];
    if ([requestString hasSuffix:@"({\"result\":1,\"type\":2})"]) {
        returnResult=YES;
    }
    return returnResult;
}
#pragma mark - Pause Task
-(BOOL) pauseMultiTasksByTaskID:(NSArray*) ids{
    BOOL returnResult=NO;
    NSString* idString=[ids componentsJoinedByString:@","];
    NSString *requestString=[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/interface/task_pause?tid=%@&uid=%@",idString,[self userID]];
    LCHTTPConnection *request=[LCHTTPConnection new];
    NSString* responsed=[request get:requestString];
    if(responsed){
        returnResult=YES;
    }
    return returnResult;
}
-(BOOL) pauseTaskWithID:(NSString*) taskID{
    return [self pauseMultiTasksByTaskID:@[ taskID ]];
}
-(BOOL) pauseTask:(XunleiItemInfo*) info{
    return [self pauseTaskWithID:info.taskid];
}
-(BOOL) pauseMutiTasksByTaskItemInfo:(NSArray*) infos{
    NSMutableArray* tids=[NSMutableArray arrayWithCapacity:0];
    for(XunleiItemInfo *info in infos){
        [tids addObject:[info taskid]];
    }
    return [self pauseMultiTasksByTaskID:tids];
}
#pragma mark - ReStart Task
-(BOOL) restartTask:(XunleiItemInfo*) info{
    return [self restartMutiTasksByTaskItemInfo:@[info]];
}
-(BOOL) restartMutiTasksByTaskItemInfo:(NSArray*) infos{
    BOOL returnResult=YES;
    for(XunleiItemInfo* info in infos){
        NSString* callbackString=[NSString stringWithFormat:@"jsonp%@",[self _currentTimeString]];
        NSURL *requestURL=[NSURL URLWithString:[NSString stringWithFormat:@"http://dynamic.cloud.vip.xunlei.com/interface/redownload?callback=%@",callbackString]];
        
        LCHTTPConnection* commitRequest = [LCHTTPConnection new];
        [commitRequest setPostValue:info.taskid forKey:@"id[]"];
        [commitRequest setPostValue:info.dcid forKey:@"cid[]"];
        [commitRequest setPostValue:info.originalURL forKey:@"url[]"];
        [commitRequest setPostValue:info.name forKey:@"taskname[]"];
        [commitRequest setPostValue:[NSString stringWithFormat:@"%u",info.status] forKey:@"download_status[]"];
        [commitRequest setPostValue:@"1" forKey:@"type"];
        [commitRequest setPostValue:@"0" forKey:@"class_id"];
        NSString *responseString=[commitRequest post:[requestURL absoluteString]];
        if (!responseString) {
            returnResult=NO;
        }
    }
    return returnResult;
}
#pragma mark - Yun ZhuanMa Methods

-(NSString *)getCloudPlayData:(NSString *)url {
    
    NSString *encodedValue = (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(nil,(CFStringRef)url, nil,(CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    
    NSString *urlString=[NSString stringWithFormat:@"http://i.vod.xunlei.com/req_get_method_vod?url=%@&platform=1&jsonp=jsonp1234567890&userid=%@&sessionid=%@",encodedValue, [self userID], [self cookieValueWithName:@"sessionid"]];
    NSLog(@"%@", urlString);
    
    //获取BT task页面内容
    LCHTTPConnection *request=[LCHTTPConnection new];
    
    NSString* siteData=[[[request get:urlString] stringByReplacingOccurrencesOfString:@"jsonp1234567890(" withString:@""] stringByReplacingOccurrencesOfString:@"})" withString:@"}"];
    
    NSLog(@"%@", [siteData objectFromJSONString]);
    
    return siteData;
}

//Yun Zhuan Ma
-(BOOL) addYunTaskWithFileSize:(NSString*) size downloadURL:(NSString*) url dcid:(NSString*) cid fileName:(NSString*) aName Quality:(YUNZHUANMAQuality) q{
    NSString *gcid=[ParseElements GCID:url];
    NSURL *requestURL=[NSURL URLWithString:@"http://dynamic.cloud.vip.xunlei.com/interface/cloud_build_task/"];
    NSString *detailTaskPostValue=[NSString stringWithFormat:@"[{\"section_type\":\"c7\",\"filesize\":\"%@\",\"gcid\":\"%@\",\"cid\":\"%@\",\"filename\":\"%@\"}]",size,gcid,cid,aName];
    LCHTTPConnection* commitRequest = [LCHTTPConnection new];
    NSString *cloudFormat=[NSString stringWithFormat:@"%d",q];
    [commitRequest setPostValue:cloudFormat  forKey:@"cloud_format"];
    [commitRequest setPostValue:detailTaskPostValue forKey:@"tasks"];
    NSString *response=[commitRequest post:[requestURL absoluteString]];
    if(response){
        NSDictionary *rDict=[response objectFromJSONString];
        if([rDict objectForKey:@"succ"] && [[rDict objectForKey:@"succ"] intValue]==1){
            return YES;
        }
    }
    return NO;
}
-(BOOL) deleteYunTaskByID:(NSString*) anId{
    return [self deleteYunTasksByIDArray:@[anId]];
}

-(BOOL) deleteYunTasksByIDArray:(NSArray *)ids{
    BOOL returnResult=NO;
    NSString *jsontext=[ids JSONString];
    NSURL *url=[NSURL URLWithString:@"http://dynamic.cloud.vip.xunlei.com/interface/cloud_delete_task"];
    LCHTTPConnection*request = [LCHTTPConnection new];
    
    [request setPostValue:jsontext forKey:@"tasks"];

    NSString *response=[request post:[url absoluteString]];
    if(response){
        NSDictionary *resJson=[response objectFromJSONString];
        if([[resJson objectForKey:@"result"] intValue]==0){
            returnResult=YES;
        }
    }
    return returnResult;
}
#pragma mark - Xunlei KuaiChuan ...迅雷快传
-(BOOL) addAllKuaiTasksToLixianByURL:(NSURL*) kuaiURL{
    BOOL result=NO;
    Kuai *k=[Kuai new];
    NSArray *infos=[k kuaiItemInfoArrayByKuaiURL:kuaiURL];
    for(KuaiItemInfo *i in infos){
        NSString *url=i.urlString;
        NSString* t=[self addNormalTask:url];
        if(t) result=YES;
    }
    return result;
}
-(NSArray*) getKuaiItemInfos:(NSURL*) kuaiURL{
    Kuai *k=[Kuai new];
    return [k kuaiItemInfoArrayByKuaiURL:kuaiURL];
}

-(NSString*) generateXunleiURLStringByKuaiItemInfo:(KuaiItemInfo*) info{
    Kuai *k=[Kuai new];
    return [k generateLixianUrl:info];
}

#pragma mark - Other Useful Methods
-(void) _addResponseCookietoCookieStorage:(NSArray*) cookieArray{
    //在iOS下还没有问题，但是在Mac下，如果收到的Cookie没有ExpireDate那么就不会存储到CookieStorage中，会造成获取错误
    //目前为了不影响原有的带有ExpireDate的Cookie，只是在登陆上的几个跳转加了ExpireDate
    //其实这么做迅雷没有什么问题，本来那几个登陆的关键值就是Non-Session的，反而是Mac OS蛋疼了
    //参考连接：http://stackoverflow.com/questions/11570737/shared-instance-of-nshttpcookiestorage-does-not-persist-cookies
    //WTF!!!
    for(NSHTTPCookie* i in cookieArray ){
        [self setCookieWithKey:i.name Value:i.value];
    }
}

-(XunleiItemInfo *) getTaskWithTaskID:(NSString*) aTaskID{
    XunleiItemInfo *r=nil;
    NSMutableArray *array=[self _readAllTasksWithStat:TLTAll];
    for(XunleiItemInfo* i in array){
        if(i.taskid==aTaskID){
            r=i;
        }
    }
    return r;
}

//取得当前UTC时间，并转换成13位数字字符
-(NSString *) _currentTimeString{
    double UTCTime=[[NSDate date] timeIntervalSince1970];
    NSString *currentTime=[NSString stringWithFormat:@"%f",UTCTime*1000];
    NSLog(@"%@",currentTime);
    currentTime=[[currentTime componentsSeparatedByString:@"."] objectAtIndex:0];
    
    return currentTime;
}
@end
