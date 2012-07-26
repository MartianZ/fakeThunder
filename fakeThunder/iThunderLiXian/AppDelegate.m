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
    python_task = [[NSTask alloc] init];
    [python_task setLaunchPath:@"/usr/bin/python"];
    
    NSString *resourcesPath = [[NSBundle mainBundle] resourcePath];    
    [python_task setArguments:[NSArray arrayWithObject:[NSString stringWithFormat:@"%@/XunleiAPI/api_mini.py", resourcesPath]]];
    [python_task launch];
    NSDockTile *tile = [[NSApplication sharedApplication] dockTile];
    [tile setBadgeLabel:@"Loading..."];
    usleep(1500000); //等待Python服务开启完全
    [tile setBadgeLabel:@""];
    
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];

    
    
    main_view = [[MainView alloc] initWithWindowNibName:@"MainView"];
    [main_view showWindow:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSString *check_update = [RequestSender sendRequest:@"http://api.4321.la/analytics-thunder.php?ver=20120725"];
        dispatch_async( dispatch_get_main_queue(), ^{
            if ([check_update hasPrefix:@"Update"]) {
                [[NSAlert alertWithMessageText:@"更新" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"软件检测到新版本的发布，请从软件中运行“自动更新”以更新软件。"] runModal];
            }
        });
    });
    
    /*广告～*/
    
    NSUserDefaults *user_default = [NSUserDefaults standardUserDefaults];
    NSInteger s = [user_default integerForKey:@UD_FIRST_STARTUP];
    if (s < 5) {
        [user_default setInteger:s+1 forKey:@UD_FIRST_STARTUP];
    } else if (s == 5)
    {
        [user_default setInteger:6 forKey:@UD_FIRST_STARTUP];
        [[NSAlert alertWithMessageText:@"捐赠作者" defaultButton:@"我知道了" alternateButton:nil otherButton:nil informativeTextWithFormat:@"fakeThunder是一款开源、免费软件，仍有很大的开发空间。非常高兴能够看到fakeThunder能够帮助到您，如果您喜欢这款软件，请考虑捐赠作者以支持后续的开发和维护费用。具体捐赠方式可查看软件偏好设置 - 高级。\n\n感谢您的支持，本对话框不会再次出现。"] runModal];
    }
}





- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSString* url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    url = [url stringByReplacingOccurrencesOfString:@"fakethunder://" withString:@""];
    NSLog(@"%@", url);
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
    [python_task terminate];
    
    //KILLALL ARIA2C
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/killall"];
    [task setArguments:[NSArray arrayWithObject:@"aria2c"]];
    [task launch];
    [task waitUntilExit];
}
@end
