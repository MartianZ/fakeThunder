//
//  MainView.m
//  fakeThunder
//
//  Created by Martian on 12-7-23.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "MainView.h"

@interface MainView ()

@end

@implementation MainView

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        current_page = 0;
        NSLog(@"%lu", [[NSUserDefaults standardUserDefaults] integerForKey:@UD_TASK_SPEED_LIMIT]);
        
    }
    
    return self;
}



- (void)windowDidLoad
{
    [super windowDidLoad];

    tasks_view = [[TasksView alloc] initWithNibName:@"TasksView" bundle:[NSBundle bundleForClass:[self class]]];
    message_view = [[MessageView alloc] initWithNibName:@"MessageView" bundle:[NSBundle bundleForClass:[self class]] TasksView:tasks_view];
    
    // tab视图控制
    
    // 左tab (种子拖放区域)
    NSView* leftTabView = [[torrent_tab_view tabViewItemAtIndex:0] view];
    drop_zone_view = [[DropZoneView alloc] init];
    drop_zone_view.delegate = self;
    
    [drop_zone_view setFrameOrigin:NSMakePoint(0, 0)];
    [drop_zone_view setFrameSize:leftTabView.frame.size];
    
    [leftTabView addSubview:drop_zone_view positioned:NSWindowBelow relativeTo:[leftTabView.subviews objectAtIndex:0]];

    
    // 右tab (种子文件列表)
    torrent_view = [[TorrentView alloc] initWithNibName:@"TorrentView" bundle:[NSBundle bundleForClass:[self class]]];
    
    // 右tab按钮
    [torrent_view.view addSubview:torrent_ok_button];
    [torrent_view.view addSubview:torrent_back_button];
    [torrent_view.view addSubview:torrent_add_cancel_button];
    torrent_add_cancel_button.frame = NSMakeRect(308, -7, 89, 32);
    torrent_ok_button.frame = NSMakeRect(397, -7, 89, 32);
    torrent_back_button.frame = NSMakeRect(172, -7, 89, 32);
    [[torrent_tab_view tabViewItemAtIndex:1] setView: torrent_view.view];
    
    [self.window.contentView addSubview:tasks_view.view];
    [self.window.contentView addSubview:message_view.view];

    self.hash = [[NSUserDefaults standardUserDefaults] objectForKey:@UD_LAST_LOGIN_HASH];
    self.cookie = [[NSUserDefaults standardUserDefaults] objectForKey:@UD_LAST_LOGIN_COOKIE];
    
    if (self.hash && [self.hash length] == 32) {
        //自动登录
        [toobaritem_login setEnabled:NO];
        [toobaritem_login setLabel:@"正在登录"];

        [toobaritem_login setLabel:@"注销"];
        
        [message_view showMessage:@"正在加载任务列表……"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            tasks_view.hash = self.hash;
            tasks_view.cookie = self.cookie;
            current_page = 0;
            [tasks_view thread_get_task_list:0];
            
            [message_view hideMessage];
        });
        
        
    }

    
}

