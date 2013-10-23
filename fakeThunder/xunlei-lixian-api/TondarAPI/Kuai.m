//
//  Kuai.m
//  TondarAPI
//
//  Created by liuchao on 8/20/12.
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
#import "Kuai.h"
#import "LCHTTPConnection.h"
#import "NSString+RE.h"
@implementation KuaiItemInfo
-(id)init{
    self=[super init];
    if(self){
        _name=nil;
        _urlString=nil;
        _size=nil;
        _gcid=nil;
        _cid=nil;
        _gcid_resid=nil;
        _fid=nil;
        _tid=nil;
        _namehex=@"0102";
        _internalid=@"111";
        _taskid=@"xxx";
    }
    return self;
}

@end


@implementation Kuai

-(NSArray*) kuaiItemInfoArrayByKuaiURL:(NSURL*) kuaiURL{
    NSMutableArray *retArray=[NSMutableArray arrayWithCapacity:0];
    LCHTTPConnection *request=[LCHTTPConnection new];
    NSString* data=[request get:[kuaiURL absoluteString]];
    if(data){
        NSString* re=@"file_name=\"([^\"]*)\"\\s*file_url=\"([^\"]*)\"\\s*file_size=\"([^\"]*)\"\\s*cid=\"([^\"]*)\"\\s*gcid=\"([^\"]*)\"\\s*gcid_resid=\"([^\"]*)\"";
        NSArray *originalUrlInfoArray=[data arrayOfCaptureComponentsMatchedByRegex:re];
        for(NSArray *i in originalUrlInfoArray){
            KuaiItemInfo *item=[KuaiItemInfo new];
            item.name=[i objectAtIndex:1];
            item.urlString=[i objectAtIndex:2];
            item.size=[i objectAtIndex:3];
            item.cid=[i objectAtIndex:4];
            item.gcid=[i objectAtIndex:5];
            item.gcid_resid=[i objectAtIndex:6];
            
            NSString *fidRex=@"fid=([^&]+)";
            item.fid=[item.urlString stringByMatching:fidRex capture:1];
            
            NSString *tidRex=@"tid=([^&]+)";
            item.tid=[item.urlString stringByMatching:tidRex capture:1];
            
            [retArray addObject:item];
            item=nil;
            //            NSLog(@"%@",[i objectAtIndex:1]);
            //             NSLog(@"%@",[i objectAtIndex:4]);
            //            NSLog(@"%@",tid);
        }
    }
    return retArray;
}
-(NSString*) generateLixianUrl:(KuaiItemInfo*) itemInfo{
    NSString *urlT=[NSString stringWithFormat:@"http://gdl.lixian.vip.xunlei.com/download?fid=%@&mid=666&threshold=150&tid=%@&srcid=4&verno=1&g=%@&scn=t16&i=%@&t=1&ui=%@&ti=%@&s=%@&m=0&n=%@",itemInfo.fid,itemInfo.tid,itemInfo.gcid,itemInfo.gcid,itemInfo.internalid,itemInfo.taskid,itemInfo.size,itemInfo.namehex];
    return urlT;
}
@end
