#import "QPDFSegmentedCell.h"

@implementation QPDFSegmentedCell

- (SEL)action
{
	if ([self menuForSegment:[self selectedSegment]] != nil)
		return nil;
	else
		return [super action];
}

@end
