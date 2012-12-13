//
//  DropZoneView.m
//  fakeThunder
//
//  Created by Jiaan Fang on 12-12-12.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "DropZoneView.h"

@implementation DropZoneView

@synthesize delegate;

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    }
    return self;
}
//--------------------------------------------------------------
//     Delegate
//--------------------------------------------------------------

- (void)torrentDropped : (NSString*) filePath{
    if ([[self delegate]respondsToSelector:@selector(didRecivedTorrentFile:)]) {
		[self.delegate didRecivedTorrentFile:filePath];
	}
}
- (void) setDelegate:(id <DropZoneDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;

    }
}
//--------------------------------------------------------------
//     拖放相关
//--------------------------------------------------------------

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender{
    NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    if ([draggedFilenames count] > 1) {
        highlight=NO;
        not_single=YES;
        wrong_file=NO;
        [self setNeedsDisplay: YES];
        return NSDragOperationNone;
    } else if (![[[draggedFilenames objectAtIndex:0] pathExtension]isEqual:@"torrent"]){
        highlight=NO;
        not_single=NO;
        wrong_file=YES;
        [self setNeedsDisplay: YES];
        return NSDragOperationNone;
    } else {
        highlight=YES;
        not_single=NO;
        wrong_file=NO;
        [self setNeedsDisplay: YES];
        return NSDragOperationCopy;
    }
}

- (void)draggingExited:(id <NSDraggingInfo>)sender{
    highlight=NO;
    wrong_file=NO;
    not_single=NO;
    [self setNeedsDisplay: YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    highlight=NO;
    wrong_file=NO;
    not_single=NO;
    [self setNeedsDisplay: YES];
    return YES;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender {
    NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    if ([[[draggedFilenames objectAtIndex:0] pathExtension] isEqual:@"torrent"]){
        return YES;
    } else {
        return NO;
    }
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender{
    NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    NSString *filePath = [draggedFilenames objectAtIndex:0];
    [self torrentDropped:filePath];
}

//--------------------------------------------------------------
//     绘图
//--------------------------------------------------------------
- (void)drawRect:(NSRect)rect{
    [super drawRect:rect];
    

    if ( highlight ) {
        //// Color Declarations
        NSColor* color = [NSColor colorWithCalibratedRed: 0.84 green: 0.84 blue: 0.84 alpha: 1];
        
        //// Rounded Rectangle Drawing
        NSBezierPath* roundedRectanglePath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(3.5, 3.5, 531, 239) xRadius: 15 yRadius: 15];
        [color setFill];
        [roundedRectanglePath fill];
        [[NSColor lightGrayColor] setStroke];
        [roundedRectanglePath setLineWidth: 3];
        CGFloat roundedRectanglePattern[] = {5, 5, 5, 5};
        [roundedRectanglePath setLineDash: roundedRectanglePattern count: 4 phase: 0];
        [roundedRectanglePath stroke];
        
    } else {
        NSColor* color = [NSColor colorWithCalibratedRed: 0.871 green: 0.871 blue: 0.871 alpha: 1];
        
        //// Rounded Rectangle Drawing
        NSBezierPath* roundedRectanglePath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(3.5, 3.5, 531, 239) xRadius: 15 yRadius: 15];
        [color setFill];
        [roundedRectanglePath fill];
        [[NSColor lightGrayColor] setStroke];
        [roundedRectanglePath setLineWidth: 3];
        CGFloat roundedRectanglePattern[] = {5, 5, 5, 5};
        [roundedRectanglePath setLineDash: roundedRectanglePattern count: 4 phase: 0];
        [roundedRectanglePath stroke];
        
        // 错误信息
        if (not_single || wrong_file) {
            NSString* textContent;
            if (not_single) {
                //// Abstracted Attributes
                textContent = @"不支持多个文件";
            } else if (wrong_file) {
                //// Abstracted Attributes
                textContent = @"不是种子文件";
            }
            //// Text Drawing
            NSRect textRect = NSMakeRect(175, 202, 189, 30);
            NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            [textStyle setAlignment: NSCenterTextAlignment];
            
            NSDictionary* textFontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSFont boldSystemFontOfSize: [NSFont systemFontSize]], NSFontAttributeName,
                                                [NSColor blackColor], NSForegroundColorAttributeName,
                                                textStyle, NSParagraphStyleAttributeName, nil];
            
            [textContent drawInRect: textRect withAttributes: textFontAttributes];
        }
    }
}
@end
