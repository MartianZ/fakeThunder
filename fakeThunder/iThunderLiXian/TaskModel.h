//
//  TaskModel.h
//  iThunderLiXian
//
//  Created by Martian on 12-7-6.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadOperation.h"

@class DownloadOperation;
@interface TaskModel : NSObject {
    NSString *_TaskTitle;
    NSString *_FatherTitle;
    NSString *_TaskSizeDescription;
    NSString *_TaskLiXianProcess;
    NSString *_TaskID;
    NSImage *_TaskType;
    NSUInteger _TaskSize;
    NSUInteger _TaskDownloadedSize; //只有BT任务用来记录，其他时候忽略这个
    NSString *_Cookie;
    BOOL _Indeterminate;
    NSInteger _ProgressValue;
    NSString *_LiXianURL;

    NSString *_TaskTypeString;
    NSString *_CID;
    NSString *_ButtonTitle;
    TaskModel *_FatherTaskModel;
    
    BOOL _ButtonEnabled;
    
    DownloadOperation *_download_operation;
    BOOL _StartAllDownloadNow;
    
    NSString *_TimeLeft;
    @public
    BOOL _NeedToStopNow;
}

@property (atomic) BOOL ButtonEnabled;
@property (atomic, retain) NSString *ButtonTitle;
@property (atomic) NSUInteger TaskSize;
@property (atomic, retain) NSString *TaskTitle;
@property (atomic, retain) NSString *FatherTitle;
@property (atomic, retain) NSString *TaskSizeDescription;
@property (atomic, retain) NSString *TaskLiXianProcess;
@property (atomic, retain) NSString *TaskID;
@property (atomic, retain) NSImage *TaskType;
@property (atomic) BOOL Indeterminate;
@property (atomic) NSInteger ProgressValue;
@property (atomic) NSUInteger TaskDownloadedSize;
@property (atomic, retain) NSString *Cookie;
@property (atomic, retain) NSString *LiXianURL;
@property (atomic, retain) NSString *TaskTypeString;
@property (atomic, retain) NSString *CID;
@property (atomic, retain) NSString *TimeLeft;
@property (atomic, retain) TaskModel *FatherTaskModel;
@property (atomic, retain) DownloadOperation *download_operation;
@property (atomic) BOOL StartAllDownloadNow;
-(void)start_download;

@end
