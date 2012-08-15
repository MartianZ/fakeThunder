//
//  AppDelegate.h
//  fakeThunder
//
//  Created by Martian on 12-8-15.
//  Copyright (c) 2012年 MartianZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    MainView *mainView;
}

@property (assign) IBOutlet NSWindow *window;

@end
