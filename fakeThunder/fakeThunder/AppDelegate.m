//
//  AppDelegate.m
//  fakeThunder
//
//  Created by Martian on 12-8-15.
//  Copyright (c) 2012年 MartianZ. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    mainView = [[MainView alloc] initWithWindowNibName:@"MainView"];
    [mainView showWindow:self];
    
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    //KILLALL ARIA2C
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/killall"];
    [task setArguments:[NSArray arrayWithObject:@"aria2c"]];
    [task launch];
    [task waitUntilExit];
}

@end
