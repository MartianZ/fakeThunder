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
        
    }
    
    return self;
}

- (void)windowDidLoad
{
    tasksView = [[TasksView alloc] initWithNibName:@"TasksView" bundle:[NSBundle bundleForClass:[self class]]];

    [super windowDidLoad];
    
    [self.window.contentView addSubview:tasksView.view];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

- (IBAction)startDownloadSelectedTask:(id)sender {
    [tasksView downloadSelectedTask];
}
@end
