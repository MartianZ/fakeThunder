//
//  TasksView.h
//  fakeThunder
//
//  Created by Martian on 12-8-15.
//  Copyright (c) 2012年 MartianZ. All rights reserved.
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
#import <Cocoa/Cocoa.h>
#import "TasksView.h"
#import "TaskEntity.h"
#import <TondarAPI/HYXunleiLixianAPI.h>
#import <TondarAPI/XunleiItemInfo.h>
#import "DownloadOperation.h"
@interface TasksView : NSViewController <NSTableViewDelegate, NSTableViewDataSource, TaskDelegate> {

    @private
    NSMutableArray *_tableContents;
    NSMutableArray *_observedVisibleItems;
    IBOutlet NSTableView *_tableViewMain;
    HYXunleiLixianAPI *TondarAPI;
    NSOperationQueue *operationDownloadQueue;

    BOOL _useSmallRowHeight;
    BOOL _isLoadingTask;
    NSUInteger _currentPage;
    NSWindow *_mainWindow;
}


- (void)downloadSelectedTask;
- (void)stopDownloadSelectedTask;
- (void)startCheckNewTasks;
- (IBAction)tblvwDoubleClick:(id)sender;
- (void)startLoadFirstTaskPagsWithTondarAPI:(HYXunleiLixianAPI*)api;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parentWindow:(NSWindow *)window;

@end