//----------------------------------------
//   标题栏 / 登录、注销
//----------------------------------------
- (IBAction)toolbar_Login:(id)sender
{
    if ([[toobaritem_login label] isEqualToString:@"登录"])
    {
        [login_ok_button setEnabled:YES];
        [NSApp beginSheet:login_window modalForWindow:self.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
        
    } else {
        [NSApp beginSheet:logout_window modalForWindow:self.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
    }
}

//----------------------------------------
//   登录窗口 - 取消
//----------------------------------------
- (IBAction)login_cancel:(id)sender
{
    [NSApp endSheet:login_window returnCode:NSCancelButton];
}

//----------------------------------------
//   登录窗口 - 确定
//----------------------------------------
- (IBAction)login_button_ok:(id)sender
{
    NSString *username = [login_username stringValue];
    NSString *password = [login_password stringValue];
    if ([username length] < 3 || [password length] < 6) return;
    
    [login_progress startAnimation:self];
    [login_ok_button setEnabled:NO];
    
    [toobaritem_login setEnabled:NO];
    [toobaritem_login setLabel:@"正在登录"];
    
    NSString *encodedPassword = (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(nil,(CFStringRef)password, nil,(CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSString *requestResult = [RequestSender sendRequest:[NSString stringWithFormat:@"http://127.0.0.1:9999/initial/%@/%@",username, encodedPassword]];
        
        if (![login_window isVisible]) { [toobaritem_login setEnabled:YES]; return; }
        if ([requestResult length] == 32) {
            //LOGIN SUCCESS
            self.hash = requestResult;
            self.cookie = [RequestSender sendRequest:[NSString stringWithFormat:@"http://127.0.0.1:9999/%@/get_cookie",self.hash]];
            tasks_view.hash = self.hash;
            tasks_view.cookie = self.cookie;
            
            //自动登录
            [[NSUserDefaults standardUserDefaults] setObject:self.hash forKey:@UD_LAST_LOGIN_HASH];
            [[NSUserDefaults standardUserDefaults] setObject:self.cookie forKey:@UD_LAST_LOGIN_COOKIE];
            
            dispatch_async( dispatch_get_main_queue(), ^{
                [login_progress stopAnimation:self];
                [NSApp endSheet:login_window returnCode:NSOKButton];
                [toobaritem_login setLabel:@"注销"];
            });
            
            current_page = 0;
            [tasks_view thread_get_task_list:0];
            
        } else {
            dispatch_async( dispatch_get_main_queue(), ^{
                [login_progress stopAnimation:self];
                [toobaritem_login setLabel:@"登录"];
                [[NSAlert alertWithMessageText:@"登录失败" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"登录失败，请检查您的用户名和密码！并确保当前的fakeThunder为最新版本。如果仍然无法正常登录，请到官方网站发送反馈。"] runModal];
                [login_ok_button setEnabled:YES];
            });
        }
    });
}

//----------------------------------------
//   注销窗口 - 确认
//----------------------------------------
- (IBAction)logout_ok:(id)sender
{
    
    [toobaritem_login setLabel:@"登录"];
    self.hash = nil;
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@UD_LAST_LOGIN_HASH];
    self.cookie = nil;
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@UD_LAST_LOGIN_COOKIE];
    [tasks_view clear_task_list];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [NSApp endSheet:logout_window returnCode:NSCancelButton];
}

//----------------------------------------
//   注销窗口 - 取消
//----------------------------------------
- (IBAction)logout_cancel:(id)sender
{
    [NSApp endSheet:logout_window returnCode:NSCancelButton];
}

//----------------------------------------
//   SHEET - 关闭
//----------------------------------------
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
    [login_window close];
    [logout_window close];
    [add_task_window close];
}

//----------------------------------------
//   菜单单击 - 载入偏好设置窗口
//----------------------------------------
-(IBAction)showPrefsWindow:(id)sender
{
    [[AppPrefsWindowsController sharedPrefsWindowController] showWindow:nil];
}

//----------------------------------------
//   标题栏 - 添加任务
//----------------------------------------
-(IBAction)toolbar_add_task:(id)sender
{
    if (!self.hash || self.hash.length != 32) {
        [[NSAlert alertWithMessageText:@"无法添加任务" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"请先登录您的迅雷VIP账户，再添加任务！"] runModal];
        return;
    }
    
    [add_task_ok_button setEnabled:YES];
    [NSApp beginSheet:add_task_window modalForWindow:self.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

//----------------------------------------
//   添加任务，确定
//----------------------------------------
-(IBAction)add_task_ok_button_click:(id)sender
{
    
    if ([[add_task_url stringValue] length]<5) {
        return;
    }
    [add_task_ok_button setEnabled:NO];
    [add_task_progress startAnimation:self];
    
    NSString *taskStr = [[add_task_url stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *taskUrls = [taskStr componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        for (NSString *taskUrl in taskUrls) {
            if (![tasks_view thread_add_task:taskUrl]) {
                dispatch_async( dispatch_get_main_queue(), ^{
                    [[NSAlert alertWithMessageText:@"添加任务失败" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"添加任务失败，请确定您的地址正确无误后重试。Url:%@", taskUrl] runModal];
                    [add_task_ok_button setEnabled:YES];
                });
                break;
            } else {
                dispatch_async( dispatch_get_main_queue(), ^{
                    [NSApp endSheet:add_task_window returnCode:NSCancelButton];
                    
                });
            }
        }
        [add_task_url setStringValue:@""];
        [add_task_progress stopAnimation:self];
    });
}


//----------------------------------------
//   添加任务，取消
//----------------------------------------
-(IBAction)add_task_cancel_button_click:(id)sender
{
    [add_task_url setStringValue:@""];
    [self torrent_add_back_button:nil];
    [NSApp endSheet:add_task_window returnCode:NSCancelButton];
}

//----------------------------------------
//   标题栏 - 加载更多
//----------------------------------------
-(IBAction)toolbar_loadmore:(id)sender
{
    if (!self.hash || self.hash.length != 32) {
        [[NSAlert alertWithMessageText:@"无法加载更多任务" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"请先登录您的迅雷VIP账户！"] runModal];
        return;
    }
    
    
    current_page += 1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        [tasks_view thread_get_task_list:current_page];
    });
    
}

//----------------------------------------
//   标题栏 - 刷新
//----------------------------------------
-(IBAction)toolbar_refresh:(id)sender
{



    if (!self.hash || self.hash.length != 32) {
        [[NSAlert alertWithMessageText:@"无法加载任务" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"请先登录您的迅雷VIP账户！"] runModal];
        return;
    }
    
    if (message_view.view.isHidden) {
        [message_view showMessage:@"正在刷新任务……"];
        
        current_page = 0;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            [tasks_view thread_refresh];
            [message_view hideMessage];
        });
    }
    
    
}

