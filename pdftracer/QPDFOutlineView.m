#import "QPDFOutlineView.h"

@implementation QPDFOutlineView

- (BOOL)acceptsFirstResponder
{
//	NSLog(@"ACCEPT FR: %@",self);
	[super acceptsFirstResponder];
	return YES;
}
- (BOOL)becomeFirstResponder
{
	NSLog(@"BECOME FR: %@",self);
	
	[super becomeFirstResponder];
	/*
	NSResponder* fr = [[self window] firstResponder];
	do {
		NSLog(@"resp: %@",fr);
		fr = [fr nextResponder];
	} while (fr != nil);
	
	NSWindow* w = [self window];
	NSWindowController* wc = [w windowController];
	
	NSLog(@" window: %@ controller: %@",w,wc );
	*/
	[[[self window] windowController] selectChangeNotification:self];
	
	return YES;
}

/*
- (BOOL)respondsToSelector:(SEL)aSelector
{
	NSString* selstr =NSStringFromSelector(aSelector);
	if (![selstr isEqualToString:@"validModesForFontPanel:"])
	{
		NSLog(@"WC EVENT -> %@",NSStringFromSelector(aSelector));
		if( [NSWindowController instancesRespondToSelector:aSelector] ) {
			// invoke the inherited method
			return YES;
		}
	}
	return NO;
}
*/
@end
