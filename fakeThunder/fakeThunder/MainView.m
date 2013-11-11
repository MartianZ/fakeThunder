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
        NSLog(@"MainView Initing...");
        TondarAPI = [[HYXunleiLixianAPI alloc] init];
        [TondarAPI logOut];
        userDefault = [NSUserDefaults standardUserDefaults];
        
    }
    
    return self;
}

- (void)windowDidLoad {
    
    NSString *username = [userDefault stringForKey:@"username"];
    NSString *password = [userDefault stringForKey:@"password"];

    
    if (username && [username length] > 0) {
        [loginUsername setStringValue:username];
        [loginPassword setStringValue:password];
        
        [NSApp beginSheet:loginWindow modalForWindow:self.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
        
        [self loginButtonOk:nil];
        
    }
    
    tasksView = [[TasksView alloc] initWithNibName:@"TasksView" bundle:[NSBundle bundleForClass:[self class]] parentWindow:self.window];

    [super windowDidLoad];
    
    
    //left tab, torrent drag zone
    NSView* leftTabView = [[torrentTabView tabViewItemAtIndex:0] view];
    dropZoneView= [[DropZoneView alloc] init];
    dropZoneView.delegate = self;
    
    [dropZoneView setFrameOrigin:NSMakePoint(0, 0)];
    [dropZoneView setFrameSize:leftTabView.frame.size];
    
    [leftTabView addSubview:dropZoneView positioned:NSWindowBelow relativeTo:[leftTabView.subviews objectAtIndex:0]];
    
    //right tab, torrent file list
    torrentView = [[TorrentView alloc] initWithNibName:@"TorrentView" bundle:[NSBundle bundleForClass:[self class]]];
    torrentView.delegate = self;
    
    [[torrentTabView tabViewItemAtIndex:1] setView: torrentView.view];
    
    [self.window.contentView addSubview:tasksView.view];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)didRecivedTorrentFile:(NSString *)filePath {
    
    [self uploadTorrentFile:filePath];

}

- (void)uploadTorrentFile: (NSString*)filePath
{
    [torrentProgress startAnimation:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSDictionary* info = [TondarAPI fetchBTFileList:filePath];
        if (info && info.count != 0) {
            NSLog(@"%@", info);
            torrentView.info = info;
            torrentView.url = filePath;
            [torrentTabView selectTabViewItemAtIndex:1];
        } else {
            dispatch_async( dispatch_get_main_queue(), ^{
                [[NSAlert alertWithMessageText:NSLocalizedString(@"Failed", nil) defaultButton:@"Okay" alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Failed to get torrent file list, please make sure there is no same task in your task list.", nil)] runModal];
            });
        }
        [torrentProgress stopAnimation:self];

    });
}

- (void)didFinishFileSelect:(BOOL)isOkay {
    if (isOkay) {
        NSArray* fileList = [torrentView.info objectForKey:@"filelist"];
        NSMutableArray *fileToDownload = [[NSMutableArray alloc] init];
        for (int i = 0; i < fileList.count; i++) {
            NSDictionary* aFile = [fileList objectAtIndex:i];
            if ([[aFile valueForKey:@"valid"] boolValue]) {
                [fileToDownload addObject:[NSString stringWithFormat:@"%@", [aFile valueForKey:@"findex"]]];
            } 
        }
        
        NSLog(@"%@", fileToDownload);
        [TondarAPI addBTTask:torrentView.url selection:fileToDownload hasFetchedFileList:torrentView.info];
        [fileToDownload release];
        [tasksView startCheckNewTasks];

    }
    [NSApp endSheet:addTaskWindow returnCode:NSOKButton];

}


- (IBAction)selectTorrentFileButton:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
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
            [self uploadTorrentFile:filePath];
        }
        
    }
}


#define CHECK_LOGIN if (![[toobarItemLogin label] isEqualToString:NSLocalizedString(@"Sign out", nil)]) { [[NSAlert alertWithMessageText:@"Login required!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Please sign in to Xunlei first!", nil)] runModal];return; }

- (IBAction)startDownloadSelectedTask:(id)sender {
    CHECK_LOGIN
    [tasksView downloadSelectedTask];
}


- (IBAction)stopDownloadSelectedTask:(id)sender {
    CHECK_LOGIN
    [tasksView stopDownloadSelectedTask];
}


- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
    [loginWindow close];
    [addTaskWindow close];
    [logoutWindow close];
}

