//
//  AppDelegate.m
//  iThunderLiXian
//
//  Created by Martian on 12-7-6.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    main_view = [[MainView alloc] initWithWindowNibName:@"MainView"];
    [main_view showWindow:self];
}

- (BOOL) applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if (!flag)
    {
		[main_view.window makeKeyAndOrderFront:self];
	}
	return YES;
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    //KILLALL ARIA2C
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/killall"];
    [task setArguments:[NSArray arrayWithObject:@"aria2c"]];
    [task launch];
}
@end
