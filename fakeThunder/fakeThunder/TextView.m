//
//  TextView.m
//  fakeThunder
//
//  Created by Martian Z on 11/28/13.
//  Copyright (c) 2013 MartianZ. All rights reserved.
//

#import "TextView.h"

@implementation TextView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

-(NSArray *)readablePasteboardTypes {
    return [NSArray arrayWithObjects:NSPasteboardTypeString,
            nil];
}

@end
