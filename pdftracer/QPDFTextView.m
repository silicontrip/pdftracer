#import "QPDFTextView.h"

// #import "QPDFWindowController.h"

@implementation QPDFTextView
/*
- (instancetype)init
{
	self = [super init];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationSetText:) name:@"QPDFUpdateTextview" object:nil];
	return self;
}

-(void)notificationSetText:(NSNotification*)n
{
	NSString* text = [n object];
	[self sett]

}
*/

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)print:(id)sender
{
	// [[self nextResponder] print:sender];
}

- (void)performTextFinderAction:(id)sender
{
	NSLog(@"Findernating the countryside: %@",sender);
}

/*
- (void)paste:(id)sender
{
	
	NSLog(@"paster; %@",sender);
	
	[super paste:sender];
}
*/

/*
- (BOOL)becomeFirstResponder
{
	
	[super becomeFirstResponder];
	
	NSResponder* fr = [[self window] firstResponder];
	do {
		NSLog(@"TEXTVIEW RC: %@",fr);
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

