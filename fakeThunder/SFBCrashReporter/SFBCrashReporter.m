/*
 *  Copyright (C) 2009 - 2012 Stephen F. Booth <me@sbooth.org>
 *  All Rights Reserved
 */

#import "SFBCrashReporter.h"
#import "SFBCrashReporterWindowController.h"

@interface SFBCrashReporter (Private)
+ (NSArray *) crashLogDirectories;
+ (NSArray *) crashLogPaths;
@end

@implementation SFBCrashReporter

+ (void) checkForNewCrashes
{
	// If no URL is found for the submission, we can't do anything
	NSString *crashSubmissionURLString = [[NSUserDefaults standardUserDefaults] stringForKey:@"SFBCrashReporterCrashSubmissionURL"];
	if(!crashSubmissionURLString) {
		crashSubmissionURLString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SFBCrashReporterCrashSubmissionURL"];
		if(!crashSubmissionURLString)
			[NSException raise:@"Missing SFBCrashReporterCrashSubmissionURL" format:@"You must specify the URL for crash log submission as the SFBCrashReporterCrashSubmissionURL in either Info.plist or the user defaults!"];
	}

	// Determine when the last crash was reported
	NSDate *lastCrashReportDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"SFBCrashReporterLastCrashReportDate"];
	
	// If a crash was never reported, use now as the starting point, removie all earlier crash report
	if(!lastCrashReportDate) {
		lastCrashReportDate = [NSDate date];
		[[NSUserDefaults standardUserDefaults] setObject:lastCrashReportDate forKey:@"SFBCrashReporterLastCrashReportDate"];
        
        for(NSString *path in [self crashLogPaths]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        
        return;
	}
	
	// Determine if it is even necessary to show the window (by comparing file modification dates to the last time a crash was reported)
	NSArray *crashLogPaths = [self crashLogPaths];
	for(NSString *path in crashLogPaths) {
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
		NSDate *fileModificationDate = [fileAttributes fileModificationDate];
		
		// If the last time a crash was reported is earlier than the file's modification date, allow the user to report the crash
		if(fileModificationDate && NSOrderedAscending == [lastCrashReportDate compare:fileModificationDate] ) {
			[SFBCrashReporterWindowController showWindowForCrashLogPath:path submissionURL:[NSURL URLWithString:crashSubmissionURLString]];
			
			// Don't prompt more than once
			break;
		}
	}
}

@end

@implementation SFBCrashReporter (Private)

+ (NSArray *) crashLogDirectories
{
	// Snow Leopard crash logs are located in ~/Library/Logs/DiagnosticReports
	NSString *crashLogDirectory = @"Logs/DiagnosticReports";

	NSMutableArray *crashFolderPaths = [[NSMutableArray alloc] init];
	
	NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask | NSLocalDomainMask, YES);
	for(NSString *libraryPath in libraryPaths) {
		NSString *path = [libraryPath stringByAppendingPathComponent:crashLogDirectory];
		
		BOOL isDir = NO;
		if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir) {
			[crashFolderPaths addObject:path];
			break;
		}
	}
	
	return crashFolderPaths;	
}

+ (NSArray *) crashLogPaths
{
	NSString *applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	NSArray *crashLogDirectories = [self crashLogDirectories];

	NSMutableArray *paths = [[NSMutableArray alloc] init];

	for(NSString *crashLogDirectory in crashLogDirectories) {
		NSString *file = nil;
		NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:crashLogDirectory];
		while((file = [dirEnum nextObject]))
			if([file hasPrefix:applicationName])
				[paths addObject:[crashLogDirectory stringByAppendingPathComponent:file]];
	}
	
	return paths;
}

@end
