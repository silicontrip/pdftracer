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
	
	[[[self window] windowController] selectChangeNotification:self];
	
	return YES;
}

@end
