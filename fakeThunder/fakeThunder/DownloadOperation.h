//
//  DownloadOperation.h
//  fakeThunder
//
//  Created by Martian Z on 13-10-19.
//  Copyright (c) 2013年 MartianZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskEntity.h"

@class TaskEntity;

@interface DownloadOperation : NSOperation {
    TaskEntity *entity;
    BOOL _isFinish;

}

-(id)initWithTaskEntity:(TaskEntity *)task;


@end
