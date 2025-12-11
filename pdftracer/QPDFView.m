#import "QPDFView.h"


// So we can handle special PDF Document UI stuff.
// and so we can ignore regular PDF Document UI stuff.
// it goes ding.

@implementation QPDFView

// @synthesize relatedSegment;

- (void)mouseDown:(NSEvent*)event
{
	NSLog(@"we have a mouse down. Repeat, a mouse is down");

	PDFPage *currentPage = [self currentPage];

	//NSRect boundsBox = self.bounds;
	// NSRect boundsBox = [currentPage bounds];
	//NSRect cropBox = [currentPage boundsForBox:kPDFDisplayBoxCropBox];
	//NSRect artBox = [currentPage boundsForBox:kPDFDisplayBoxArtBox];

	//NSRect iBounds = self.documentView.bounds;
	//CGFloat iScale = self.documentView.scale;

	//NSLog(@": docview:%@ viewbounds:%@",NSStringFromRect(iBounds),NSStringFromRect(boundsBox));

	PDFDestination* cDest = [self currentDestination];

	NSLog(@"Point: %@ zoom %f",NSStringFromPoint([cDest point]),[cDest zoom]);


	//CGRect displayBox = self.displayBox;
	//CGRect bounds = self.bounds;
	//calculate current zoom level
	//float zoom = bounds.size.width / displayBox.size.width;
	//calculate current view position
	//CGPoint position = CGPointMake(displayBox.origin.x - currentPage.boundsForBox(kPDFDisplayBoxMediaBox).origin.x, displayBox.origin.y - currentPage.boundsForBox(kPDFDisplayBoxMediaBox).origin.y);

	CGFloat scale = [self scaleFactor];

	NSLog(@"%@\n scale : %f",event,scale);
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
- (BOOL)extendedRootViewBounds {
	if (self) {
	//return [super extendedRootViewBounds];


	return YES;
	}
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

