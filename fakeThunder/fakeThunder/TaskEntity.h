//
//  TaskEntity.h
//  fakeThunder
//
//  Created by Martian Z on 13-10-18.
//  Copyright (c) 2013年 MartianZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskEntity : NSObject {
@private
    NSString *_taskID;
}

- (id)initWithTaskID:(NSString *)taskID;


@property (retain) NSString *title;
@property (retain) NSString *subtitle;
@property (retain) NSString *status;
@property NSInteger progress;
@property (retain) NSString *taskID;


+ (TaskEntity *)entityForID:(NSString *)taskID;


@end
