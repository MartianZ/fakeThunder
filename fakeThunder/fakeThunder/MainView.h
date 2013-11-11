//
//  MainView.h
//  fakeThunder
//
//  Created by Martian on 12-8-15.
//  Copyright (c) 2012年 MartianZ. All rights reserved.
//
/*
 Copyright (C) 2012-2014 MartianZ
 
 fakeThunder is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 fakeThunder is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#import <Cocoa/Cocoa.h>
#import "TasksView.h"
#import <TondarAPI/HYXunleiLixianAPI.h>
#import <TondarAPI/XunleiItemInfo.h>
#import "DropZoneView.h"
#import "TorrentView.h"
#import <Sparkle/SUUpdater.h>
#import "AppPrefsWindowsController.h"
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

    NSUserDefaults *userDefault;

    
}



@end
