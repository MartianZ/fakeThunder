//
//  AppPrefsWindowsController.m
//  fakeThunder
//
//  Created by Martian Z on 13-10-22.
//  Copyright (c) 2013年 MartianZ. All rights reserved.
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
