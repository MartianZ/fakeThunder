//
//  TorrentView.m
//  fakeThunder
//
//  Created by Martian Z on 13-10-21.
//  Copyright (c) 2013年 MartianZ. All rights reserved.
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
#import "TorrentView.h"

@interface TorrentView ()

@end

@implementation TorrentView

@synthesize url;
@synthesize info;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Initialization code here.
    }
    
    return self;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
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
            returnValue = [aFile objectForKey:@"subtitle"];
        }
        else if ([columnIdentifier isEqualToString:@"size"]) {
            returnValue = [aFile objectForKey:@"subformatsize"];
        }
        else if ([columnIdentifier isEqualToString:@"format"]) {
            returnValue = [aFile objectForKey:@"ext"];
        }
    }
    return returnValue;
}

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

#pragma mark - 

- (IBAction)buttonSelectAllClick:(id)sender {
    NSArray* fileList = [self.info objectForKey:@"filelist"];
    for (int i = 0; i < fileList.count; i++) {
        NSDictionary* aFile = [fileList objectAtIndex:i];
        [aFile setValue: [NSNumber numberWithBool:TRUE] forKey:@"valid"];
        [self.fileListView reloadData];
    }
}

- (IBAction)buttonInvertSelectAllClick:(id)sender {
    NSArray* fileList = [self.info objectForKey:@"filelist"];
    for (int i = 0; i < fileList.count; i++) {
        NSDictionary* aFile = [fileList objectAtIndex:i];
        if ([[aFile valueForKey:@"valid"] boolValue]) {
            [aFile setValue: [NSNumber numberWithBool:FALSE] forKey:@"valid"];
            [self.fileListView reloadData];
        } else {
            [aFile setValue: [NSNumber numberWithBool:TRUE] forKey:@"valid"];
            [self.fileListView reloadData];
        }
    }
}

-(IBAction)buttonCancelAndOkayClick:(id)sender {
    if ([[self delegate]respondsToSelector:@selector(didFinishFileSelect:)]) {
        [addBTTaskProgress startAnimation:nil];
		[self.delegate didFinishFileSelect:[[(NSButton *)sender title] isEqualToString:@"OK"]];
        [addBTTaskProgress stopAnimation:nil];
	}
}
@end
