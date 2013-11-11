//
//  XunleiItemInfo.h
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


#import <Foundation/Foundation.h>

typedef enum{
    sWaiting=0,
    sDownloadding=1,
    sComplete=2,
    sFail=3,
    sPending=4
}TaskStatus;


@interface XunleiItemInfo : NSObject<NSCoding>

@property(nonatomic, assign) NSString *taskid;
//任务名称
@property(nonatomic, assign) NSString *name;
//任务大小（以字节为单位）
@property(nonatomic, assign) NSString *size;
//任务大小（易读）
@property(nonatomic, assign) NSString *readableSize;
//下载进度(float)
@property(nonatomic, assign) NSString *downloadPercent;
//剩余保留时间
@property(nonatomic, assign) NSString  *retainDays;
//添加时间
@property(nonatomic, assign) NSString *addDate;
//下载地址
@property(nonatomic, assign) NSString *downloadURL;
//原始下载地址
@property(nonatomic, assign) NSString *originalURL;
//BT或者普通任务(0为BT，1为普通任务）
@property(nonatomic, assign) NSString *isBT;
//
@property(nonatomic, assign) NSString *type;
//hash
@property(nonatomic, assign) NSString  *dcid;
//下载状态
@property(nonatomic) TaskStatus  status;
//是否可以在线播放
@property(nonatomic, assign) NSString *ifvod;

@end
