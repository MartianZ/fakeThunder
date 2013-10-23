/*
 *  Copyright (C) 2009 - 2012 Stephen F. Booth <me@sbooth.org>
 *  All Rights Reserved
 */

#import "SFBCrashReporterWindowController.h"
#import "SFBSystemInformation.h"
#import "GenerateFormData.h"

#import <AddressBook/AddressBook.h>

#define USE_NSTEXTVIEW_PRIVATE_API 1
#if USE_NSTEXTVIEW_PRIVATE_API
@interface NSTextView (ApplePrivate)
- (void) setPlaceholderString:(NSString *)placeholder;
@end
#endif

@interface SFBCrashReporterWindowController ()
{
@private
	NSURLConnection *_urlConnection;
	NSMutableData *_responseData;
}

// Keep a strong reference to self so ARC doesn't release the window before it's shown
@property (nonatomic, strong) id self_reference;

@end

@interface SFBCrashReporterWindowController (Callbacks)
- (void) showSubmissionSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
@end

@interface SFBCrashReporterWindowController (Private)
- (NSString *) applicationName;
- (void) sendCrashReport;
- (void) showSubmissionSucceededSheet;
- (void) showSubmissionFailedSheet:(NSError *)error;
@end

@implementation SFBCrashReporterWindowController

@synthesize emailAddress, crashLogPath, submissionURL;
@synthesize commentsTextView, reportButton, discardButton, ignoreButton, progressIndicator;
@synthesize self_reference;

+ (void) initialize
{
	// Register reasonable defaults for most preferences
	NSMutableDictionary *defaultsDictionary = [NSMutableDictionary dictionary];
	
	[defaultsDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"SFBCrashReporterIncludeAnonymousSystemInformation"];
	[defaultsDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"SFBCrashReporterIncludeEmailAddress"];
		
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDictionary];
}

+ (void) showWindowForCrashLogPath:(NSString *)crashLogPath submissionURL:(NSURL *)submissionURL
{
	NSParameterAssert(nil != crashLogPath);
	NSParameterAssert(nil != submissionURL);

	SFBCrashReporterWindowController *windowController = [[self alloc] init];
	
	windowController.crashLogPath = crashLogPath;
	windowController.submissionURL = submissionURL;
	
	[[windowController window] center];
	[windowController showWindow:self];

	windowController.self_reference = windowController;
}

// Should not be called directly by anyone except this class
- (id) init
{
	return [super initWithWindowNibName:@"SFBCrashReporterWindow" owner:self];
}

- (void) windowDidLoad
{
	// Set the window's title
	NSString *applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	NSString *applicationShortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	
	NSString *windowTitle;
	if(!applicationShortVersion)
		windowTitle = [NSString stringWithFormat:NSLocalizedString(@"Crash Reporter: %@", @""), applicationName];
	else
		windowTitle = [NSString stringWithFormat:NSLocalizedString(@"Crash Reporter: %@ (%@)", @""), applicationName, applicationShortVersion];

	[[self window] setTitle:windowTitle];
	
	// Populate the e-mail field with the user's primary e-mail address
	ABMultiValue *emailAddresses = [[[ABAddressBook sharedAddressBook] me] valueForProperty:kABEmailProperty];
	self.emailAddress = (NSString *)[emailAddresses valueForIdentifier:[emailAddresses primaryIdentifier]];

	// Set the font for the comments
	[self.commentsTextView setTypingAttributes:[NSDictionary dictionaryWithObject:[NSFont systemFontOfSize:10.0] forKey:NSFontAttributeName]];

#if USE_NSTEXTVIEW_PRIVATE_API
	// Private API for placeholder strings in NSTextView
	if([self.commentsTextView respondsToSelector:@selector(setPlaceholderString:)])
		[self.commentsTextView setPlaceholderString:NSLocalizedString(@"Please enter a description of the actions leading up to the crash.", @"")];
#endif
}

- (void) windowWillClose:(NSNotification *)notification
{

#pragma unused(notification)

	// Ensure we don't leak memory
	self.self_reference = nil;
}

#pragma mark Action Methods

// Send the report off
- (IBAction) sendReport:(id)sender
{

#pragma unused(sender)

	[self sendCrashReport];
}

// Don't do anything except dismiss our window
- (IBAction) ignoreReport:(id)sender
{

#pragma unused(sender)

	[[self window] orderOut:self];
}

