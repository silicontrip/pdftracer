#import "QPDFOutlineView.h"

@implementation QPDFOutlineView

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
	

	[[[self window] windowController] selectChangeNotification:self];
	
	return YES;
}
/*
- (BOOL)validateMenuItem:(NSMenuItem*)anItem
{
	SEL theAction = [anItem action];
	NSLog(@"VALIDATE: %@",NSStringFromSelector(theAction));
	NSLog(@"current %@ %d",self, [self selectedRow]);
	
	if (theAction == @selector(delete:)) {
		NSLog(@"delete... %@ %d",self,[self selectedRow]);
		return NO;
	}
	// return [super validateUserInterfaceItem:anItem];
	return YES;
}
*/
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
