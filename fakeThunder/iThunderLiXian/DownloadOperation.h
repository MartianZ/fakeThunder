//
//  DownloadOperation.h
//  iThunderLiXian
//
//  Created by Martian on 12-7-11.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskModel.h"

@class TaskModel;
@interface DownloadOperation : NSOperation {
    TaskModel *task;
    BOOL _isFinish;
}

-(id)initWithTaskModel:(TaskModel *)t;

@end