// Move the crash log to the trash since the user isn't interested in submitting it
- (IBAction) discardReport:(id)sender
{

#pragma unused(sender)

	// In 10.8 use:
//	[[NSFileManager defaultManager] trashItemAtURL:[NSURL fileURLWithPath:self.crashLogPath] resultingItemURL:NULL error:NULL];

	// Note: it is odd to use UTF8String here instead of fileSystemRepresentation, but FSPathMakeRef is explicitly
	// documented to take an UTF-8 C string
	FSRef ref;
	OSStatus err = FSPathMakeRef((const UInt8 *)[self.crashLogPath UTF8String], &ref, NULL);
	if(noErr == err) {
		err = FSMoveObjectToTrashSync(&ref, NULL, kFSFileOperationDefaultOptions);
		if(noErr != err)
			NSLog(@"SFBCrashReporter: Unable to move %@ to trash: %i", self.crashLogPath, err);
	}
	else
		NSLog(@"SFBCrashReporter: Unable to create FSRef for file %@", self.crashLogPath);

	[[self window] orderOut:self];
}

@end

@implementation SFBCrashReporterWindowController (Callbacks)

- (void) showSubmissionSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{

#pragma unused(sheet)
#pragma unused(returnCode)
#pragma unused(contextInfo)

	// Whether success or failure, all that remains is to close the window
	[[self window] orderOut:self];
}

@end

@implementation SFBCrashReporterWindowController (Private)

// Convenience method for bindings
- (NSString *) applicationName
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

// Do the actual work of building the HTTP POST and submitting it
- (void) sendCrashReport
{
	NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
	
	// Append system information, if specified
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"SFBCrashReporterIncludeAnonymousSystemInformation"]) {
		SFBSystemInformation *systemInformation = [[SFBSystemInformation alloc] init];
		
		id value = nil;
		
		if((value = [systemInformation machine]))
			[formValues setObject:value forKey:@"machine"];
		if((value = [systemInformation model]))
			[formValues setObject:value forKey:@"model"];
		if((value = [systemInformation physicalMemory]))
			[formValues setObject:value forKey:@"physicalMemory"];
		if((value = [systemInformation busFrequency]))
			[formValues setObject:value forKey:@"busFrequency"];
		if((value = [systemInformation CPUFrequency]))
			[formValues setObject:value forKey:@"CPUFrequency"];
		if((value = [systemInformation CPUFamily]))
			[formValues setObject:value forKey:@"CPUFamily"];
		if((value = [systemInformation CPUType]))
			[formValues setObject:value forKey:@"CPUType"];
		if((value = [systemInformation CPUSubtype]))
			[formValues setObject:value forKey:@"CPUSubtype"];
		if((value = [systemInformation numberOfCPUs]))
			[formValues setObject:value forKey:@"numberOfCPUs"];
		if((value = [systemInformation physicalCPUs]))
			[formValues setObject:value forKey:@"physicalCPUs"];
		if((value = [systemInformation logicalCPUs]))
			[formValues setObject:value forKey:@"logicalCPUs"];
		if((value = [systemInformation systemVersion]))
			[formValues setObject:value forKey:@"systemVersion"];
		if((value = [systemInformation systemBuildVersion]))
			[formValues setObject:value forKey:@"systemBuildVersion"];

		[formValues setObject:[NSNumber numberWithBool:YES] forKey:@"systemInformationIncluded"];
	}
	else
		[formValues setObject:[NSNumber numberWithBool:NO] forKey:@"systemInformationIncluded"];
	
	// Include email address, if permitted
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"SFBCrashReporterIncludeEmailAddress"] && self.emailAddress)
		[formValues setObject:self.emailAddress forKey:@"emailAddress"];
	
	// Optional comments
	NSAttributedString *attributedComments = [self.commentsTextView attributedSubstringFromRange:NSMakeRange(0, NSUIntegerMax)];
	if([[attributedComments string] length])
		[formValues setObject:[attributedComments string] forKey:@"comments"];
	
	// The most important item of all
	[formValues setObject:[NSURL fileURLWithPath:self.crashLogPath] forKey:@"crashLog"];

	// Add the application information
	NSString *applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	if(applicationName)
		[formValues setObject:applicationName forKey:@"applicationName"];
	
	NSString *applicationIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
	if(applicationIdentifier)
		[formValues setObject:applicationIdentifier forKey:@"applicationIdentifier"];

	NSString *applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	if(applicationVersion)
		[formValues setObject:applicationVersion forKey:@"applicationVersion"];

	NSString *applicationShortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	if(applicationShortVersion)
		[formValues setObject:applicationShortVersion forKey:@"applicationShortVersion"];
	
	// Create a date formatter
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	// Determine which locale the developer would like dates/times in
	NSString *localeName = [[NSUserDefaults standardUserDefaults] stringForKey:@"SFBCrashReporterPreferredReportingLocale"];
	if(!localeName) {
		localeName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SFBCrashReporterPreferredReportingLocale"];
		// US English is the default
		if(!localeName)
			localeName = @"en_US";
	}
	
	NSLocale *localeToUse = [[NSLocale alloc] initWithLocaleIdentifier:localeName];
	[dateFormatter setLocale:localeToUse];

	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	
	// Include the date and time
	[formValues setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"date"];
		
	// Generate the form data
	NSString *boundary = @"81e29ba4f957efe5916039f587fe3ed7";
	NSData *formData = GenerateFormData(formValues, boundary);
	
	// Set up the HTTP request
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:self.submissionURL];
	
	[urlRequest setHTTPMethod:@"POST"];

	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	[urlRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];

	[urlRequest setValue:@"SFBCrashReporter" forHTTPHeaderField:@"User-Agent"];
	[urlRequest setValue:[NSString stringWithFormat:@"%lu", [formData length]] forHTTPHeaderField:@"Content-Length"];

	[urlRequest setHTTPBody:formData];
	
	[self.progressIndicator startAnimation:self];

	[self.reportButton setEnabled:NO];
	[self.ignoreButton setEnabled:NO];
	[self.discardButton setEnabled:NO];
	
	// Submit the URL request
	_urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

