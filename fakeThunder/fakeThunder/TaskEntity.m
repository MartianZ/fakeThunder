//
//  TaskEntity.m
//  fakeThunder
//
//  Created by Martian Z on 13-10-18.
//  Copyright (c) 2013年 MartianZ. All rights reserved.
//

#import "TaskEntity.h"

@implementation TaskEntity

@synthesize taskID = _taskID;
@synthesize title;


+ (TaskEntity *)entityForID:(NSString *)taskID
{
    return [[TaskEntity alloc] initWithTaskID:taskID];
}


- (id)initWithTaskID:(NSString *)taskID {
    self = [super init];
    _taskID = [taskID retain];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    id result = [[[self class] alloc] initWithTaskID:self.taskID];
    return result;
}

- (void)dealloc {
    [_taskID release];
    [super dealloc];
}


- (BOOL)isSelectable {
    return YES;
}

@end
