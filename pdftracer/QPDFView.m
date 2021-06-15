#import "QPDFView.h"


// So we can handle special PDF Document UI stuff.
// and so we can ignore regular PDF Document UI stuff.
// it goes ding.

@implementation QPDFView

// @synthesize relatedSegment;



- (void)mouseDown:(NSEvent*)event
{
	NSLog(@"we have a mouse down. Repeat, a mouse is down");
	NSLog(@"%@",event);
}

- (void)keyDown:(NSEvent*)event
{
	; // do nothing
}

- (BOOL)acceptsFirstResponder
{
	// [super acceptsFirstResponder];
	return NO;
}
/*
- (BOOL)becomeFirstResponder
{
	
	[super becomeFirstResponder];
	
	NSResponder* fr = [[self window] firstResponder];
	do {
		NSLog(@"QPDFView: %@",fr);
		fr = [fr nextResponder];
	} while (fr != nil);
	
	//NSWindow* w = [self window];
	//NSWindowController* wc = [w windowController];
	

	// [[[self window] windowController] selectChangeNotification:self];
	
	return YES;
}
*/
/*
- (BOOL)respondsToSelector:(SEL)aSelector
{
	//return YES;
	NSString* selstr =NSStringFromSelector(aSelector);
	BOOL response = [NSWindowController instancesRespondToSelector:aSelector];
//	if (![selstr isEqualToString:@"validModesForFontPanel:"])
//	{
		NSLog(@"QPDFView selector -> %@ ? %d",selstr,response);
		if( response ) {
			// invoke the inherited method
			return YES;
		}
//	}
 return [super respondsToSelector:aSelector];
}
*/
@end

