//
//  MainView.h
//  fakeThunder
//
//  Created by Martian on 12-7-23.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TasksView.h"
#import "RequestSender.h"
#import "AppPrefsWindowsController.h"
#import "MessageView.h"
@interface MainView : NSWindowController
{
    
    TasksView *tasks_view;
    MessageView *message_view;
    IBOutlet NSWindow *login_window;
    IBOutlet NSTextField *login_username;
    IBOutlet NSTextField *login_password;
    IBOutlet NSProgressIndicator *login_progress;
    IBOutlet NSButton *login_ok_button;
    IBOutlet NSWindow *add_task_window;
    IBOutlet NSProgressIndicator *add_task_progress;
    IBOutlet NSButton *add_task_ok_button;
    IBOutlet NSTextField *add_task_url;
    IBOutlet NSToolbarItem *toobaritem_login;
    IBOutlet NSToolbarItem *toobaritem_loadmore;
    IBOutlet NSToolbarItem *toobaritem_add_task;
    NSString *hash;
    NSString *cookie;
    
    int current_page;
    

}

@property (atomic, retain) NSString *hash;
@property (atomic, retain) NSString *cookie;

@end
