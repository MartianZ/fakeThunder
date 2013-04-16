//
//  TasksView.m
//  fakeThunder
//
//  Created by Martian on 12-7-23.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "TasksView.h"

@interface TasksView ()

@end

@implementation TasksView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
        _hash = [[NSString alloc] init];
        
        //--------------------------------------------------------------
        //      mutable_array：用来保存任务列表，查看BT任务文件内容后快速返回
        //--------------------------------------------------------------
        mutable_array = [[NSMutableArray alloc] init];
        bt_file_list_mutable_dict = [[NSMutableDictionary alloc] init];
        
        operation_download_queue = [[NSOperationQueue alloc] init];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults integerForKey:@UD_MAX_TASKS] < 1) {
            [defaults setInteger:1 forKey:@UD_MAX_TASKS];
        }
        [operation_download_queue setMaxConcurrentOperationCount:[defaults integerForKey:@UD_MAX_TASKS]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(set_max_tasks) name:@UD_MAX_TASKS object:nil];
        
        message_view = [[MessageView alloc] initWithNibName:@"MessageView" bundle:[NSBundle bundleForClass:[self class]] TasksView:self];
        
        [collection setValue:@(0) forKey:@"_animationDuration"];

    }
    return self;
}

//--------------------------------------------------------------
//      监视软件偏好设置中的最大下载任务数的更改
//--------------------------------------------------------------
-(void)set_max_tasks
{
    NSLog(@"CHANGE MAX TASKS");
    [operation_download_queue setMaxConcurrentOperationCount:[[NSUserDefaults standardUserDefaults] integerForKey:@UD_MAX_TASKS]];
    
}

