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
@interface MainView : NSWindowController {
    
    HYXunleiLixianAPI *TondarAPI;

    TasksView *tasksView;
    IBOutlet NSWindow *loginWindow;

    IBOutlet NSToolbarItem *toobarItemLogin;
    
    IBOutlet NSTextField *loginUsername;
    IBOutlet NSTextField *loginPassword;
    IBOutlet NSProgressIndicator *loginProgress;
    IBOutlet NSButton *loginButtonOK;
    IBOutlet NSButton *loginButtonCancel;
    
    
    
    //Add Task Window
    IBOutlet NSWindow *addTaskWindow;
    IBOutlet NSButton *addTaskNormalButtonOK;
    IBOutlet NSButton *addTaskNormalButtonCancel;
    IBOutlet NSTextView *addTaskURL;
    IBOutlet NSProgressIndicator *addTaskNormalProgress;

    
}



@end
