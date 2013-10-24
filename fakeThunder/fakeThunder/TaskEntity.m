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
@synthesize delegate = _delegate;


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


- (void)performDownloadWithThread {
    [NSThread detachNewThreadSelector:@selector(performDownload) toTarget:self withObject:nil];
}



- (void)performDownload {
    NSLog(@"Download Start: %@ %@ %@", self.title, self.cookies, self.taskDcid);
    self.status = @"Status: Loading...";
    self.needToStop = NO;
    if ([self.delegate respondsToSelector:@selector(taskRowNeedUpdate:)]) {
        [self.delegate taskRowNeedUpdate:self.taskDcid];
    }
    
    NSString *resourcesPath = [[NSBundle mainBundle] resourcePath];
    NSString *exePath = [NSString stringWithFormat:@"%@/aria2c",resourcesPath];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:exePath];
    
    
    NSString *savePath = [[NSUserDefaults standardUserDefaults] objectForKey:UD_SAVE_PATH];
    NSInteger maxSpeed = [[NSUserDefaults standardUserDefaults] integerForKey:UD_TASK_SPEED_LIMIT];
    if (!savePath || [savePath length] == 0) {
        savePath = @"~/Downloads";
    }
    
    if (maxSpeed < 0) {
        maxSpeed = 0;
    }
    
    savePath = [savePath stringByExpandingTildeInPath];
    NSString *maxSpeedStr = [NSString stringWithFormat:@"%ldK", maxSpeed];
    if ([self.taskType isEqualToString:@"BTSubtask"]) {
        savePath = [NSString stringWithFormat:@"%@/%@",savePath, self.taskFatherTitle];
    }
    
    
    
    NSArray *args = [NSArray arrayWithObjects:@"--file-allocation=none",@"-c",@"-s",@"10",@"-x",@"10",@"-d",savePath,@"--out",[NSString stringWithFormat:@"%@.!", self.title], @"--max-download-limit", maxSpeedStr,@"--header", self.cookies, self.liXianURL, nil];

        
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", savePath, self.title]]) {
        //Has same file
        self.status = @"Download complete! :D";
        self.progress = 100;
        
        NSUserNotification *un = [[NSUserNotification alloc] init];
        [un setTitle:@"fakeThunder - Download complete"];
        [un setInformativeText:self.title];
        [un setHasActionButton:NO];
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:un];
        
        if ([self.delegate respondsToSelector:@selector(taskRowNeedUpdate:)]) {
            [self.delegate taskRowNeedUpdate:self.taskDcid];
        }
        
        [task release];
        return;

    }

    [task setArguments:args];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardInput:[NSPipe pipe]];
    [task launch];
    
    char temp[1024], down[64], total[64], percentage[64], speed[64], lefttime[64];
    while (1) {
        sleep(1);
        NSData *data = [[[task standardOutput] fileHandleForReading] availableData];
        NSString *errs=[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        
        if ([errs rangeOfString:@"error occurred."].location != NSNotFound) {
            break;
        } else if ([errs rangeOfString:@"Exception caught"].location != NSNotFound) {
            continue;
        } else if ([errs rangeOfString:@"Download Progress Summary"].location != NSNotFound) {
            continue;
        } else if ([errs length] > 100) {
            continue;
        }
        
        errs = [errs stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        errs = [errs stringByReplacingOccurrencesOfString:@"/" withString:@" "];
        errs = [errs stringByReplacingOccurrencesOfString:@"(" withString:@" "];
        errs = [errs stringByReplacingOccurrencesOfString:@")" withString:@""];
        NSLog(@"%@", errs);
        memset(temp, 0, 1024*sizeof(char));
        strcpy(temp, [errs cStringUsingEncoding:NSASCIIStringEncoding]);
        sscanf(temp, "%*s SIZE:%s %s %s %*s SPD:%s ETA:%s]", down, total, percentage, speed, lefttime);
        
        
        NSString *timeLeft = [NSString stringWithFormat:@", Time left: %s", lefttime];

        if ([timeLeft hasSuffix:@"]"]) {
            timeLeft = [timeLeft stringByReplacingOccurrencesOfString:@"]" withString:@""];
        } else {
            timeLeft = @"";
        }
        NSString *speedStr = [NSString stringWithFormat:@"%s", speed];
        if ([errs rangeOfString:@"%"].location == NSNotFound) {
            speedStr = @"0Bs";
        }
        
        self.status = [NSString stringWithFormat:@"Speed: %@%@", [speedStr stringByReplacingOccurrencesOfString:@"]" withString:@""], timeLeft];
        self.progress = [[[NSString stringWithFormat:@"%s",percentage] stringByReplacingOccurrencesOfString:@"%" withString:@""] doubleValue];
        
        if ([self.delegate respondsToSelector:@selector(taskRowNeedUpdate:)]) {
            [self.delegate taskRowNeedUpdate:self.taskDcid];
        }
        
        if (![task isRunning]) {
            break;
        }
        
        if (self.needToStop) {
            [task terminate];
            self.status = @"Pausing...";
            break;
        }
    }

    while ([task isRunning]) {
        //DO NOTHING
        //等待程序彻底结束
    }
    
    switch ([task terminationStatus]) {
        case 0:
        {

            
            //下载完成
            self.status = @"Download complete! :D";
            self.progress = 100;
            
            NSUserNotification *un = [[NSUserNotification alloc] init];
            [un setTitle:@"fakeThunder - Download complete"];
            [un setInformativeText:self.title];
            [un setHasActionButton:NO];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:un];
            
            
            [[NSFileManager defaultManager] moveItemAtPath:[NSString stringWithFormat:@"%@/%@.!",savePath, self.title] toPath:[NSString stringWithFormat:@"%@/%@",savePath, self.title] error:nil];

            
            if ([self.delegate respondsToSelector:@selector(taskRowNeedUpdate:)]) {
                [self.delegate taskRowNeedUpdate:self.taskDcid];
            }
        }
            break;

        case 7:
        {
            //暂停下载
            self.status = @"Download paused..";
            
            if ([self.delegate respondsToSelector:@selector(taskRowNeedUpdate:)]) {
                [self.delegate taskRowNeedUpdate:self.taskDcid];
            }
            
            
        }
            break;
    }
    
    [task release];

}
@end

@implementation TaskLoaderEntity

+ (TaskLoaderEntity *)entityNew
{
    return [[TaskLoaderEntity alloc] init];
}

@end
