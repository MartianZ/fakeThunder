//
//  TasksView.h
//  fakeThunder
//
//  Created by Martian on 12-7-23.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RequestSender.h"
#import "TaskModel.h"
#import "MessageView.h"

@class MessageView;
@interface TasksView : NSViewController {
    IBOutlet NSArrayController *array_controller;

    IBOutlet NSView *collection_view;
    IBOutlet NSBox *collection_view_box;
    IBOutlet NSCollectionView *collection;
    
    IBOutlet NSMenu *task_menu;
    IBOutlet NSButton *task_more_button;
    
    IBOutlet NSImageCell *nav_image;
    IBOutlet NSTextField *nav_label;
    IBOutlet NSButton *nav_button;

    NSOperationQueue *operation_download_queue;
    NSMutableArray *mutable_array;
    NSMutableDictionary *bt_file_list_mutable_dict;
    
    NSString *_hash;
    NSString *_cookie;
    
    MessageView *message_view;
}

@property (atomic, retain) NSString *hash;
@property (atomic, retain) NSString *cookie;

- (void)thread_get_task_list:(NSInteger)page_num;
- (BOOL)thread_add_task:(NSString *)task_url;
- (BOOL)thread_add_BT_task:(NSDictionary *)infoDict filePath: (NSString*)url;;
- (NSDictionary*)thread_get_torrent_file_list:(NSString *)file_path;
- (void)clear_task_list;
- (void)thread_refresh;

@end
