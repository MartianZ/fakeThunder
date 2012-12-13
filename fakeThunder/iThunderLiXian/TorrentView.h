//
//  TorrentView.h
//  fakeThunder
//
//  Created by Jiaan Fang on 12-12-11.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TorrentView : NSViewController
{
    NSDictionary *info;
    NSString *url;
    __weak NSTableView *_file_list_view;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

- (void)setInfo:(NSDictionary*)input;
- (void)setUrl:(NSString*)input;

- (NSDictionary*)info;
- (NSString*)url;

- (IBAction)negative_selection_button:(id)sender;
- (IBAction)select_all_button:(id)sender;

@property (weak) IBOutlet NSTableView *file_list_view;
@property (assign,getter=isSelected) BOOL selected;
@end
