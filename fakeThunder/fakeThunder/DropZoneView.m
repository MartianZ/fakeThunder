//
//  DropZoonView.m
//  fakeThunder
//
//  Created by Jiaan Fang on 12-12-12., Edited by Martian Z on 13-10-21.
//  Copyright (c) 2013年 MartianZ. All rights reserved.
//

#import "DropZoneView.h"

@implementation DropZoneView

@synthesize delegate;

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    }
    return self;
}


#pragma mark - 
#pragma mark - Delegate

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

#pragma mark -
#pragma mark - DragAndDrop

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender{
    NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    if ([draggedFilenames count] > 1) {
        isHighLight = NO;
        isNotSigle = YES;
        isWrongFile = NO;
        [self setNeedsDisplay: YES];
        return NSDragOperationNone;
    } else if (![[[draggedFilenames objectAtIndex:0] pathExtension]isEqual:@"torrent"]){
        isHighLight = NO;
        isNotSigle = NO;
        isWrongFile = YES;
        [self setNeedsDisplay: YES];
        return NSDragOperationNone;
    } else {
        isHighLight = YES;
        isNotSigle = NO;
        isWrongFile = NO;
        [self setNeedsDisplay: YES];
        return NSDragOperationCopy;
    }
}


- (void)draggingExited:(id<NSDraggingInfo>)sender {
    isHighLight = NO;
    isNotSigle = NO;
    isWrongFile= NO;
    [self setNeedsDisplay: YES];
}


- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    isHighLight = NO;
    isNotSigle = NO;
    isWrongFile= NO;
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


- (void)drawRect:(NSRect)rect{
    [super drawRect:rect];
    
    
    if ( isHighLight ) {
        //// Color Declarations
        NSColor* color = [NSColor colorWithCalibratedRed: 0.84 green: 0.84 blue: 0.84 alpha: 1];
        
        //// Rounded Rectangle Drawing
        NSBezierPath* roundedRectanglePath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(3.5, 8, 454, 231) xRadius: 15 yRadius: 15];
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
        NSBezierPath* roundedRectanglePath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(3.5, 8, 454, 231) xRadius: 15 yRadius: 15];
        [color setFill];
        [roundedRectanglePath fill];
        [[NSColor lightGrayColor] setStroke];
        [roundedRectanglePath setLineWidth: 3];
        CGFloat roundedRectanglePattern[] = {5, 5, 5, 5};
        [roundedRectanglePath setLineDash: roundedRectanglePattern count: 4 phase: 0];
        [roundedRectanglePath stroke];
        
        // 错误信息
        if (isNotSigle || isWrongFile) {
            NSString* textContent;
            if (isNotSigle) {
                //// Abstracted Attributes
                textContent = @"Not support multi files.";
            } else {
                //// Abstracted Attributes
                textContent = @"Not a torrent file.";
            }
            //// Text Drawing
            NSRect textRect = NSMakeRect(140, 60, 189, 30);
            NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            [textStyle setAlignment: NSCenterTextAlignment];
            
            NSDictionary* textFontAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSFont boldSystemFontOfSize: [NSFont systemFontSize]], NSFontAttributeName,
                                                [NSColor redColor], NSForegroundColorAttributeName,
                                                textStyle, NSParagraphStyleAttributeName, nil] autorelease];
            
            [textContent drawInRect: textRect withAttributes: textFontAttributes];
        }
    }
}
@end
