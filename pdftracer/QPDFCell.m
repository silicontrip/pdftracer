#import "QPDFCell.h"

@implementation QPDFCell

- (SEL)action
{
	if ([self menuForSegment:[self selectedSegment]] != nil)
		return nil;
	else
		return [super action];
}

@end
