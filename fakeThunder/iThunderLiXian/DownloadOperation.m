//
//  DownloadOperation.m
//  iThunderLiXian
//
//  Created by Martian on 12-7-11.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "DownloadOperation.h"

@implementation DownloadOperation

-(id)initWithTaskModel:(TaskModel *)t
{
    if (self = [super init]) {
        task = t;
        t.ButtonTitle = @"队列中...";
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
        [task start_download];
        _isFinish = YES;
    }
}

-(BOOL)isFinished {
    return _isFinish;
}



@end
