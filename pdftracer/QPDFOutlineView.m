#import "QPDFOutlineView.h"

@implementation QPDFOutlineView

@synthesize relatedSegment;

- (BOOL)acceptsFirstResponder
{
	[super acceptsFirstResponder];
	return YES;
}
- (BOOL)becomeFirstResponder
{
	
	[super becomeFirstResponder];
	/*
	NSResponder* fr = [[self window] firstResponder];
	do {
		NSLog(@"resp: %@",fr);
		fr = [fr nextResponder];
	} while (fr != nil);
	*/
	//NSWindow* w = [self window];
	//NSWindowController* wc = [w windowController];
	

	// [[[self window] windowController] selectChangeNotification:self];
	
	return YES;
}

/*
- (BOOL)respondsToSelector:(SEL)aSelector
{
	NSString* selstr =NSStringFromSelector(aSelector);
	if (![selstr isEqualToString:@"validModesForFontPanel:"])
	{
		NSLog(@"OUT EVENT -> %@",NSStringFromSelector(aSelector));
		if( [NSWindowController instancesRespondToSelector:aSelector] ) {
			// invoke the inherited method
			return YES;
		}
	}
	return NO;
}
*/
@end