- (void) showSubmissionSucceededSheet
{
	[self.progressIndicator stopAnimation:self];
		
	NSBeginAlertSheet(NSLocalizedString(@"The crash report was successfully submitted.", @""), 
					  nil /* Use the default button title, */, 
					  nil, 
					  nil, 
					  [self window], 
					  self, 
					  @selector(showSubmissionSheetDidEnd:returnCode:contextInfo:), 
					  NULL, 
					  NULL, 
					  NSLocalizedString(@"Thank you for taking the time to help improve %@!", @""), 
					  [self applicationName]);
}

- (void) showSubmissionFailedSheet:(NSError *)error
{
	NSParameterAssert(nil != error);

	[self.progressIndicator stopAnimation:self];
	
	NSBeginAlertSheet(NSLocalizedString(@"An error occurred while submitting the crash report.", @""), 
					  nil /* Use the default button title, */, 
					  nil, 
					  nil, 
					  [self window], 
					  self, 
					  @selector(showSubmissionSheetDidEnd:returnCode:contextInfo:), 
					  NULL, 
					  NULL, 
					  NSLocalizedString(@"The error was: %@", @""), 
					  [error localizedDescription]);
}

#pragma mark NSTextView delegate methods

- (BOOL) textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector;
{
    if(commandSelector == @selector(insertTab:)) {
        [[textView window] selectNextKeyView:self];
        return YES;
    }
	else if(commandSelector == @selector(insertBacktab:)) {
        [[textView window] selectPreviousKeyView:self];
        return YES;
    }

    return NO;
}

#pragma mark NSURLConnection delegate methods

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{

#pragma unused(connection)
#pragma unused(response)

	_responseData = [[NSMutableData alloc] init];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{

#pragma unused(connection)

	[_responseData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{

#pragma unused(connection)

	// A valid response is simply the string 'ok'
	NSString *responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
	BOOL responseOK = [responseString isEqualToString:@"ok"];

	_urlConnection = nil;
	_responseData = nil;
	
	if(responseOK) {
		// Create our own instance since this method could be called from a background thread
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		
		// Use the file's modification date as the last submitted crash date
		NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:self.crashLogPath error:nil];
		NSDate *fileModificationDate = [fileAttributes fileModificationDate];

		if(fileModificationDate)
			[[NSUserDefaults standardUserDefaults] setObject:fileModificationDate forKey:@"SFBCrashReporterLastCrashReportDate"];

		// Delete the crash log since it is no longer needed
		NSError *error = nil;
		if(![fileManager removeItemAtPath:self.crashLogPath error:&error])
			NSLog(@"SFBCrashReporter error: Unable to delete the submitted crash log (%@): %@", [self.crashLogPath lastPathComponent], [error localizedDescription]);

		// Even though the log wasn't deleted, submission was still successful
		[self performSelectorOnMainThread: @selector(showSubmissionSucceededSheet) withObject:nil waitUntilDone:NO];
	}
	// An error occurred on the server
	else {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Unrecognized response from the server", @""), NSLocalizedDescriptionKey, nil];
		NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EPROTO userInfo:userInfo];

		[self performSelectorOnMainThread: @selector(showSubmissionFailedSheet:) withObject:error waitUntilDone:NO];
	}
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{

#pragma unused(connection)

	_urlConnection = nil;
	_responseData = nil;

	[self performSelectorOnMainThread:@selector(showSubmissionFailedSheet:) withObject:error waitUntilDone:NO];
}

@end
