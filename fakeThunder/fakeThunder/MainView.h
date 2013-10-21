//
//  MainView.h
//  fakeThunder
//
//  Created by Martian on 12-8-15.
//  Copyright (c) 2012年 MartianZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TasksView.h"
#import <TondarAPI/HYXunleiLixianAPI.h>
#import <TondarAPI/XunleiItemInfo.h>
#import "SSKeychain.h"
#import "DropZoneView.h"
#import "TorrentView.h"
#import <Sparkle/SUUpdater.h>

@interface MainView : NSWindowController<DropZoneDelegate, TorrentViewDelegate> {
    
    HYXunleiLixianAPI *TondarAPI;

    TasksView *tasksView;
    TorrentView *torrentView;

    IBOutlet NSWindow *loginWindow;
    IBOutlet NSWindow *logoutWindow;

    IBOutlet NSToolbarItem *toobarItemLogin;
    
    IBOutlet NSTextField *loginUsername;
    IBOutlet NSTextField *loginPassword;
    IBOutlet NSProgressIndicator *loginProgress;
    IBOutlet NSProgressIndicator *torrentProgress;

    IBOutlet NSButton *loginButtonOK;
    IBOutlet NSButton *loginButtonCancel;
    
    
    
    //Add Task Window
    IBOutlet NSWindow *addTaskWindow;
    IBOutlet NSButton *addTaskNormalButtonOK;
    IBOutlet NSButton *addTaskNormalButtonCancel;
    IBOutlet NSTextView *addTaskURL;
    IBOutlet NSProgressIndicator *addTaskNormalProgress;
    IBOutlet NSTabView *torrentTabView;
    DropZoneView *dropZoneView;


    
}



@end
