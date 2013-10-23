/*
 *  Copyright (C) 2009 - 2012 Stephen F. Booth <me@sbooth.org>
 *  All Rights Reserved
 */

#import <Cocoa/Cocoa.h>

// ========================================
// The main interface
// ========================================
@interface SFBCrashReporter : NSObject
{}

// Ensure that SFBCrashReporterCrashSubmissionURL is set to a string in either your application's Info.plist
// or NSUserDefaults and call this
+ (void) checkForNewCrashes;

@end
