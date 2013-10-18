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
#import <TondarAPI/HYXunleiLixianAPI.h>
#import <TondarAPI/XunleiItemInfo.h>

@implementation TasksView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"TasksView Init");
        _tableContents = [NSMutableArray new];
        
        
        HYXunleiLixianAPI *TondarAPI = [[HYXunleiLixianAPI alloc] init];
        [TondarAPI logOut];
        if ([TondarAPI loginWithUsername:@"xunlei@binux.me" Password:@"loliluloli"]) {
            NSLog(@"LOGIN SUCCESS: %@", [TondarAPI userID]);
            
            NSArray *temp = [TondarAPI readAllTasks1];
            NSLog(@"%@", temp);
            for (XunleiItemInfo *task in temp) {
                NSLog(@"%@", task.taskid);
                TaskEntity *entity1 = [TaskEntity entityForID:task.taskid];
                [_tableContents addObject:entity1];
                entity1.title = task.name;
                entity1.subtitle = @"584MiB, Remote Server Progress: 100%";
                entity1.subtitle = [NSString stringWithFormat:@"%@, Remote Server Progress: %@%%", task.readableSize, task.downloadPercent];
                entity1.status = @"Status: Ready";
                entity1.taskType = [NSString stringWithFormat:@"%@", task.isBT];
                entity1.taskExt = [NSString stringWithFormat:@"%@", task.type];
                entity1.cookies = [NSString stringWithFormat:@"Cookie:gdriveid=%@;", [TondarAPI GDriveID]];
                entity1.liXianURL = [NSString stringWithFormat:@"%@", task.downloadURL];
                NSLog(@"%@", [TondarAPI GDriveID]);

            }
        }
        
        //[_tableViewMain setDoubleAction:@selector(tblvwDoubleClick:)];
        [_tableViewMain setTarget:self];
        [_tableViewMain setUsesAlternatingRowBackgroundColors:YES];
        [_tableViewMain setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
        [_tableViewMain reloadData];

 
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
    [cellView.progessIndicator setDoubleValue:entity.progress];

    
    if ([entity.taskType isEqualToString:@"0"]) {
        //BT
        [cellView.imageView setImage:[NSImage imageNamed:@"taskitem_bt"]];
    } else {
        [cellView.imageView setImage:[[NSWorkspace sharedWorkspace] iconForFileType: entity.taskExt]];
    }
    
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

- (void)downloadSelectedTask {
    
    if ([_tableViewMain selectedRow] >= 0) {
        
        TaskEntity *entity = [self _entityForRow:[_tableViewMain selectedRow]];
        
        entity.selectedRow = [_tableViewMain selectedRow];
        [entity setDelegate:self];
        [entity performDownloadWithThread];

    }
}



- (void)taskRowNeedUpdate:(NSString *)taskID
{
    
    for (int row = 0; row < [_tableViewMain numberOfRows]; row++ ) {
        if ([[NSString stringWithFormat:@"%@", [self _entityForRow:row].taskID] isEqualToString:taskID])
        {
            TableCellView *cellView = [_tableViewMain viewAtColumn:0 row:row makeIfNecessary:NO];
            cellView.statusTextField.stringValue = [self _entityForRow:row].status;
            [cellView.progessIndicator setDoubleValue:[self _entityForRow:row].progress];
            break;
        }
    }
    
}


@end
