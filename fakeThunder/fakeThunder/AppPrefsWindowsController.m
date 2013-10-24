//
//  AppPrefsWindowsController.m
//  fakeThunder
//
//  Created by Martian Z on 13-10-22.
//  Copyright (c) 2013年 MartianZ. All rights reserved.
//

#import "AppPrefsWindowsController.h"


@implementation AppPrefsWindowsController

-(void)setupToolbar {
    [self addView:generalPreferenceView label:@"General" image:[NSImage imageNamed:@"General"]];
    [self addView:bandwidthPreferenceView label:@"Bandwidth" image:[NSImage imageNamed:@"Bandwidth"]];
    
    [self setCrossFade:YES];
	[self setShiftSlowsAnimation:YES];
    
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    [NSColor setIgnoresAlpha:NO];
}

-(IBAction)selectSavePath:(id)sender
{
    NSPopUpButton *popupButton = (NSPopUpButton *)sender;
    if ([popupButton indexOfSelectedItem] == 2) {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setCanChooseFiles:NO];
        [panel setCanChooseDirectories:YES];
        [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
            if (result == NSFileHandlingPanelOKButton) {
                NSURL *url = panel.directoryURL;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[url path] forKey:UD_SAVE_PATH];
                [[popupButton itemAtIndex:0] setTitle:[[url path] lastPathComponent]];
                [[popupButton itemAtIndex:0] setImage:[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)]];
                [defaults setObject:[[url path] lastPathComponent] forKey:UD_SAVE_PATH_DISPLAY];
                
                [defaults synchronize];
            }
        }];
        
        [popupButton selectItemAtIndex:0];
    }
}

- (IBAction) openNotificationSystemPrefs: (id) sender
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL fileURLWithPath:@"/System/Library/PreferencePanes/Notifications.prefPane"]];
}

-(IBAction)setMaxTasks:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:UD_MAX_TASKS object:self];
}

- (IBAction)donate:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://donate.martianz.cn"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}
@end
