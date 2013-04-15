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
#import "TorrentView.h"
#import "DropZoneView.h"
@interface MainView : NSWindowController <DropZoneDelegate>
{
    
    TasksView *tasks_view;
    MessageView *message_view;
    TorrentView *torrent_view;
    DropZoneView *drop_zone_view;
    IBOutlet NSWindow *login_window;
    IBOutlet NSTextField *login_username;
    IBOutlet NSTextField *login_password;
    IBOutlet NSProgressIndicator *login_progress;
    IBOutlet NSButton *login_ok_button;
    IBOutlet NSWindow *add_task_window;
    IBOutlet NSProgressIndicator *add_task_progress;
    IBOutlet NSButton *add_task_ok_button;
    IBOutlet NSTextField *add_task_url;
    IBOutlet NSWindow *logout_window;
    IBOutlet NSButton *logout_ok_button;
    IBOutlet NSToolbarItem *toobaritem_login;
    IBOutlet NSToolbarItem *toobaritem_loadmore;
    IBOutlet NSToolbarItem *toobaritem_add_task;
    IBOutlet NSToolbarItem *toobaritem_refresh;
    IBOutlet NSTabView *torrent_tab_view;
    IBOutlet NSButton *torrent_ok_button;
    IBOutlet NSButton *torrent_back_button;
    IBOutlet NSButton *torrent_add_cancel_button;
    IBOutlet NSButton *torrent_select_all_button;
    IBOutlet NSButton *torrent_negative_select_button;
    NSString *_hash;
    NSString *_cookie;
    
    int current_page;
    

}

@property (atomic, retain) NSString *hash;
@property (atomic, retain) NSString *cookie;


- (IBAction)toolbar_add_task:(id)sender;
- (IBAction)add_torrent_file_button:(id)sender;
- (void)didRecivedTorrentFile: (NSString*)filePath;
- (IBAction)torrent_add_confirm_button:(id)sender;
- (IBAction)torrent_add_back_button:(id)sender;
- (IBAction)torrent_add_cancel_button:(id)sender;
- (void)upload_torrent_file: (NSString*)filePath;
- (BOOL)add_task_panel_is_open;


@end
