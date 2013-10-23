/*
 *  Copyright (C) 2009 - 2012 Stephen F. Booth <me@sbooth.org>
 *  All Rights Reserved
 */

#import "GenerateFormData.h"

NSData *
GenerateFormData(NSDictionary *formValues, NSString *boundary)
{
	NSCParameterAssert(nil != formValues);
	NSCParameterAssert(nil != boundary);
	
	NSMutableData *result = [[NSMutableData alloc] init];
	
	// Iterate over the form elements' keys and append their values
	NSArray *keys = [formValues allKeys];
	for(NSString *key in keys) {
		id value = [formValues valueForKey:key];
		
		[result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
		
		// String value
		if([value isKindOfClass:[NSString class]]) {
			NSString *string = (NSString *)value;
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key] dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[@"Content-Type: text/plain; charset=utf-8\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
		}
		// Number value
		else if([value isKindOfClass:[NSNumber class]]) {
			NSNumber *number = (NSNumber *)value;
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key] dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[@"Content-Type: text/plain; charset=utf-8\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[[number stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		// URL value (only file URLs are supported)
		else if([value isKindOfClass:[NSURL class]] && [(NSURL *)value isFileURL]) {
			NSURL *url = (NSURL *)value;
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, [[url path] lastPathComponent]] dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[@"Content-Type: application/octet-stream\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[NSData dataWithContentsOfURL:url]];
		}
		// Illegal class
		else
			NSLog(@"SFBCrashReporterError: formValues contained illegal object %@ of class %@", value, [value class]);
		
		[result appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
	}
	
	[result appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
	
	return result;
}
