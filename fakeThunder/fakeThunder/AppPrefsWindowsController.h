//
//  AppPrefsWindowsController.h
//  fakeThunder
//
//  Created by Martian Z on 13-10-22.
//  Copyright (c) 2013年 MartianZ. All rights reserved.
//

#import "DBPrefsWindowController.h"

@interface AppPrefsWindowsController : DBPrefsWindowController <NSWindowDelegate> {
    
    IBOutlet NSView *generalPreferenceView;
    IBOutlet NSView *bandwidthPreferenceView;
    
}

@end
