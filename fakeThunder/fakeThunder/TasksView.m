//
//  TasksView.m
//  fakeThunder
//
//  Created by Martian on 12-8-15.
//  Copyright (c) 2012年 MartianZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TasksView.h"
#import "TaskEntity.h"
#import "TableCellView.h"
@implementation TasksView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"TasksView Init");
        _tableContents = [NSMutableArray new];
        
        
        
        TaskEntity *entity1 = [TaskEntity entityForID:@"1"];
        [_tableContents addObject:entity1];
        entity1.title = @"半泽直树.Hanzawa.Naoki.Ep07.Chi'Jap.HDTVrip.1024X";
        entity1.subtitle = @"584MiB, Remote Server Progress: 100%";
        entity1.status = @"Status: Ready";
        
        
        //[_tableViewMain setDoubleAction:@selector(tblvwDoubleClick:)];
        [_tableViewMain setTarget:self];
        [_tableViewMain reloadData];
        [_tableViewMain setUsesAlternatingRowBackgroundColors:YES];
        [_tableViewMain setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
    }
    
    return self;
}


-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _tableContents.count;
}


- (TaskEntity *)_entityForRow:(NSInteger)row {
    return (TaskEntity *)[_tableContents objectAtIndex:row];
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    TaskEntity *entity = [self _entityForRow:row];
    
    
    TableCellView *cellView = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    
    cellView.textField.stringValue = entity.title;
    cellView.subTitleTextField.stringValue = entity.subtitle;
    cellView.statusTextField.stringValue = entity.status;
    
    // Use KVO to observe for changes of the thumbnail image
    if (_observedVisibleItems == nil) {
        _observedVisibleItems = [NSMutableArray new];
    }
    if (![_observedVisibleItems containsObject:entity]) {
        [_observedVisibleItems addObject:entity];
    }
    
    // Size/hide things based on the row size
    //[cellView layoutViewsForSmallSize:_useSmallRowHeight animated:NO];
    
    return cellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 65;
}



@end