//--------------------------------------------------------------
//     添加任务 － BT － 手动选择种子文件
//--------------------------------------------------------------

- (IBAction)add_torrent_file_button:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];//123
    
    [openDlg setCanChooseFiles:YES]; 
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setAllowedFileTypes:[NSArray arrayWithObject:@"torrent"]];
    
    if ( [openDlg runModal] == NSOKButton )
    {
        NSArray* files = [openDlg URLs];
        

        for(int i = 0; i < [files count]; i++ )
        {
            NSString* filePath = [[files objectAtIndex:i] path];
            [self upload_torrent_file:filePath];
        }
        
    }
}

//--------------------------------------------------------------
//     添加任务 － BT － 拖放框收到种子文件
//--------------------------------------------------------------
- (void)didRecivedTorrentFile: (NSString*)filePath
{
    [self upload_torrent_file:filePath];
}

//--------------------------------------------------------------
//     添加任务 - BT － 上传种子文件并返回文件列表
//--------------------------------------------------------------

- (void)upload_torrent_file: (NSString*)filePath
{
    [add_task_progress startAnimation:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSDictionary* info = [tasks_view thread_get_torrent_file_list:filePath];
        if (info.count != 0) {
            torrent_view.info = info;
            torrent_view.url = filePath;
            [torrent_tab_view selectTabViewItemAtIndex:1];
        } else {
            dispatch_async( dispatch_get_main_queue(), ^{
                [[NSAlert alertWithMessageText:@"添加任务失败" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"种子添加失败，请确认种子文件是否有效。"] runModal];
                [self torrent_add_back_button:nil];
            });
        }
        [add_task_progress stopAnimation:self];
    });
    [torrent_view.file_list_view reloadData];
}

//--------------------------------------------------------------
//     添加任务 － BT － 文件列表选择完成，确认添加任务
//--------------------------------------------------------------
- (IBAction)torrent_add_confirm_button:(id)sender
{
    [add_task_progress startAnimation:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        
        // 判断是否没有选择任何文件
        NSArray* fileList = [torrent_view.info objectForKey:@"filelist"];
        BOOL none_selected = YES;
        for (int i = 0; i < fileList.count; i++) {
            if ([[[fileList objectAtIndex:i] objectForKey:@"valid"] boolValue])
            {
                none_selected = NO;
            }
        }
        if (none_selected) {
            dispatch_async( dispatch_get_main_queue(), ^{
                [[NSAlert alertWithMessageText:@"添加任务失败" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"种子添加失败，请至少选择一个文件。"] runModal];
            });
            [add_task_progress stopAnimation:self];
            
        } else {
            
            if (![tasks_view thread_add_BT_task:torrent_view.info filePath:torrent_view.url])
            {
                dispatch_async( dispatch_get_main_queue(), ^{
                    [[NSAlert alertWithMessageText:@"添加任务失败" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"种子添加失败，请确认种子文件是否有效。"] runModal];                
                });
            } else {
                dispatch_async( dispatch_get_main_queue(), ^{
                    [NSApp endSheet:add_task_window returnCode:NSCancelButton];
                    [self torrent_add_back_button:nil];
                });
            }
            [add_task_progress stopAnimation:self];
        }
    });
}

//--------------------------------------------------------------
//     添加任务 － BT － 返回拖放框
//--------------------------------------------------------------
- (IBAction)torrent_add_back_button:(id)sender {
    torrent_view.info = nil;
    torrent_view.url = nil;
    [torrent_tab_view selectTabViewItemAtIndex:0];
}

//--------------------------------------------------------------
//     添加任务 － BT － 取消
//--------------------------------------------------------------
- (IBAction)torrent_add_cancel_button:(id)sender {
    [self torrent_add_back_button:nil];
    [NSApp endSheet:add_task_window returnCode:NSCancelButton];
}

//--------------------------------------------------------------
//     检查添加任务面板是否已打开
//--------------------------------------------------------------

- (BOOL)add_task_panel_is_open {
    if ([add_task_window isVisible]) {
        return YES;
    } else {
        return NO;
    }
}


@end
