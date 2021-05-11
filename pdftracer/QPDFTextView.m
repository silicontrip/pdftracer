#import "QPDFTextView.h"

// #import "QPDFWindowController.h"

@implementation QPDFTextView

- (BOOL)acceptsFirstResponder
{
	return YES;
}
/*
- (BOOL)becomeFirstResponder
{
	
	[super becomeFirstResponder];
	
	NSResponder* fr = [[self window] firstResponder];
	do {
		NSLog(@"QPDFTextView R.C.: %@",fr);
		fr = [fr nextResponder];
	} while (fr != nil);
	
	//NSWindow* w = [self window];
	//NSWindowController* wc = [w windowController];
	
	
	// [[[self window] windowController] selectChangeNotification:self];
	
	return YES;
}
*/
/*
- (void)keyDown:(NSEvent*)event
{
	// [super keyDown:event];
	
//	NSRect saveRect = [self visibleRect];
//	NSLog(@"self rect: %@",NSStringFromRect(saveRect));
	
//	NSResponder* fr = [self nextResponder];
	// [fr keyDown:event];
	// [[self window] firstResponder];
	// NSLog(@"keyDown N.R.: %@",fr);
	// fr = [fr nextResponder];
	// NSLog(@"keyDown N.R.: %@",fr);

	// fr = [self nextResponder];
	// NSLog(@"keyDown N.R.: %@",fr);

//	NSString* key = [event characters];
	
//	if (![key isEqualToString:@" "])
//	{
		[super keyDown:event];
//	}
	// [fr keyDown:event];
	
	NSLog(@"we have a key down. Repeat, a key is down");
	NSLog(@"%@",event);
}
*/

/*
- (BOOL)respondsToSelector:(SEL)aSelector
{
	//return YES;
	NSString* selstr =NSStringFromSelector(aSelector);
	BOOL response = [NSWindowController instancesRespondToSelector:aSelector];
	if (![selstr isEqualToString:@"validModesForFontPanel:"])
	{
	//NSLog(@"OUT EVENT -> %@ ? %d",selstr,response);
		if( response ) {
		// invoke the inherited method
			return YES;
		}
	}
	return [super respondsToSelector:aSelector];
}
*/
@end

