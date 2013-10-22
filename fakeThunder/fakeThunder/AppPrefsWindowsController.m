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

@end
