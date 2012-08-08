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
    NSString *TaskTitle;
    NSString *FatherTitle;
    NSString *TaskSizeDescription;
    NSString *TaskLiXianProcess;
    NSString *TaskID;
    NSImage *TaskType;
    NSUInteger TaskSize;
    NSUInteger TaskDownloadedSize; //只有BT任务用来记录，其他时候忽略这个
    NSString *Cookie;
    BOOL Indeterminate;
    NSInteger ProgressValue;    
    NSString *LiXianURL;

    NSString *TaskTypeString;
    NSString *CID;
    NSString *ButtonTitle;
    TaskModel *FatherTaskModel;
    
    BOOL ButtonEnabled;
    
    DownloadOperation *download_operation;
    BOOL StartAllDownloadNow;
    
    NSString *TimeLeft;
    @public
    BOOL NeedToStopNow;
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
