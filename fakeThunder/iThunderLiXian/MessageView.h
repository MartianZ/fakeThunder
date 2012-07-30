//
//  MessageView.h
//  fakeThunder
//
//  Created by Martian on 12-7-30.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TasksView.h"

@class TasksView;
@interface MessageView : NSViewController {
    IBOutlet NSTextField *message_label;
    IBOutlet NSProgressIndicator *message_progress;
    TasksView *tasks_view;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil TasksView:(TasksView *)tasksView;
-(void) showMessage:(NSString *)message;
-(void) hideMessage;


@end
