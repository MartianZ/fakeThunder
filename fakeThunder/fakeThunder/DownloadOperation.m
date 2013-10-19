//
//  DownloadOperation.m
//  fakeThunder
//
//  Created by Martian Z on 13-10-19.
//  Copyright (c) 2013年 MartianZ. All rights reserved.
//

#import "DownloadOperation.h"

@implementation DownloadOperation

- (id)initWithTaskEntity:(TaskEntity *)task {
    if (self = [super init]) {
        entity = task;
        _isFinish = NO;
    }
    return self;
}

-(void)start
{
    if (self.isCancelled) {
        _isFinish = YES;
    } else {
        _isFinish = NO;
        [entity performDownload];
        _isFinish = YES;
    }
}

-(BOOL)isFinished {
    return _isFinish;
}

@end