//--------------------------------------------------------------
//      线程：添加任务
//--------------------------------------------------------------
-(BOOL)thread_add_task:(NSString *)task_url
{
    
    NSString *encodedValue = (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(nil,(CFStringRef)task_url, nil,(CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    
    NSString *request_url = @"http://127.0.0.1:9999/add_task";
    
    NSString *request_data = [NSString stringWithFormat:@"hash=%@&url=%@", self.hash, encodedValue];
    
    NSString *requestResult = [RequestSender postRequest:request_url withBody:request_data];
    
    
    if ([requestResult isEqualToString:@"Success"]) {
        //添加任务成功
        /*[array_controller removeObjects:[array_controller arrangedObjects]];
        [self thread_get_task_list:0]; */ //这样会导致前面的下载进度丢失
        dispatch_async( dispatch_get_main_queue(), ^{
            [self mainthread_add_task_to_list:[self thread_get_first_task]];
        });
        
        return YES;
    } else {
        return NO;
    }
}



//--------------------------------------------------------------
//      线程：刷新任务列表
//--------------------------------------------------------------
- (void)thread_refresh
{
    
    if (!nav_button.isHidden) {
        return;
    }
    NSString *requestResult = [RequestSender sendRequest:[NSString stringWithFormat:@"http://127.0.0.1:9999/%@/get_task_list/20/0",self.hash]];
    
    if ([requestResult isEqualToString:@"Fail"])
    {
        return;
    }
    
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[requestResult dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
    
    NSLog(@"%@",[jsonArray objectAtIndex:0]);
    
    for (unsigned long i = 0; (i <  20) && (i < [jsonArray count]); i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[jsonArray objectAtIndex:i]];
        [self performSelectorOnMainThread:@selector(mainthread_add_task_to_list:) withObject:dict waitUntilDone:YES];
    }
}


//--------------------------------------------------------------
//      线程：获取任务列表，并自动添加到主界面
//--------------------------------------------------------------
- (void)thread_get_task_list:(NSInteger)page_num
{
    
    if (page_num == 0 && [[array_controller arrangedObjects] count] > 0) {
        return;
    }
    
    NSString *requestResult = [RequestSender sendRequest:[NSString stringWithFormat:@"http://127.0.0.1:9999/%@/get_task_list/%lu/0",self.hash, (page_num+1) * 20]];
        
    if ([requestResult isEqualToString:@"Fail"])
    {
        return;
    }
    
    NSLog(@"%@", [requestResult dataUsingEncoding:NSUTF8StringEncoding]);
    
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[requestResult dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
    
    NSLog(@"%@",[jsonArray objectAtIndex:0]);
    
    for (unsigned long i = page_num * 20; (i < (page_num + 1) * 20) && (i < [jsonArray count]); i++) {
        [self performSelectorOnMainThread:@selector(mainthread_add_task_to_list:) withObject:[jsonArray objectAtIndex:i] waitUntilDone:YES];
    }
    
    
}

//--------------------------------------------------------------
//      线程：获取第一个任务
//--------------------------------------------------------------
- (NSDictionary *)thread_get_first_task
{
    NSString *requestResult = [RequestSender sendRequest:[NSString stringWithFormat:@"http://127.0.0.1:9999/%@/get_task_list/1/0",self.hash]];
    
    if ([requestResult isEqualToString:@"Fail"])
    {
        return nil;
    }
    
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[requestResult dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
        
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[jsonArray objectAtIndex:0]];
    [dict setObject:@"1" forKey:@"AddToTop"];
    return dict;
    
}

//--------------------------------------------------------------
//      主线程：添加任务列表到ArrayController
//--------------------------------------------------------------
- (void)mainthread_add_task_to_list:(NSDictionary *)dict
{
    /*
     {
     cid = 4324E224D5A4A797363660885936A7D8D1BB328F;
     format = other;
     "lixian_url" = "";
     process = 100;
     size = 106950840;
     status = finished;
     "task_id" = 116965968392;
     "task_type" = bt;
     taskname = "[HSsub][\U671d\U304b\U3089\U305a\U3063\U3057\U308a\U00b7\U30df\U30eb\U30af\U30dd\U30c3\U30c8][01][704x396][H264_AAC].mkv";
     url = "bt://4324E224D5A4A797363660885936A7D8D1BB328F";
     }
     */
    TaskModel *task = [[TaskModel alloc] init];
    if ([dict objectForKey:@"dirtitle"]) {
        //BT子任务
        task.TaskTitle = [dict objectForKey:@"dirtitle"];
        task.FatherTitle = [dict objectForKey:@"fathertitle"];
        task.FatherTaskModel = [mutable_array objectAtIndex:[[dict objectForKey:@"fathertaskmodel"] unsignedLongValue]];
    } else {
        task.TaskTitle = [dict objectForKey:@"taskname"];
        task.FatherTitle = nil;
        task.FatherTaskModel = nil;
    }
        
    float task_size = [[dict objectForKey:@"size"] floatValue];
    float task_process = [[dict objectForKey:@"process"] floatValue];
    task.TaskSize = task_size; task.TaskDownloadedSize = 0;
    
    int i = 0;
    NSArray *size_scale = [NSArray arrayWithObjects:@"Bytes",@"KiB",@"MiB",@"GiB",@"TiB",@"PiB",@"EiB", nil];
    while (task_size > 1024) {
        i++;
        task_size = task_size / 1024;
    }
    
    task.TaskSizeDescription = [NSString stringWithFormat:@"%.2f%@",task_size,size_scale[i]];
    task.TaskLiXianProcess = [NSString stringWithFormat:@"离线下载进度：%.2f%%",task_process];
    
    
    if ([dict objectForKey:@"task_type"] && [[dict objectForKey:@"task_type"] isEqualToString:@"bt"]) {
        task.TaskType = [NSImage imageNamed:@"4"];
        task.TaskTypeString = @"bt";
    } else {
        if ([[dict objectForKey:@"format"] isEqualToString:@"movie"]) {
            task.TaskType = [NSImage imageNamed:@"6"];
            task.TaskTypeString = @"movie";
        } else {
            task.TaskType = [NSImage imageNamed:@"5"];
            task.TaskTypeString = @"other";
        }
        if ([[dict objectForKey:@"format"] isEqualToString:@"rar"])
        {
            task.TaskType = [NSImage imageNamed:@"9"];
        }
        
    }
        
    task.TaskID = [NSString stringWithFormat:@"%lu",[[dict objectForKey:@"task_id"] unsignedLongValue]];
    
    
    /*如果任务重复则不添加*/
    for (TaskModel* t in [array_controller arrangedObjects]) {
        if ([t.TaskID isEqualToString:task.TaskID]) {
            return;
        }
    }
    
    task.Indeterminate = YES;
    task.ProgressValue = 0;
    task.Cookie = [NSString stringWithFormat:@"Cookie:%@", self.cookie];
    task.LiXianURL = [dict objectForKey:@"lixian_url"];
    
    task.CID = [NSString stringWithString:[dict objectForKey:@"cid"]];
    task.ButtonTitle = @"开始本地下载";
    task.ButtonEnabled = YES;
    
    /*添加到顶部*/
    if ([dict objectForKey:@"AddToTop"]) {
        [array_controller insertObject:task atArrangedObjectIndex:0];
    } else {
        [array_controller addObject:task];
    }
    

    if (task.FatherTaskModel && task.FatherTaskModel.StartAllDownloadNow) {
        
        if ([task.TaskLiXianProcess hasSuffix:@"100.00%"])
        {
            task->_NeedToStopNow = NO;
            task.ButtonTitle = @"队列中...";
            DownloadOperation *download_operation = [[DownloadOperation alloc] initWithTaskModel:task];
            [operation_download_queue addOperation:download_operation];
            task.download_operation = download_operation;
        }
        
    }
    
}

//--------------------------------------------------------------
//      线程：加载BT任务内容
//--------------------------------------------------------------
-(void)thread_load_bt_file_list:(TaskModel *)t
{
    @autoreleasepool {
        [collection setHidden:YES];
        [mutable_array removeAllObjects];
        [collection setValue:@(0) forKey:@"_animationDuration"];
        for (TaskModel *tt in [array_controller arrangedObjects]) {
            [mutable_array addObject:tt];
        }
        
        [array_controller removeObjects:[array_controller arrangedObjects]];
        [nav_label setStringValue:@"加载中..."];
        [nav_label setToolTip:t.TaskID];
        [nav_image setImage:[NSImage imageNamed:@"nav-bt.png"]];
        
        
        if ([bt_file_list_mutable_dict objectForKey:t.TaskID]) {
            for (TaskModel *tt in [bt_file_list_mutable_dict objectForKey:t.TaskID]) {
                dispatch_async( dispatch_get_main_queue(), ^{
                    [array_controller addObject:tt];
                });
            }
            [nav_label setStringValue:t.TaskTitle];
        }
        else {
            
            NSString *file_list = [RequestSender sendRequest:[NSString stringWithFormat:@"http://127.0.0.1:9999/%@/get_bt_list/%@/%@",self.hash,t.TaskID,t.CID]];
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[file_list dataUsingEncoding:NSUTF8StringEncoding] options:    NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
            //sleep(1); //等待渐变动画结束，然后再继续
            [nav_label setStringValue:t.TaskTitle];
            for (NSDictionary *dict in jsonArray) {
                NSMutableDictionary *mutable_dict = [NSMutableDictionary dictionaryWithDictionary:dict];
                NSString *dirtitle = [NSString stringWithString:[dict objectForKey:@"dirtitle"]];
                dirtitle = [dirtitle stringByReplacingOccurrencesOfString:@"\\*" withString:@"/"];
                [mutable_dict setObject:dirtitle forKey:@"dirtitle"];
                [mutable_dict setObject:t.TaskTitle forKey:@"fathertitle"];
                [mutable_dict setObject:[NSNumber numberWithInteger:[mutable_array indexOfObject:t]] forKey:@"fathertaskmodel"];
                [self performSelectorOnMainThread:@selector(mainthread_add_task_to_list:) withObject:mutable_dict waitUntilDone:YES];
                
            }
        }
        [nav_button setHidden:NO];
        [collection setHidden:NO];

    }
    
    
}

//--------------------------------------------------------------
//      按钮单击：开始下载
//--------------------------------------------------------------
- (IBAction)button_start_download:(id)sender
{
    if (![sender isKindOfClass:[NSButton class]])
    {
        return;
    }
    NSButton *button = (NSButton *)sender;
    
    TaskModel *t;
    for (TaskModel *tt in [array_controller arrangedObjects]) {
        if ([tt.TaskID isEqualToString:[button toolTip]]) {
            t = tt;
            break;
        }
    }
    
    
    if ([t.ButtonTitle isEqualToString:@"开始本地下载"] || [t.ButtonTitle isEqualToString:@"继续下载"])
    {
        
        
        //下载文件
        if ([t.TaskTypeString isEqualToString:@"bt"]) { //BT任务，下载全部文件
            t.StartAllDownloadNow = YES;
            [NSThread detachNewThreadSelector:@selector(thread_load_bt_file_list:) toTarget:self withObject:t];
            return;
        }
        
        if (![t.TaskLiXianProcess hasSuffix:@"100.00%"])
        {
            [[NSAlert alertWithMessageText:@"无法下载任务" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"远端离线任务尚未下载完成，无法下载到本地，请等待完成后重试。"] runModal];
            
            return;
        }
        
        t->_NeedToStopNow = NO;
        //[t start_download:button]; 采用线程池
        //operation_download_queue
        t.ButtonTitle = @"队列中...";
        
        DownloadOperation *download_operation = [[DownloadOperation alloc] initWithTaskModel:t];
        [operation_download_queue addOperation:download_operation];
        t.download_operation = download_operation;
        
        return;
    }
    if ([t.ButtonTitle hasSuffix:@"Bs"]) {
        //暂停下载
        t->_NeedToStopNow = YES;
        return;
    }
    
    if ([t.ButtonTitle hasPrefix:@"队列中"]) {
        //取消队列
        [t.download_operation cancel];
        t.ButtonTitle = @"开始本地下载";
    }
    
    if ([t.ButtonTitle isEqualToString:@"完成下载"]) {
        NSString *save_path = [[NSUserDefaults standardUserDefaults] objectForKey:@UD_SAVE_PATH];
        if (!save_path || [save_path length] == 0) {
            save_path = @"~/Desktop";
        }
        
        save_path = [save_path stringByExpandingTildeInPath];
        /*
         if (!self.FatherTitle) {
         args = [NSArray arrayWithObjects:@"--file-allocation=none",@"-c",@"-s",max_thread_str,@"-x",max_thread_str,@"-d",save_path,@"--out",self.TaskTitle, @"--max-download-limit", max_speed_str,@"--header", self.Cookie, self.LiXianURL, nil];
         } else {
         args = [NSArray arrayWithObjects:@"--file-allocation=none",@"-c",@"-s", max_thread_str,@"-x", max_thread_str, @"-d",save_path,@"--out",[NSString stringWithFormat:@"%@/%@",self.FatherTitle,self.TaskTitle], @"--max-download-limit", max_speed_str, @"--header", self.Cookie, self.LiXianURL, nil];
         }
         */
        if (!t.FatherTitle) {

            [[NSWorkspace sharedWorkspace] selectFile:[NSString stringWithFormat:@"%@/%@",save_path, t.TaskTitle] inFileViewerRootedAtPath:@""];
        } else {
            [[NSWorkspace sharedWorkspace] selectFile:[NSString stringWithFormat:@"%@/%@/%@",save_path, t.FatherTitle,t.TaskTitle] inFileViewerRootedAtPath:@""];

        }
    }
    
}

//--------------------------------------------------------------
//      按钮单击：获取更多功能
//--------------------------------------------------------------
-(IBAction)task_button_more_click:(id)sender
{
    if (![sender isKindOfClass:[NSButton class]])
    {
        return;
    }
    
    NSButton *button = (NSButton *)sender;
    
    for (TaskModel *t in [array_controller arrangedObjects]) {
        if ([t.TaskID isEqualToString:[button toolTip]]) {
            
            for (NSMenuItem *menu_item in [task_menu itemArray]) {
                [menu_item setToolTip:[button toolTip]];
            }
            
            [[[task_menu itemArray] objectAtIndex:0] setHidden:YES];
            [[[task_menu itemArray] objectAtIndex:1] setHidden:YES];
            if ([t.TaskTypeString isEqualToString:@"bt"]) {
                //BT任务
                [[[task_menu itemArray] objectAtIndex:0] setHidden:NO];
            } else if ([t.TaskTypeString isEqualToString:@"movie"]) {
                [[[task_menu itemArray] objectAtIndex:1] setHidden:NO];
            }
            break;
        }
    }
    
    
    NSRect frame = [(NSButton *)sender frame];
    NSPoint menuOrigin = [[(NSButton *)sender superview] convertPoint:NSMakePoint(frame.origin.x, frame.origin.y) toView:nil];
    
    NSEvent *event =  [NSEvent mouseEventWithType:NSLeftMouseDown
                                         location:menuOrigin
                                    modifierFlags:NSLeftMouseDownMask
                                        timestamp:0
                                     windowNumber:[[(NSButton *)sender window] windowNumber]
                                          context:[[(NSButton *)sender window] graphicsContext]
                                      eventNumber:0
                                       clickCount:1
                                         pressure:1];
    [NSMenu popUpContextMenu:task_menu withEvent:event forView:(NSButton *)sender];
}



-(void)thread_cloud_play:(TaskModel *)t
{
    
    NSString *encodedValue = (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(nil,(CFStringRef)t.LiXianURL, nil,(CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    
    NSString *request_url = @"http://127.0.0.1:9999/vod_get_play_url";
    
    NSString *request_data = [NSString stringWithFormat:@"hash=%@&url=%@", self.hash, encodedValue];
    
    NSString *requestResult = [RequestSender postRequest:request_url withBody:request_data];
    
    
    NSLog(@"%@",requestResult);
    
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[requestResult dataUsingEncoding:NSUTF8StringEncoding] options:    NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
    
    
    NSArray *jsonArray;
    if ((jsonArray = [[jsonDict objectForKey:@"resp"] objectForKey:@"vodinfo_list"])) {
        if ([jsonArray count] < 1) {
            return;
        }
        /*
         
         {
         "has_subtitle" = "-1";
         "spec_id" = 357120;
         "vod_url" = "http://gdl.lixian.vip.xunlei.com/download?dt=16&g=46909C4152B16E34240CA2FAA3AACB603E7BC805&t=2&ui=32767&s=350443827&v_type=-1&scn=c4&n=08586C0FD0F6390000&p=1&xplaybackid=23833448-cb42-11e1-9add-782bcb3dd24d";
         }
         
         */
        
        NSString *play_url;
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@UD_VOD_PLAY_SHARPNESS] == 1) {
            play_url = [[jsonArray objectAtIndex:0] objectForKey:@"vod_url"]; //标清
        } else {
            play_url = [[jsonArray objectAtIndex:[jsonArray count] -1] objectForKey:@"vod_url"]; //高清
        }
        
        
        play_url = [play_url stringByReplacingOccurrencesOfString:@"&p=" withString:@"&"];
        NSString *play_url_2 = [play_url substringFromIndex:[play_url rangeOfString:@"&s"].location + 3];
        play_url_2 = [play_url_2 substringToIndex:[play_url_2 rangeOfString:@"&"].location];
        NSString *play_url_3 = [NSString stringWithFormat:@"%@&start=0&end=%@&p=1",play_url,play_url_2];
        NSLog(@"%@",play_url_3);
        
        NSString *user_id = [play_url_3 substringFromIndex:[play_url_3 rangeOfString:@"&ui="].location + 4];
        user_id = [user_id substringToIndex:[user_id rangeOfString:@"&"].location];
        NSLog(@"%@",user_id);
        
        /*
         open -a "MPlayerX.app" --args '-ExtraOptions' '"-cookies -cookies-file /cookies.txt"' '-url' 'http://gdl.lixian.vip.xunlei.com/download?dt=16&g=A05AD1F697495D81B9D147D647B69351D2654C03&t=2&ui=32767&s=143722770&v_type=-1&scn=c8&n=0E485299C7896A0B00&p=1&xplaybackid=ecb339a0-cb6d-11e1-8b97-782bcb3dd24d&start=0&end=143722770'
         
         open -a "MPlayerX.app" --args '-ExtraOptions' '"-cookies -cookies-file cookies.txt"' '-url' 'http://gdl.lixian.vip.xunlei.com/download?dt=16&2&g=84FE933D4B8F1F5825357A2ADC8D11E61613560C&ui=32767&v_type=-1&n=0&start=0&end=152321397'
         
         */
        
        //killall MPlayerX
        //为了设置额外的启动参数，这里必须重启一下MPlayerX，然后调用Open打开
        //感谢开发MPlayerX的朋友，竟然有提供额外的启动参数！OS X上最完美的播放器，没有之一
        
        NSString *cookie_path = [@"~/Desktop/.xunlei_cookie.txt" stringByExpandingTildeInPath];
        NSString *cookie_content = [NSString stringWithFormat:@".xunlei.com	TRUE	/	FALSE	16572792388	userid	%@", user_id];
        [cookie_content writeToFile:cookie_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        NSTask *task_kill = [[NSTask alloc] init];
        [task_kill setLaunchPath:@"/usr/bin/killall"];
        NSArray *args_kill = [NSArray arrayWithObjects:@"MPlayerX", nil];
        [task_kill setArguments:args_kill];
        [task_kill launch];
        [task_kill waitUntilExit];        
        
        
        
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/open"];
        NSArray *args = [NSArray arrayWithObjects:@"-a",@"MPlayerX.app",@"--args",@"-ExtraOptions",[NSString stringWithFormat:@"\"-cookies -cookies-file %@\"", cookie_path],@"-url",play_url_3,nil];
        [task setArguments:args];
        [task launch];
        [task waitUntilExit];
        
    } else {
        return;
    }
}



//--------------------------------------------------------------
//      菜单单击：云点播
//--------------------------------------------------------------
-(IBAction)menu_cloud_play:(id)sender
{
    @autoreleasepool {
        /*
        [[NSAlert alertWithMessageText:@"Under Development!" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"由于迅雷官方的调整，云点播功能暂时不可用。后续版本会提供支持。"] runModal];
        return;*/
        
        NSMenuItem *menu_item = (NSMenuItem *)sender;
        
        for (TaskModel *t in [array_controller arrangedObjects]) {
            if ([t.TaskID isEqualToString:[menu_item toolTip]]) {
                
                [NSThread detachNewThreadSelector:@selector(thread_cloud_play:) toTarget:self withObject:t];
                break;
            }
        }
    }
}

-(void)thread_delete_task:(TaskModel *)t
{
    NSString *request_url = [NSString stringWithFormat:@"http://127.0.0.1:9999/DeleteTask/%@/%@", self.hash, t.TaskID];
     
    NSString *requestResult = [RequestSender sendRequest:request_url];
    
    if ([requestResult isEqualToString:@"Success"]) {
        dispatch_async( dispatch_get_main_queue(), ^{
            [array_controller removeObject:t];
            [mutable_array removeObject:t];
        });
    } else {
        dispatch_async( dispatch_get_main_queue(), ^{
          [[NSAlert alertWithMessageText:@"抱歉，删除任务失败！" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"删除任务失败，请手动登录 http://lixian.xunlei.com 删除任务！"] runModal];  
        });
    }

}


//--------------------------------------------------------------
//      菜单单击：删除任务
//--------------------------------------------------------------
-(IBAction)menu_delete:(id)sender
{
    @autoreleasepool {
        /*[[NSAlert alertWithMessageText:@"Under Development!" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"由于迅雷官方的调整，分享功能暂时不可用。后续版本会提供支持。"] runModal];
        return;*/
        
        NSMenuItem *menu_item = (NSMenuItem *)sender;
        
        for (TaskModel *t in [array_controller arrangedObjects]) {
            if ([t.TaskID isEqualToString:[menu_item toolTip]]) {
                
                NSLog(@"%@ %@", t.TaskID, self.hash);
                
                [NSThread detachNewThreadSelector:@selector(thread_delete_task:) toTarget:self withObject:t];
                break;
            }
        }
    }
}

//--------------------------------------------------------------
//      按钮单击：返回起始任务列表
//--------------------------------------------------------------
-(IBAction)button_back_to_file_list:(id)sender
{
    [nav_button setHidden:YES];
    [nav_image setImage:nil];
    [nav_label setStringValue:@""];
    //备份BT文件列表
    if (![bt_file_list_mutable_dict objectForKey:[nav_label toolTip]]) {
        NSArray *bt_files = [[NSArray alloc] initWithArray:[array_controller arrangedObjects]];
        [bt_file_list_mutable_dict setObject:bt_files forKey:[nav_label toolTip]];
    }
    
    
    [array_controller removeObjects:[array_controller arrangedObjects]];
    [array_controller addObjects:mutable_array];
    [mutable_array removeAllObjects];

}

//--------------------------------------------------------------
//      清空列表
//--------------------------------------------------------------
-(void)clear_task_list
{
    [array_controller removeObjects:[array_controller arrangedObjects]];
    [mutable_array removeAllObjects];
}

//--------------------------------------------------------------
//      线程：获取BT种子文件列表
//--------------------------------------------------------------
-(NSDictionary*)thread_get_torrent_file_list:(NSString *)file_path
{
    NSString *encodedValue = (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(nil,(CFStringRef)file_path, nil,(CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    NSString *request_url = @"http://127.0.0.1:9999/get_torrent_file_list";
    NSString *request_data = [NSString stringWithFormat:@"hash=%@&url=%@", self.hash, encodedValue];
    NSString *requestResult = [RequestSender postRequest:request_url withBody:request_data];
    
    NSDictionary *infoDict = [NSJSONSerialization JSONObjectWithData:[requestResult dataUsingEncoding:NSUTF8StringEncoding] options:    NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
    
    return infoDict;
    
}


//--------------------------------------------------------------
//     线程: BT选择文件完成，确认添加文件
//--------------------------------------------------------------

- (BOOL)thread_add_BT_task:(NSDictionary *)infoDict filePath: (NSString*)url
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict options:NSJSONWritingPrettyPrinted error:&error];
    if (! jsonData) {
        NSLog(@"转换JSON错误: %@", error);
        return NO;
    } else {
        NSString* infoString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *encodedValue = (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(nil,(CFStringRef)infoString, nil,(CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
        NSString *request_url = @"http://127.0.0.1:9999/add_bt_task";
        NSString *request_data = [NSString stringWithFormat:@"hash=%@&info=%@&url=%@", self.hash, encodedValue, url];
        NSString *requestResult = [RequestSender postRequest:request_url withBody:request_data];
        
        if ([requestResult isEqualToString:@"Success"]) {
            //添加任务成功
            
            dispatch_async( dispatch_get_main_queue(), ^{
                [self mainthread_add_task_to_list:[self thread_get_first_task]];
            });
            return YES;
        } else {
            return NO;
        }}
}

//--------------------------------------------------------------
//      菜单单击：获取BT文件列表
//--------------------------------------------------------------
-(IBAction)menu_bt_show_file_list:(id)sender
{
    @autoreleasepool {
        NSMenuItem *menu_item = (NSMenuItem *)sender;
        
        for (TaskModel *t in [array_controller arrangedObjects]) {
            if ([t.TaskID isEqualToString:[menu_item toolTip]]) {
                
                [NSThread detachNewThreadSelector:@selector(thread_load_bt_file_list:) toTarget:self withObject:t];
                break;
            }
        }
    }
}
@end
