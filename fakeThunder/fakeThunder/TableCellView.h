//
//  TableCellView.h
//  fakeThunder
//
//  Created by Martian Z on 13-10-18.
//  Copyright (c) 2013年 MartianZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TableCellView : NSTableCellView {
@private
    IBOutlet NSTextField *subTitleTextField;
    IBOutlet NSTextField *statusTextField;
    IBOutlet NSProgressIndicator *progessIndicator;
    IBOutlet NSButton *removeButton;
}



@property(assign) NSTextField *subTitleTextField;
@property(assign) NSTextField *statusTextField;
@property(assign) NSProgressIndicator *progessIndicator;
@property(assign) NSButton *removeButton;



@end
