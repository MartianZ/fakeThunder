/*
 *  Copyright (C) 2009 - 2012 Stephen F. Booth <me@sbooth.org>
 *  All Rights Reserved
 */

#import <Cocoa/Cocoa.h>

// ========================================
// The main class for SFBCrashReporter
// ========================================
@interface SFBCrashReporterWindowController : NSWindowController
{}

// ========================================
// Properties
@property (nonatomic, strong) NSString * emailAddress;
@property (nonatomic, strong) NSString * crashLogPath;
@property (nonatomic, strong) NSURL * submissionURL;

// ========================================
// IB Outlets
@property (nonatomic, assign) IBOutlet NSTextView * commentsTextView; // weak property type not available for NSTextView
@property (nonatomic, weak) IBOutlet NSButton * reportButton;
@property (nonatomic, weak) IBOutlet NSButton * ignoreButton;
@property (nonatomic, weak) IBOutlet NSButton * discardButton;
@property (nonatomic, weak) IBOutlet NSProgressIndicator * progressIndicator;

// ========================================
// Always use this to show the window- do not alloc/init directly
+ (void) showWindowForCrashLogPath:(NSString *)path submissionURL:(NSURL *)submissionURL;

// ========================================
// Action methods
- (IBAction) sendReport:(id)sender;
- (IBAction) ignoreReport:(id)sender;
- (IBAction) discardReport:(id)sender;

@end
