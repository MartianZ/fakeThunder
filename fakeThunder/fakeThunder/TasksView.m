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
        
        operationDownloadQueue = [[NSOperationQueue alloc] init];
        [operationDownloadQueue setMaxConcurrentOperationCount:3];

        

    }
    
    return self;
}



- (void)startLoadFirstTaskPagsWithTondarAPI:(HYXunleiLixianAPI*)api {
    TondarAPI = api;
    
    NSLog(@"LOGIN SUCCESS: %@", [TondarAPI userID]);
        
    NSArray *temp = [TondarAPI readAllTasks1];
    NSLog(@"%@", temp);
    
    for (XunleiItemInfo *task in temp) {
        TaskEntity *entity = [TaskEntity entityForID:task.taskid];
        
            
        [_tableContents addObject:entity];
        entity.title = task.name;
        entity.subtitle = @"584MiB, Remote Server Progress: 100%";
        entity.subtitle = [NSString stringWithFormat:@"%@, Remote Server Progress: %@%%", task.readableSize, task.downloadPercent];
        entity.status = @"Status: Ready";
        entity.taskType = [NSString stringWithFormat:@"%@", task.isBT];
        entity.taskExt = [NSString stringWithFormat:@"%@", task.type];
        entity.cookies = [NSString stringWithFormat:@"Cookie:gdriveid=%@;", [TondarAPI GDriveID]];
        entity.liXianURL = [NSString stringWithFormat:@"%@", task.downloadURL];
        entity.taskDcid = [NSString stringWithFormat:@"%@", task.dcid];
                    
    }
    
    _currentPage = 1;
    [_tableViewMain reloadData];
}

- (void)startCheckNewTasks {
    NSArray *temp = [TondarAPI readAllTasks1];
    for (XunleiItemInfo *task in temp) {
        
        BOOL hasSameTask = NO;
        for (TaskEntity *oldEntity in _tableContents) {
            if ([oldEntity.taskID isEqualToString:task.taskid]) {
                hasSameTask = YES;
                break;
            }
        }
        
        if (!hasSameTask) {
            TaskEntity *entity = [TaskEntity entityForID:task.taskid];
            
            
            [_tableContents insertObject:entity atIndex:0];
            entity.title = task.name;
            entity.subtitle = @"584MiB, Remote Server Progress: 100%";
            entity.subtitle = [NSString stringWithFormat:@"%@, Remote Server Progress: %@%%", task.readableSize, task.downloadPercent];
            entity.status = @"Status: Ready";
            entity.taskType = [NSString stringWithFormat:@"%@", task.isBT];
            entity.taskExt = [NSString stringWithFormat:@"%@", task.type];
            entity.cookies = [NSString stringWithFormat:@"Cookie:gdriveid=%@;", [TondarAPI GDriveID]];
            entity.liXianURL = [NSString stringWithFormat:@"%@", task.downloadURL];
            entity.taskDcid = [NSString stringWithFormat:@"%@", task.dcid];
            
        }
        
    }
    
    [_tableViewMain reloadData];

}

- (void)startLoadTaskWithPage:(NSUInteger)page {
    
    TaskLoaderEntity *loderEntity = [TaskLoaderEntity entityNew];
    [_tableContents addObject:loderEntity];
    [_tableViewMain reloadData];
    
    _isLoadingTask = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSArray *temp = [TondarAPI readTasksWithPage:page];
        [_tableContents removeObjectAtIndex:_tableContents.count - 1];
        [_tableViewMain reloadData];
        
        
        for (XunleiItemInfo *task in temp) {
            TaskEntity *entity = [TaskEntity entityForID:task.taskid];
            
            [_tableContents addObject:entity];
            entity.title = task.name;
            entity.subtitle = @"584MiB, Remote Server Progress: 100%";
            entity.subtitle = [NSString stringWithFormat:@"%@, Remote Server Progress: %@%%", task.readableSize, task.downloadPercent];
            entity.status = @"Status: Ready";
            entity.taskType = [NSString stringWithFormat:@"%@", task.isBT];
            entity.taskExt = [NSString stringWithFormat:@"%@", task.type];
            entity.cookies = [NSString stringWithFormat:@"Cookie:gdriveid=%@;", [TondarAPI GDriveID]];
            entity.liXianURL = [NSString stringWithFormat:@"%@", task.downloadURL];
            entity.taskDcid = [NSString stringWithFormat:@"%@", task.dcid];
            
        }
        
        _isLoadingTask = NO;

        
        [_tableViewMain reloadData];
    });

    
}

