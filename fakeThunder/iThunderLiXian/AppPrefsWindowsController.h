//
//  AppPrefsWindowsController.h
//  fakeThunder
//
//  Created by Martian on 12-7-22.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBPrefsWindowController.h"

@interface AppPrefsWindowsController : DBPrefsWindowController <NSWindowDelegate> {
    IBOutlet NSView *generalPreferenceView;
    IBOutlet NSView *advancedPreferenceView;
    
    @public
    NSOperationQueue *operation_download_queue;
}

@end
