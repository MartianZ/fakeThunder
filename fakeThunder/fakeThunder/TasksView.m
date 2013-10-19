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
        
        
        TondarAPI = [[HYXunleiLixianAPI alloc] init];
        [TondarAPI logOut];
        
        
        
        if ([TondarAPI loginWithUsername:@"1123400335@qq.com" Password:@"WangliuytrewqXL"]) {
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
                entity1.taskDcid = [NSString stringWithFormat:@"%@", task.dcid];

                NSLog(@"%@", [TondarAPI GDriveID]);

            }
        }

    }
    
    return self;
}

- (void)awakeFromNib {
    [_tableViewMain setDoubleAction:@selector(tblvwDoubleClick:)];
    [_tableViewMain setTarget:self];
    [_tableViewMain setUsesAlternatingRowBackgroundColors:YES];
    [_tableViewMain setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
    
    
    [_tableViewMain reloadData];
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
        
        TaskEntity *entity = [self _entityForRow:[_tableViewMain selectedRow]];
        
        entity.selectedRow = [_tableViewMain selectedRow];
        [entity setDelegate:self];
        [entity performDownloadWithThread];

    }
}



- (void)taskRowNeedUpdate:(NSString *)taskID
{
    
    for (int row = 0; row < [_tableViewMain numberOfRows]; row++ ) {
        if ([[NSString stringWithFormat:@"%@", [self _entityForRow:row].taskDcid] isEqualToString:taskID])
        {
            NSLog(@"FOUND!");
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
        [_tableContents removeObjectAtIndex:row];
        [_tableViewMain removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationEffectFade];
    }
}


- (IBAction)tblvwDoubleClick:(id)sender {
    NSInteger row = [_tableViewMain selectedRow];
    if (row != -1) {
        TaskEntity *entity = [self _entityForRow:row];
        
        if (![entity isKindOfClass:[TaskLoaderEntity class]] && [entity.taskType isEqualToString:@"0"]) {
            NSLog(@"%@", entity.taskID); //BT Task
            
            
            
            TaskLoaderEntity *loderEntity = [TaskLoaderEntity entityNew];
            
            [_tableViewMain setEnabled:NO];
            [_tableContents insertObject:loderEntity atIndex:row];
            [_tableViewMain removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row+1] withAnimation:nil];
            [_tableContents removeObjectAtIndex:row+1];

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                NSArray *taskList = [TondarAPI readAllBTTaskListWithTaskID:entity.taskID hashID:entity.taskDcid];
                
                for(XunleiItemInfo *task in taskList){
                    
                    
                    TaskEntity *newEntity = [TaskEntity entityForID:task.taskid];
                    
                    newEntity.title = task.name;
                    newEntity.subtitle = [NSString stringWithFormat:@"%@, Remote Server Progress: %@%%", task.readableSize, task.downloadPercent];
                    newEntity.status = @"Status: Ready";
                    newEntity.taskType = [NSString stringWithFormat:@"%@", task.isBT];
                    newEntity.taskExt = [NSString stringWithFormat:@"%@", [task.name substringFromIndex:[task.name rangeOfString:@"." options:NSBackwardsSearch].location + 1]];
                    newEntity.cookies = [NSString stringWithFormat:@"Cookie:gdriveid=%@;", [TondarAPI GDriveID]];
                    newEntity.liXianURL = [NSString stringWithFormat:@"%@", task.downloadURL];
                    newEntity.taskDcid = [NSString stringWithFormat:@"%@", task.dcid];
                    
                    dispatch_async( dispatch_get_main_queue(), ^{
                        [_tableContents insertObject:newEntity atIndex:row+1];
                        [_tableViewMain insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:row+1] withAnimation:NSTableViewAnimationSlideLeft];
                        [_tableViewMain endUpdates];

                    });
                    usleep(300000);
                }
                
                dispatch_async( dispatch_get_main_queue(), ^{
                    [_tableContents removeObjectAtIndex:row];
                    [_tableViewMain removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationSlideRight];
                    [_tableViewMain setEnabled:YES];
                    [_tableViewMain reloadData];

                });
                

            });
            
            
            
            
            

            

            
            
        }
    }
}

@end
