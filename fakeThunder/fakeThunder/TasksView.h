//
//  TasksView.h
//  fakeThunder
//
//  Created by Martian on 12-8-15.
//  Copyright (c) 2012年 MartianZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TasksView.h"


@class ChildEditController;
@class SeparatorCell;

@interface TasksView : NSViewController {
    IBOutlet NSOutlineView		*myOutlineView;
    IBOutlet NSTreeController	*treeController;
    NSMutableArray				*contents;
    SeparatorCell				*separatorCell;	// the cell used to draw a separator line in the outline view
    NSImage						*folderImage;
	NSImage						*urlImage;
    BOOL						buildingOutlineView;
}


@end
