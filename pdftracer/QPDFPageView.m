#import "QPDFPageView.h"

@implementation QPDFPageView

@synthesize pdfDocument;

-(void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
	NSLog(@"[QPDFPageiew drawRect:dirty: %@]",NSStringFromRect(dirtyRect));

	// CGFloat scale = self.scaleFactor;


	NSGraphicsContext* ncg = [NSGraphicsContext currentContext];
	CGContextRef cg = [ncg CGContext];
	
	NSAffineTransform* xform = [NSAffineTransform transform];

	[xform scaleXBy:1.1 yBy:1.1];
	[xform concat];
	
	[[NSColor whiteColor] setFill];
	
	[[NSBezierPath bezierPathWithRect:dirtyRect] fill];
	

	PDFPage* pp = [pdfDocument pageAtIndex:0];

	NSRect displayBox = [pp boundsForBox:kPDFDisplayBoxMediaBox];
	NSRect cropBox = [pp boundsForBox:kPDFDisplayBoxCropBox];

	NSLog(@"display: %@ crop: %@",NSStringFromRect(displayBox),NSStringFromRect(cropBox));

	[pp drawWithBox:kPDFDisplayBoxMediaBox toContext:cg];
	
}

-(void)mouseDown:(NSEvent*)ev
{
	NSAffineTransform* xform = [NSAffineTransform transform];
	
	[xform scaleXBy:M_SQRT2 yBy:M_SQRT2];
	[xform concat];
	[self display];
}

-(void)dealloc
{
	[pdfDocument release];
	[super dealloc];
}


@end

