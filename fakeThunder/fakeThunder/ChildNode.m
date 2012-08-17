#import "ChildNode.h"

@implementation ChildNode

// -------------------------------------------------------------------------------
//	init:
// -------------------------------------------------------------------------------
- (id)init
{
	self = [super init];
	if (self)
    {
		self.nodeTitle = @"";
		description = [[NSString alloc] initWithString:@"- empty description -"];
		text = [[NSTextStorage alloc] init];
	}
	return self;
}

// -------------------------------------------------------------------------------
//	dealloc:
// -------------------------------------------------------------------------------
- (void)dealloc
{
	[description release];
	[text release];
	[super dealloc];
}

// -------------------------------------------------------------------------------
//	setDescription:newDescription:
// -------------------------------------------------------------------------------
- (void)setDescription:(NSString *)newDescription
{
	[newDescription retain];
	[description release];
	description = newDescription;
}

// -------------------------------------------------------------------------------
//	description
// -------------------------------------------------------------------------------
- (NSString *)description
{
	return description;
}

// -------------------------------------------------------------------------------
//	setText:newText:
// -------------------------------------------------------------------------------
- (void)setText:(id)newText
{
	if ([newText isKindOfClass:[NSAttributedString class]])
		[text replaceCharactersInRange:NSMakeRange(0, [text length]) withAttributedString:newText];
	else
		[text replaceCharactersInRange:NSMakeRange(0, [text length]) withString:newText];
}

// -------------------------------------------------------------------------------
//	text:
// -------------------------------------------------------------------------------
- (NSTextStorage *)text
{
	return text;
}

// -------------------------------------------------------------------------------
//	mutableKeys:
//
//	Maintain support for archiving and copying.
// -------------------------------------------------------------------------------
- (NSArray *)mutableKeys
{
	return [[super mutableKeys] arrayByAddingObjectsFromArray:
				[NSArray arrayWithObjects:@"description", @"text", nil]];
}

@end
