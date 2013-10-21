//
//  TorrentView.h
//  fakeThunder
//
//  Created by Martian Z on 13-10-21.
//  Copyright (c) 2013年 MartianZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol TorrentViewDelegate <NSObject>

@optional
- (void)didFinishFileSelect: (BOOL)isOkay;

@end

@interface TorrentView : NSViewController {
    __weak NSTableView *_fileListView;
    NSDictionary *info;
    NSString *url;
    IBOutlet NSProgressIndicator *addBTTaskProgress;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

@property (retain) NSDictionary *info;
@property (retain) NSString *url;

@property (weak) IBOutlet NSTableView *fileListView;
@property (nonatomic, assign) id <TorrentViewDelegate> delegate;


@end
