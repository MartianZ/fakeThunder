#import <Cocoa/Cocoa.h>

#import "BaseNode.h"

@interface ChildNode : BaseNode
{
	NSString *description;
	NSTextStorage *text;
}

- (void)setDescription:(NSString *)newDescription;
- (NSString *)description;
- (void)setText:(id)newText;
- (NSTextStorage *)text;

@end
