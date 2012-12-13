//
//  TorrentView.m
//  fakeThunder
//
//  Created by Jiaan Fang on 12-12-11.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "TorrentView.h"

@interface TorrentView ()

@end

@implementation TorrentView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark - TableView Data source
//--------------------------------------------------------------
//     TableView数据源
//--------------------------------------------------------------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [[info objectForKey:@"filelist"] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    id returnValue = nil;
    if (info != nil) {
        NSArray* fileList = [info objectForKey:@"filelist"];
        NSString* columnIdentifier = [aTableColumn identifier];
        NSDictionary* aFile = [fileList objectAtIndex:rowIndex];
        if ([columnIdentifier isEqualToString:@"selected"]) {
            BOOL selected = [[aFile objectForKey:@"valid"] boolValue];
            returnValue = [NSNumber numberWithBool:selected];
        }
        else if ([columnIdentifier isEqualToString:@"name"]) {
            returnValue = [aFile objectForKey:@"title"];
        }
        else if ([columnIdentifier isEqualToString:@"size"]) {
            returnValue = [aFile objectForKey:@"formatsize"];
        }
        else if ([columnIdentifier isEqualToString:@"format"]) {
            returnValue = [aFile objectForKey:@"ext"];
        }
    }
    return returnValue;
}
//--------------------------------------------------------------
//     TableView Delegate
//--------------------------------------------------------------
#pragma mark - TableView Delegate
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSArray* fileList = [info objectForKey:@"filelist"];
    NSDictionary* aFile = [fileList objectAtIndex:rowIndex];

    if ([[aTableColumn identifier] isEqualToString:@"selected"])
    {
        [aFile setValue:anObject forKey:@"valid"];
    }

}

#pragma mark - accessors
- (void)setInfo:(NSDictionary*)input{
    info = input;
}
- (void)setUrl:(NSString*)input{
    url = input;
}

- (NSDictionary*)info{
    return info;
}

- (NSString*)url{
    return url;
}
- (IBAction)negative_selection_button:(id)sender
{
    NSArray* fileList = [info objectForKey:@"filelist"];
    for (int i = 0; i < fileList.count; i++) {
        NSDictionary* aFile = [fileList objectAtIndex:i];
        if ([[aFile valueForKey:@"valid"] boolValue]) {
            [aFile setValue: [NSNumber numberWithBool:FALSE] forKey:@"valid"];
            [_file_list_view reloadData];
        } else {
            [aFile setValue: [NSNumber numberWithBool:TRUE] forKey:@"valid"];
            [_file_list_view reloadData];
        }
    }
}

- (IBAction)select_all_button:(id)sender
{
    NSArray* fileList = [info objectForKey:@"filelist"];
    for (int i = 0; i < fileList.count; i++) {
        NSDictionary* aFile = [fileList objectAtIndex:i];
        [aFile setValue: [NSNumber numberWithBool:TRUE] forKey:@"valid"];
        [_file_list_view reloadData];
    }
}


@end