- (void)awakeFromNib {
    [_tableViewMain setDoubleAction:@selector(tblvwDoubleClick:)];
    [_tableViewMain setTarget:self];
    [_tableViewMain setUsesAlternatingRowBackgroundColors:YES];
    [_tableViewMain setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
    
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
    
    if (row == _tableContents.count - 1 && _isLoadingTask == NO) {
        [self startLoadTaskWithPage:++_currentPage];
    }
    
    if ([entity isKindOfClass:[TaskLoaderEntity class]])
    {
        
        TableCellView *cellView = [tableView makeViewWithIdentifier:@"LoadingCell" owner:self];
        [cellView.progessIndicator startAnimation:nil];
        [cellView.progessIndicator setHidden:NO];
        return cellView;
        
    } else {
    
    
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
        
        if (![entity.taskType isEqualToString:@"BTSubtask"]) {
            [cellView.removeButton setEnabled:YES];
        } else {
            [cellView.removeButton setEnabled:NO];
        }
    
    
        // Size/hide things based on the row size
        //[cellView layoutViewsForSmallSize:_useSmallRowHeight animated:NO];
    
        return cellView;
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 65;
}

- (void)downloadSelectedTask {
    
    if ([_tableViewMain selectedRow] >= 0) {
        NSUInteger index;
        for (index = [[_tableViewMain selectedRowIndexes] firstIndex];
             index != NSNotFound; index = [[_tableViewMain selectedRowIndexes] indexGreaterThanIndex: index])  {
            
            TaskEntity *entity = [self _entityForRow:index];
            entity.selectedRow = [_tableViewMain selectedRow];
            [entity setDelegate:self];
            if (![entity isKindOfClass:[TaskLoaderEntity class]] && ![entity.taskType isEqualToString:@"0"]) {
                //not BT task
                DownloadOperation *downloadOperation = [[DownloadOperation alloc] initWithTaskEntity:entity];
                [operationDownloadQueue addOperation:downloadOperation];
                entity.downloadOperaion = downloadOperation;
                entity.status = @"Status: Queuing...";
                TableCellView *cellView = [_tableViewMain viewAtColumn:0 row:index makeIfNecessary:NO];
                cellView.statusTextField.stringValue = entity.status;

            }
            
            
        }
        

    }
}

- (void)stopDownloadSelectedTask {
    
    if ([_tableViewMain selectedRow] >= 0) {
        NSUInteger index;
        for (index = [[_tableViewMain selectedRowIndexes] firstIndex];
             index != NSNotFound; index = [[_tableViewMain selectedRowIndexes] indexGreaterThanIndex: index])  {
            
            TaskEntity *entity = [self _entityForRow:index];
            entity.selectedRow = [_tableViewMain selectedRow];
            [entity setDelegate:self];
            if (![entity isKindOfClass:[TaskLoaderEntity class]] && ![entity.taskType isEqualToString:@"0"]) {
                //not BT task
                if ([entity.status hasSuffix:@"Queuing..."]) {
                    [entity.downloadOperaion cancel];
                    entity.status = @"Status: Ready";
                    TableCellView *cellView = [_tableViewMain viewAtColumn:0 row:index makeIfNecessary:NO];
                    cellView.statusTextField.stringValue = entity.status;
                } else {
                    entity.needToStop = YES;
                }
            }
            
            
        }
        
        
    }
}



- (void)taskRowNeedUpdate:(NSString *)taskID
{
    
    for (int row = 0; row < [_tableViewMain numberOfRows]; row++ ) {
        if ([[NSString stringWithFormat:@"%@", [self _entityForRow:row].taskDcid] isEqualToString:taskID])
        {
            [_tableViewMain beginUpdates];
            TableCellView *cellView = [_tableViewMain viewAtColumn:0 row:row makeIfNecessary:NO];
            cellView.statusTextField.stringValue = [self _entityForRow:row].status;
            [cellView.progessIndicator setDoubleValue:[self _entityForRow:row].progress];
            [_tableViewMain endUpdates];

            break;
        }
    }
    
}


- (IBAction)btnRemoveRowClick:(id)sender {
    NSInteger row = [_tableViewMain rowForView:sender];
    if (row != -1) {
        TaskEntity *entity = [self _entityForRow:row];
        
        [TondarAPI deleteSingleTaskByID:entity.taskID];
        if (entity.downloadOperaion) {
            entity.needToStop = YES;
            [entity.downloadOperaion cancel];
        }
        
        [_tableContents removeObjectAtIndex:row];
        [_tableViewMain removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationEffectFade];
        
        [entity release];
    }
}


- (IBAction)tblvwDoubleClick:(id)sender {
    NSInteger row = [_tableViewMain selectedRow];
    if (row != -1) {
        TaskEntity *entity = [self _entityForRow:row];
        
        if (![entity isKindOfClass:[TaskLoaderEntity class]] && [entity.taskType isEqualToString:@"0"]) {
            NSLog(@"%@", entity.taskID); //BT Task
            
            
            
            TaskLoaderEntity *loderEntity = [TaskLoaderEntity entityNew];
            
            
            //[_tableViewMain beginUpdates];

            //[_tableViewMain setEnabled:NO];
            
            
            //[_tableViewMain endUpdates];
            
            //[_tableViewMain beginUpdates];
            [_tableContents insertObject:loderEntity atIndex:row];
            [_tableViewMain insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:nil];
            [_tableContents removeObjectAtIndex:row+1];
            [_tableViewMain removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row+1] withAnimation:nil];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                
                NSArray *taskList = [TondarAPI readAllBTTaskListWithTaskID:entity.taskID hashID:entity.taskDcid];
                for(XunleiItemInfo *task in taskList){
                    TaskEntity *newEntity = [TaskEntity entityForID:task.taskid];
                    
                    newEntity.title = task.name;
                    newEntity.subtitle = [NSString stringWithFormat:@"%@, Remote Server Progress: %@%%", task.readableSize, task.downloadPercent];
                    newEntity.status = @"Status: Ready";
                    newEntity.taskType = @"BTSubtask";
                    newEntity.taskExt = [NSString stringWithFormat:@"%@", [task.name substringFromIndex:[task.name rangeOfString:@"." options:NSBackwardsSearch].location + 1]];
                    newEntity.cookies = [NSString stringWithFormat:@"Cookie:gdriveid=%@;", [TondarAPI GDriveID]];
                    newEntity.liXianURL = [NSString stringWithFormat:@"%@", task.downloadURL];
                    newEntity.taskDcid = [NSString stringWithFormat:@"%@", task.dcid];
                    newEntity.taskFatherTitle = entity.title;
                    [_tableContents insertObject:newEntity atIndex:row + 1];

                }
                [_tableContents removeObjectAtIndex:row];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableViewMain reloadData];
                });

            });
        }
    }
}

@end
