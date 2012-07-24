//
//  TaskModel.m
//  iThunderLiXian
//
//  Created by Martian on 12-7-6.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "TaskModel.h"

@implementation TaskModel


-(void)dealloc {
    self.TaskID = nil;
    self.TaskType = nil;
    self.TaskLiXianProcess = nil;
    self.TaskSizeDescription = nil;
    self.TaskTitle = nil;
}

static NSString *osver()
{
    SInt32 versionMajor = 0;
    SInt32 versionMinor = 0;
    SInt32 versionBugFix = 0;
    Gestalt( gestaltSystemVersionMajor, &versionMajor );
    Gestalt( gestaltSystemVersionMinor, &versionMinor );
    Gestalt( gestaltSystemVersionBugFix, &versionBugFix );
    return [NSString stringWithFormat:@"%d.%d.%d", versionMajor, versionMinor, versionBugFix];
}


-(void)start_download
{
    NSLog(@"开始下载：TaskID：%@ TaskTitle：%@ Cookie: %@", self.TaskID, self.TaskTitle, self.Cookie);
    self.Indeterminate = NO;
    self.ProgressValue = 0;

    self.ButtonEnabled = NO;
    self.ButtonTitle = @"准备中...";
    
    //[NSThread detachNewThreadSelector:@selector(thread_aria2c) toTarget:self withObject:nil];
    
    [self thread_aria2c];
    /* Since we are gonna set up an queue for the Download thread, it is not necessary to start a thread here*/
    
}

