//
//  MainView.m
//  fakeThunder
//
//  Created by Martian on 12-8-15.
//  Copyright (c) 2012年 MartianZ. All rights reserved.
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
        NSLog(@"MainView Init");
        TondarAPI = [[HYXunleiLixianAPI alloc] init];
        [TondarAPI logOut];
        
    }
    
    return self;
}

- (void)windowDidLoad
{
    if ([SSKeychain passwordForService:@"fakeThunder" account:@"username"]
        && [[SSKeychain passwordForService:@"fakeThunder" account:@"username"] length] > 0) {
        [loginUsername setStringValue:[SSKeychain passwordForService:@"fakeThunder" account:@"username"]];
        [loginPassword setStringValue:[SSKeychain passwordForService:@"fakeThunder" account:@"password"]];
        
        [NSApp beginSheet:loginWindow modalForWindow:self.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
        
        [self loginButtonOk:loginButtonOK];

    }
    
    tasksView = [[TasksView alloc] initWithNibName:@"TasksView" bundle:[NSBundle bundleForClass:[self class]]];

    [super windowDidLoad];
    
    [self.window.contentView addSubview:tasksView.view];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

- (IBAction)startDownloadSelectedTask:(id)sender {
    [tasksView downloadSelectedTask];
}


- (IBAction)stopDownloadSelectedTask:(id)sender {
    [tasksView stopDownloadSelectedTask];
}


- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
    [loginWindow close];
    [addTaskWindow close];
    //[logout_window close];
    //[add_task_window close];
}

- (IBAction)toolBarLogin:(id)sender
{
    if ([[toobarItemLogin label] isEqualToString:@"Sign in"])
    {
        
        [NSApp beginSheet:loginWindow modalForWindow:self.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
        
        if ([SSKeychain passwordForService:@"fakeThunder" account:@"username"]) {
            [loginUsername setStringValue:[SSKeychain passwordForService:@"fakeThunder" account:@"username"]];
            [loginPassword setStringValue:[SSKeychain passwordForService:@"fakeThunder" account:@"password"]];

        }
        
    } else {
        
    }
}


- (IBAction)toolBarAddTask:(id)sender
{
    if ([[toobarItemLogin label] isEqualToString:@"Sign in"] && 0)
    {
        
        
    } else {
        [NSApp beginSheet:addTaskWindow modalForWindow:self.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
    }
}

//----------------------------------------
//   登录窗口 - 取消
//----------------------------------------
- (IBAction)loginButtonCancel:(id)sender
{
    [NSApp endSheet:loginWindow returnCode:NSCancelButton];
}


//----------------------------------------
//   登录窗口 - 确定
//----------------------------------------
- (IBAction)loginButtonOk:(id)sender
{
    NSString *username = [loginUsername stringValue];
    NSString *password = [loginPassword stringValue];
    if ([username length] < 3 || [password length] < 6) return;
    [loginProgress startAnimation:self];
    [(NSButton *)sender setEnabled:NO];
    
    [toobarItemLogin setEnabled:NO];
    [toobarItemLogin setLabel:@"Login..."];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{

        if (![loginWindow isVisible]) { [toobarItemLogin setEnabled:YES]; return; }
        if ([TondarAPI loginWithUsername:username Password:password]) {
            //LOGIN SUCCESS

            dispatch_async( dispatch_get_main_queue(), ^{
                [SSKeychain setPassword:username forService:@"fakeThunder" account:@"username"];
                [SSKeychain setPassword:password forService:@"fakeThunder" account:@"password"];
                
                [loginProgress stopAnimation:self];
                [NSApp endSheet:loginWindow returnCode:NSOKButton];
                [toobarItemLogin setLabel:@"Sign out"];
                
            });
            
            [tasksView startLoadFirstTaskPagsWithTondarAPI:TondarAPI];

        } else {
            dispatch_async( dispatch_get_main_queue(), ^{

                [loginProgress stopAnimation:self];
                [toobarItemLogin setLabel:@"Sign in"];
                [[NSAlert alertWithMessageText:@"Login failed" defaultButton:@"Okay" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Unable to sign in to Xunlei, please make sure your username & password is correct!"] runModal];
                [(NSButton *)sender setEnabled:YES];
                
            });
        }
    });
}

- (IBAction)addTaskNormalOK:(id)sender
{
    NSString *taskURL = [addTaskURL string];
    if ([taskURL length] < 5) {
        return;
    }
    [addTaskNormalButtonOK setEnabled:NO];
    [addTaskNormalProgress startAnimation:nil];
    NSArray *tasks = [taskURL componentsSeparatedByString:@"\n"];
    for (NSString *task in tasks) {
        if (!task || [task length] < 5) {
            continue;
        }
        
        if ([task hasPrefix:@"magnet"]) {
            [TondarAPI addMegnetTask:task];
        } else {
            [TondarAPI addNormalTask:task];
        }

    }
    
    [tasksView startCheckNewTasks];
    [addTaskNormalButtonOK setEnabled:YES];
    [NSApp endSheet:addTaskWindow returnCode:NSOKButton];
    [addTaskNormalProgress stopAnimation:nil];
}


- (IBAction)addTaskNormalCancel:(id)sender {
    [NSApp endSheet:addTaskWindow returnCode:NSCancelButton];

}
@end
