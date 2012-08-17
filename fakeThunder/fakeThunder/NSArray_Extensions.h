#import <Foundation/Foundation.h>

@interface NSArray (MyArrayExtensions)
- (BOOL)containsObjectIdenticalTo:(id)object;
- (BOOL)containsAnyObjectsIdenticalTo:(NSArray *)objects;
- (NSIndexSet *)indexesOfObjects:(NSArray *)objects;
@end
