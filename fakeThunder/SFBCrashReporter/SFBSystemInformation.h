/*
 *  Copyright (C) 2009 - 2012 Stephen F. Booth <me@sbooth.org>
 *  All Rights Reserved
 */

#import <Cocoa/Cocoa.h>

// ========================================
// Utility class for accessing useful system information
// ========================================
@interface SFBSystemInformation : NSObject
{}

// The shared instance
+ (SFBSystemInformation *) instance;

// Hardware information
- (NSString *) machine;			// Machine class: "x86_64"
- (NSString *) model;			// Machine model: "MacBookPro8,2"

- (NSNumber *) physicalMemory;	// in bytes
- (NSNumber *) busFrequency;	// in hertz
- (NSNumber *) CPUFrequency;	// in hertz

// See /usr/include/mach/machine.h for possible values
- (NSNumber *) CPUFamily;
- (NSNumber *) CPUType;
- (NSNumber *) CPUSubtype;

- (NSNumber *) numberOfCPUs;	// The maximum number of processors that could be available
- (NSNumber *) physicalCPUs;	// The number of physical processors in the current power mgmt mode
- (NSNumber *) logicalCPUs;		// The number of logical processors in the current power mgmt mode

// Mac OS version information
- (NSString *) systemVersion;
- (NSString *) systemBuildVersion;

@end
