//
//  TaskEntity.h
//  fakeThunder
//
//  Created by Martian Z on 13-10-18.
//  Copyright (c) 2013年 MartianZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TaskDelegate;

@interface TaskEntity : NSObject {
@private
    NSString *_taskID;
}

- (id)initWithTaskID:(NSString *)taskID;


@property (retain) NSString *title;
@property (retain) NSString *subtitle;
@property (retain) NSString *status;
@property double progress;
@property (retain) NSString *taskID;
@property (retain) NSString *taskType;
@property (retain) NSString *taskExt;
@property (retain) NSString *cookies;
@property (retain) NSString *liXianURL;
@property  NSInteger selectedRow;

+ (TaskEntity *)entityForID:(NSString *)taskID;
- (void)performDownload;
- (void)performDownloadWithThread;

@property(assign) id <TaskDelegate> delegate;
@end

@protocol TaskDelegate <NSObject>

@optional

- (void)taskRowNeedUpdate:(NSString *)taskID;

@end