-(void)thread_aria2c
{
    @autoreleasepool {
        NSUInteger last_download_size = 0;

        NSString *resourcesPath = [[NSBundle mainBundle] resourcePath];
        NSLog(@"%@",resourcesPath);
        NSString *exePath = [NSString stringWithFormat:@"%@/aria2c",resourcesPath];
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:exePath];
        NSArray *args;
        
        
        NSString *save_path = [[NSUserDefaults standardUserDefaults] objectForKey:@UD_SAVE_PATH];
        NSInteger max_thread = [[NSUserDefaults standardUserDefaults] integerForKey:@UD_MAX_THREADS];
        if (!save_path || [save_path length] == 0) {
            save_path = @"~/Desktop";
        }
        if (!max_thread || max_thread <= 0 || max_thread > 10) {
            max_thread = 10;
        }
        
        save_path = [save_path stringByExpandingTildeInPath];
        NSString *max_thread_str = [NSString stringWithFormat:@"%ld", max_thread];
        
        if (!self.FatherTitle) {
            args = [NSArray arrayWithObjects:@"--file-allocation=none",@"-c",@"-s",max_thread_str,@"-x",max_thread_str,@"-d",save_path,@"--out",self.TaskTitle, @"--header", self.Cookie, self.LiXianURL, nil];
        } else {
            args = [NSArray arrayWithObjects:@"--file-allocation=none",@"-c",@"-s", max_thread_str,@"-x", max_thread_str, @"-d",save_path,@"--out",[NSString stringWithFormat:@"%@/%@",self.FatherTitle,self.TaskTitle], @"--header", self.Cookie, self.LiXianURL, nil];
        }
        
        
        [task setArguments:args];
        
        NSPipe *pipe = [NSPipe pipe];
        [task setStandardOutput:pipe];
        [task setStandardInput:[NSPipe pipe]];
        [task launch];
        
        char temp[1024];
        char down[64], total[64], percentage[64], speed[64], lefttime[64];
        

        while (1) {
            sleep(1);
            NSData *data = [[[task standardOutput] fileHandleForReading] availableData];
            NSString *errs=[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"%@",errs);
            
            if ([errs rangeOfString:@"error occurred."].location != NSNotFound) {
                break;
            }
            if ([errs rangeOfString:@"Exception caught"].location != NSNotFound) {
                continue;
            }
            if ([errs rangeOfString:@"Download Progress Summary"].location != NSNotFound) {
                continue;
            }
            
            if ([errs length] > 100) {
                continue;
            }
            
            // 分析进度
            //[#1 SIZE:9.8MiB/27.5MiB(35%) CN:1 SPD:1.1MiBs ETA:15s]
            //[#1 SIZE:0B/0B CN:1 SPD:0Bs]
            
            
            
            errs = [errs stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            errs = [errs stringByReplacingOccurrencesOfString:@"/" withString:@" "];
            errs = [errs stringByReplacingOccurrencesOfString:@"(" withString:@" "];
            errs = [errs stringByReplacingOccurrencesOfString:@")" withString:@""];
            
            memset(temp,0,1024*sizeof(char));
            strcpy(temp,[errs cStringUsingEncoding:NSASCIIStringEncoding]);
            sscanf(temp,"%*s SIZE:%s %s %s %*s SPD:%s ETA:%s]", down, total, percentage, speed, lefttime);
            
            self.ButtonEnabled = YES;
            
            self.ButtonTitle = [NSString stringWithFormat:@"%s",speed];
            
            self.ProgressValue = [[[NSString stringWithFormat:@"%s",percentage] stringByReplacingOccurrencesOfString:@"%" withString:@""] integerValue];
            
            if ([errs rangeOfString:@"%"].location == NSNotFound) {
                self.ButtonTitle = @"0Bs";

            } else {
            
                if (self.FatherTaskModel) {
                    //处理BT主任务的进度
                    TaskModel *father_task = self.FatherTaskModel;
                    father_task.Indeterminate = NO;
                    if (father_task.TaskDownloadedSize >= last_download_size)
                    father_task.TaskDownloadedSize -= last_download_size;
                    last_download_size = self.ProgressValue / 100.00 * self.TaskSize;
                    father_task.TaskDownloadedSize += last_download_size;
                    father_task.ProgressValue = father_task.TaskDownloadedSize / (float)father_task.TaskSize * 100;
                
                }
            }
            if (![task isRunning]) {
                break;
            }
            if (NeedToStopNow) {
                [task terminate];
                self.ButtonEnabled = NO;
                self.ButtonTitle = @"暂停中...";
                break;
            }
            
        }
        while ([task isRunning]) {
            //DO NOTHING
            //等待程序彻底结束
        }
        
        //错误代码说明
        /*
         
         EXIT STATUS
         Because aria2 can handle multiple downloads at once, it encounters lots
         of errors in a session. aria2 returns the following exit status based
         on the last error encountered.
         
         0
         If all downloads were successful.
         
         1
         If an unknown error occurred.
         
         2
         If time out occurred.
         
         3
         If a resource was not found.
         
         4
         If aria2 saw the specfied number of "resource not found" error. See
         --max-file-not-found option).
         5
         If a download aborted because download speed was too slow. See
         --lowest-speed-limit option)
         
         6
         If network problem occurred.
         
         7
         If there were unfinished downloads. This error is only reported if
         all finished downloads were successful and there were unfinished
         downloads in a queue when aria2 exited by pressing Ctrl-C by an
         user or sending TERM or INT signal.
         
         8
         If remote server did not support resume when resume was required to
         complete download.
         
         9
         If there was not enough disk space available.
         
         10
         If piece length was different from one in .aria2 control file. See
         --allow-piece-length-change option.
         
         11
         If aria2 was downloading same file at that moment.
         
         12
         If aria2 was downloading same info hash torrent at that moment.
         
         13
         If file already existed. See --allow-overwrite option.
         
         14
         If renaming file failed. See --auto-file-renaming option.
         
         15
         If aria2 could not open existing file.
         
         16
         If aria2 could not create new file or truncate existing file.
         
         17
         If file I/O error occurred.
         
         18
         If aria2 could not create directory.
         
         19
         If name resolution failed.
         
         20
         If aria2 could not parse Metalink document.
         
         21
         If FTP command failed.
         
         22
         If HTTP response header was bad or unexpected.
         
         23
         If too many redirections occurred.
         
         24
         If HTTP authorization failed.
         
         25
         If aria2 could not parse bencoded file(usually .torrent file).
         
         26
         If .torrent file was corrupted or missing information that aria2
         needed.
         
         27
         If Magnet URI was bad.
         
         28
         If bad/unrecognized option was given or unexpected option argument
         was given.
         
         29
         If the remote server was unable to handle the request due to a
         temporary overloading or maintenance.
         
         30
         If aria2 could not parse JSON-RPC request.
         
         Note
         An error occurred in a finished download will not be reported as
         exit status.
         
         
         
         
         */
        
        
        switch ([task terminationStatus]) {

            case 0:
                //下载完成
                if (self.FatherTaskModel) {
                    //处理BT主任务的进度
                    TaskModel *father_task = self.FatherTaskModel;
                    father_task.Indeterminate = NO;
                    if (father_task.TaskDownloadedSize >= last_download_size)
                        father_task.TaskDownloadedSize -= last_download_size;
                    last_download_size = self.TaskSize;
                    father_task.TaskDownloadedSize += last_download_size;
                    father_task.ProgressValue = father_task.TaskDownloadedSize / (float)father_task.TaskSize * 100;
                    
                }
                
                self.ButtonEnabled = YES;
                self.ButtonTitle = @"完成下载";
                self.ProgressValue = 100;
                
                break;
            case 7:
                //暂停下载
                self.ButtonEnabled = YES;
                self.ButtonTitle = @"继续下载";

                break;
                
            default:
                break;
        }
        
    }


}

@end
