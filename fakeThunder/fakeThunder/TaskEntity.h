//
//  TaskEntity.h
//  fakeThunder
//
//  Created by Martian Z on 13-10-18.
//  Copyright (c) 2013年 MartianZ. All rights reserved.
//
/*
 Copyright (C) 2012-2014 MartianZ
 
 fakeThunder is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 fakeThunder is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
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
@property (retain) NSString *taskDcid;
@property (retain) NSOperation *downloadOperaion;
@property (retain) NSString *taskFatherTitle;

@property BOOL needToStop;

+ (TaskEntity *)entityForID:(NSString *)taskID;
- (void)performDownload;
- (void)performDownloadWithThread;

@property(assign) id <TaskDelegate> delegate;
@end

@protocol TaskDelegate <NSObject>

@optional

- (void)taskRowNeedUpdate:(NSString *)taskID;

@end


@interface TaskLoaderEntity : TaskEntity;

@property(retain) NSString *loadingProgress;

+ (TaskLoaderEntity *)entityNew;

@end