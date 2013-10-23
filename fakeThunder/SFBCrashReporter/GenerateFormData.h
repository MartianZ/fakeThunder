/*
 *  Copyright (C) 2009 - 2012 Stephen F. Booth <me@sbooth.org>
 *  All Rights Reserved
 */

#pragma once

#import <Cocoa/Cocoa.h>

// ========================================
// Generates multipart/form-data from the given dictionary using the specified boundary
// ========================================
NSData * GenerateFormData(NSDictionary *formValues, NSString *boundary);
