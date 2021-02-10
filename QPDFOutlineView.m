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
	NSResponder* fr = [[self window] firstResponder];
	do {
		NSLog(@"resp: %@",fr);
		fr = [fr nextResponder];
	} while (fr != nil);
	[[[self window] windowController] selectChangeNotification:self];
	
	return YES;
}

@end
