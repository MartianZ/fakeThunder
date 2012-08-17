#import "NSArray_Extensions.h"

@implementation NSArray (MyArrayExtensions)

// -------------------------------------------------------------------------------
//	containsObjectIdenticalTo:obj:
// -------------------------------------------------------------------------------
- (BOOL)containsObjectIdenticalTo:(id)obj
{ 
	return [self indexOfObjectIdenticalTo:obj] != NSNotFound; 
}

// -------------------------------------------------------------------------------
//	containsAnyObjectsIdenticalTo:objects:
// -------------------------------------------------------------------------------
- (BOOL)containsAnyObjectsIdenticalTo:(NSArray*)objects
{
	NSEnumerator *e = [objects objectEnumerator];
	id obj;
	while (obj = [e nextObject])
	{
		if ([self containsObjectIdenticalTo:obj])
			return YES;
	}
	return NO;
}

// -------------------------------------------------------------------------------
//	indexesOfObjects:objects:
// -------------------------------------------------------------------------------
- (NSIndexSet*)indexesOfObjects:(NSArray*)objects
{
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
	NSEnumerator *enumerator = [objects objectEnumerator];
	id obj = nil;
	NSInteger index;
	while (obj = [enumerator nextObject])
	{
		index = [self indexOfObject:obj];
		if (index != NSNotFound)
			[indexSet addIndex:index];
	}
	return indexSet;
}

@end
