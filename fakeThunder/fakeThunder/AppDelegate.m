//
//  AppDelegate.m
//  fakeThunder
//
//  Created by Martian on 12-8-15.
//  Copyright (c) 2012年 MartianZ. All rights reserved.
//
/*
 Copyright (C) 2012-2014 MartianZ
 
 fakeThunder is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 fakeThunder is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#import "AppDelegate.h"

@implementation AppDelegate

+ (void)initialize {
	if ( self == [AppDelegate class] ) {
        //set default preference values
        NSDictionary *defaultValues = @{UD_PROMPT_BEFORE_QUITTING: @(NO),
                                        UD_PROMPT_BEFORE_REMOVING_ACTIVE_TASK: @(YES),
                                        UD_CHECK_CRASH_REPORT: @(YES),
                                        UD_HIDE_FILES_SMALLER_THAN: @(0),
                                        };
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
        [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultValues];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    mainView = [[MainView alloc] initWithWindowNibName:@"MainView"];
    [mainView showWindow:self];
    
    
    // shamelessly ask for donation (´・ω・｀)
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger s = [userDefault integerForKey:UD_FIRST_STARTUP];
    if (s < 5) {
        [userDefault setInteger:s+1 forKey:UD_FIRST_STARTUP];
    } else if (s == 5)
    {
        [userDefault setInteger:6 forKey:UD_FIRST_STARTUP];
        [[NSAlert alertWithMessageText:@"Make a donation" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"fakeThunder是一款开源、免费软件，仍有很大的开发空间。非常高兴能够看到fakeThunder能够帮助到您，如果您喜欢这款软件，请考虑捐赠作者以支持后续的开发和维护费用。具体捐赠方式可查看软件偏好设置 - 高级。\n\nfakeThunder is an open source, free software, there is still a lot of space for development. We are very pleased to see that our software can help you make your life better. If you like fakeThunder, consider donating us to support the future development! \n\n感谢您的支持，本对话框不会再次出现。\nThanks for your support, this dialog will not appear again."] runModal];
    }

    if ([userDefault boolForKey:UD_CHECK_CRASH_REPORT]) {
        [SFBCrashReporter checkForNewCrashes];
    }
    
    [NSThread detachNewThreadSelector:@selector(checkUpdate) toTarget:self withObject:nil];

}

- (NSString*)sendRequest:(NSString*)url
{
	NSString *urlString = url;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"GET"];
    NSString *contentType = [NSString stringWithFormat:@"text/xml"];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSHTTPURLResponse* urlResponse = nil;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:NULL];
	NSString *result = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
    //0x80000632 gb2312
	[request release];
    if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300)
		return result;
    return NULL;
}

-(void)checkUpdate
{
    NSString* serverResponse = [self sendRequest:@"http://martianlaboratory.com/analytics/fakethunder/20131112"];
    
    if (serverResponse && [serverResponse isEqualToString:@"Update"])
    {
        NSRunAlertPanel(NSLocalizedString(@"SoftwareUpdateTitle", nil), NSLocalizedString(@"SoftwareUpdate", nil), @"OK", nil, nil);
    }
}

- (void)sheetClosed:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    return [(NSApplication *)contextInfo replyToApplicationShouldTerminate:returnCode == NSAlertDefaultReturn];
}

-(NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:UD_PROMPT_BEFORE_QUITTING]) {
        NSBeginAlertSheet(@"Applicaion Quit",
                          @"OK",
                          @"Cancel",
                          nil,
                          mainView.window,
                          self,
                          @selector(sheetClosed:returnCode:contextInfo:),
                          NULL,
                          sender,
                          NSLocalizedString(@"Are you sure to quit fakeThunder?\nThis will terminate are your downloading task.", nil),
                          nil);
        return NSTerminateLater;
    } else {
        return NSTerminateNow;
    }
    
   
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    //KILLALL ARIA2C
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/killall"];
    [task setArguments:[NSArray arrayWithObject:@"aria2c"]];
    [task launch];
    [task waitUntilExit];
    [task release];
}

- (BOOL) applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if (!flag)
    {
		[mainView.window makeKeyAndOrderFront:self];
	}
	return YES;
}

-(IBAction)showPrefsWindow:(id)sender
{
    [[AppPrefsWindowsController sharedPrefsWindowController] showWindow:nil];
}


@end