- (IBAction)toolBarLogin:(id)sender
{
    if ([[toobarItemLogin label] isEqualToString:NSLocalizedString(@"Sign in", nil)])
    {
        
        [NSApp beginSheet:loginWindow modalForWindow:self.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
        
    } else {
        [NSApp beginSheet:logoutWindow modalForWindow:self.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];

    }
}


- (IBAction)toolBarAddTask:(id)sender
{
    CHECK_LOGIN
    [torrentTabView selectFirstTabViewItem:nil];
    [NSApp beginSheet:addTaskWindow modalForWindow:self.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
  
}

- (IBAction)toolBarRefresh:(id)sender {

    CHECK_LOGIN
    [tasksView startCheckNewTasks];
}
//----------------------------------------
//   登录窗口 - 取消
//----------------------------------------
- (IBAction)loginButtonCancel:(id)sender
{
    [NSApp endSheet:loginWindow returnCode:NSCancelButton];
    if (![loginButtonOK isEnabled]) { //If login is in progress, we just restart the app.
        [self logoutWindowOK:sender];
    }
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
    [loginButtonOK setEnabled:NO];
    
    [toobarItemLogin setEnabled:NO];
    [toobarItemLogin setLabel:NSLocalizedString(@"Login...", nil)];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{

        if (![loginWindow isVisible]) { [toobarItemLogin setEnabled:YES]; return; }
        if ([TondarAPI loginWithUsername:username Password:password isPasswordEncode:sender == nil]) {
            //如果sender是nil代表是运行软件时获取加密后的密码自动登录，如果不为nil说明是用户按的按钮
            //LOGIN SUCCESS

            dispatch_async( dispatch_get_main_queue(), ^{
                //[SSKeychain setPassword:username forService:@"fakeThunder" account:@"username"];
                //[SSKeychain setPassword:password forService:@"fakeThunder" account:@"password"];
                
                if (sender) {
                    [userDefault setObject:username forKey:@"username"];
                    [userDefault setObject:[TondarAPI encodePasswordTwiceMD5:password] forKey:@"password"];
                }

                [loginProgress stopAnimation:self];
                [NSApp endSheet:loginWindow returnCode:NSOKButton];
                [toobarItemLogin setLabel:NSLocalizedString(@"Sign out", nil)];
                
            });
            
            [tasksView startLoadFirstTaskPagsWithTondarAPI:TondarAPI];

        } else {
            dispatch_async( dispatch_get_main_queue(), ^{

                [loginProgress stopAnimation:self];
                [toobarItemLogin setLabel:NSLocalizedString(@"Sign in", nil)];
                [[NSAlert alertWithMessageText:NSLocalizedString(@"Login failed", nil) defaultButton:@"OKay" alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Unable to sign in to Xunlei, please make sure your username & password is correct!", nil)] runModal];
                [loginButtonOK setEnabled:YES];
                
            });
        }
    });
    [loginProgress startAnimation:self];

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


- (IBAction)logoutWindowOK:(id)sender {
    /*
     [SSKeychain setPassword:username forService:@"fakeThunder" account:@"username"];
     [SSKeychain setPassword:password forService:@"fakeThunder" account:@"password"];
     */
    //[SSKeychain deletePasswordForService:@"fakeThunder" account:@"username"];
    //[SSKeychain deletePasswordForService:@"fakeThunder" account:@"password"];
    [userDefault removeObjectForKey:@"username"];
    [userDefault removeObjectForKey:@"password"];
    NSString *launcherSource = [[NSBundle bundleForClass:[SUUpdater class]]  pathForResource:@"relaunch" ofType:@""];
    NSString *launcherTarget = [NSTemporaryDirectory() stringByAppendingPathComponent:[launcherSource lastPathComponent]];
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
    NSString *processID = [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]];
    
    [[NSFileManager defaultManager] removeItemAtPath:launcherTarget error:NULL];
    [[NSFileManager defaultManager] copyItemAtPath:launcherSource toPath:launcherTarget error:NULL];
	
    [NSTask launchedTaskWithLaunchPath:launcherTarget arguments:[NSArray arrayWithObjects:appPath, processID, nil]];
    
    
    //KILLALL ARIA2C
    NSTask *taskKiller = [[NSTask alloc] init];
    [taskKiller setLaunchPath:@"/usr/bin/killall"];
    [taskKiller setArguments:[NSArray arrayWithObject:@"aria2c"]];
    [taskKiller launch];
    [taskKiller waitUntilExit];
    
    exit(0);

}

- (IBAction)logoutWindowCancel:(id)sender {
    [NSApp endSheet:logoutWindow returnCode:NSCancelButton];

}


@end
