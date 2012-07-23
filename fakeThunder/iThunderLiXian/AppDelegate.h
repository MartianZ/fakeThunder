//
//  AppDelegate.h
//  iThunderLiXian
//
//  Created by Martian on 12-7-6.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainView.h"
@interface AppDelegate : NSObject <NSApplicationDelegate> {
    
    //如果不在这里提前声明，会被ARC直接自动释放，真头疼
    MainView *main_view;

}

@end
