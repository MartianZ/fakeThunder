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
        
        
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    tasks_view = [[TasksView alloc] initWithNibName:@"TasksView" bundle:[NSBundle bundleForClass:[self class]]];
    [self.window.contentView addSubview:tasks_view.view];
    
    self.hash = [[NSUserDefaults standardUserDefaults] objectForKey:@UD_LAST_LOGIN_HASH];
    self.cookie = [[NSUserDefaults standardUserDefaults] objectForKey:@UD_LAST_LOGIN_COOKIE];
    
    if (self.hash && [self.hash length] == 32) {
        //自动登录
        [toobaritem_login setEnabled:NO];
        [toobaritem_login setLabel:@"正在登录"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            tasks_view.hash = self.hash;
            tasks_view.cookie = self.cookie;
            current_page = 0;
            [tasks_view thread_get_task_list:0];
        });
        [toobaritem_login setLabel:@"注销"];
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
        [toobaritem_login setLabel:@"登录"];
        self.hash = nil;
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@UD_LAST_LOGIN_HASH];
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSString *requestResult = [RequestSender sendRequest:[NSString stringWithFormat:@"http://thunder.4321.la/initial/%@/%@",username, password]];
        if (![login_window isVisible]) { [toobaritem_login setEnabled:YES]; return; }
        if ([requestResult length] == 32) {
            //LOGIN SUCCESS
            self.hash = requestResult;
            self.cookie = [RequestSender sendRequest:[NSString stringWithFormat:@"http://thunder.4321.la/%@/get_cookie",self.hash]];
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
                [[NSAlert alertWithMessageText:@"登录失败" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"登录失败，请检查您的用户名和密码！"] runModal];
                [login_ok_button setEnabled:YES];
            });
        }
    });
}

//----------------------------------------
//   SHEET - 关闭
//----------------------------------------
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
    [login_window close];
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        if (![tasks_view thread_add_task:[add_task_url stringValue]]) {
            dispatch_async( dispatch_get_main_queue(), ^{
                [[NSAlert alertWithMessageText:@"添加任务失败" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"添加任务失败，请确定您的地址正确无误后重试。"] runModal];
                [add_task_ok_button setEnabled:YES];
            });
        } else {
            dispatch_async( dispatch_get_main_queue(), ^{
                [NSApp endSheet:add_task_window returnCode:NSCancelButton];
                
            });
        }
        [add_task_progress stopAnimation:self];
    });
}

//----------------------------------------
//   添加任务，取消
//----------------------------------------
-(IBAction)add_task_cancel_button_click:(id)sender
{
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
@end
