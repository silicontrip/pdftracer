#import "QPDFOutlineView.h"

@implementation QPDFOutlineView

@synthesize relatedSegment;

/*
- (instancetype)init
{
	NSLog(@"Outline view init");  // i have a suspicion that this is never called.
	self = [super init];
	if (self)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReload:) name:@"QPDFUpdateOutlineview" object:nil];
	}
	return self;
}
*/

- (void)dataReload:(NSNotification*)n
{
	ObjcQPDFObjectHandle* qp = (ObjcQPDFObjectHandle*)[n object];
	NSDictionary* ud = [n userInfo];
	bool rc = NO;
	if (ud)
	{
		rc= [(NSNumber*)[ud valueForKey:@"reloadChildren"] boolValue];
	//	NSLog(@"User Info present, reload: %d",rc);
	}

	if (qp)
	{
	//	NSLog(@"Reloading: %@",qp);
		[self reloadItem:qp reloadChildren:rc];
		// [self reloadItem:[qp parent] reloadChildren:rc];
	} else {
		[self reloadData];
	}
	
}

- (void)print:(id)sender
{
	[[self nextResponder] print:sender];
}

- (BOOL)acceptsFirstResponder
{
	[super acceptsFirstResponder];
	return YES;
}
/*
- (BOOL)becomeFirstResponder
{
	[super becomeFirstResponder];
	
	NSResponder* fr = [[self window] firstResponder];
	do {
		NSLog(@"OUTLINEVIEW ResChain: %@",fr);
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
