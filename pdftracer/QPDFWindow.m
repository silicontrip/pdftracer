#import "QPDFWindow.h"

@implementation QPDFWindow



-(void)editorEnabled:(BOOL)ena
{
	[tView setEditable:ena];
}

-(void)setDocument:(PDFDocument*)pdf
{
	[dView setDocument:pdf];
}

-(void)setText:(NSString*)text
{
	[tView setString:text];

}

-(void)setFont:(NSFont*)font
{
	
	tfont = font;
	[tView setFont:tfont];  // user prefs

	// [tfont retain];  // but how does it release
}

-(NSTextView*)textView
{
	return tView;
}

-(NSString*)text
{
	return [tView string];
}

-(void)addEnabled:(BOOL)ena forIndex:(int)index
{
	[segments[index] setEnabled:ena forSegment:0];
}

-(void)removeEnabled:(BOOL)ena forIndex:(int)index
{
	[segments[index] setEnabled:ena forSegment:1];
}

-(QPDFOutlineView*)outlineAtIndex:(NSInteger)index
{
	if (index>=0 && index<=2)
		return outlines[index];
	return nil;
}

-(NSSplitView*)splitAtIndex:(int)index
{
	if (index==0 || index==1)
		return sView[index];
	
	return nil;
}

-(void)updateOutline:(NSOutlineView*)ov forNode:(QPDFNode*)nn
{
	
	NSLog(@"this Node: %@",nn);
	QPDFNode * pp = [nn parentNode];
	NSLog(@"OutlineView: %@ parentQPDFNode: %@",ov,pp);
	
	[ov reloadItem:nn];

//	while (nn != nil)
//	{
//		NSLog(@"getting parent of %@",nn);
//		pp =[nn parentNode];
//		NSLog(@"OutlineView: %@ parentQPDFNode: %@",ov,pp);
//		[ov reloadItem:nn];
//
//		nn = [nn parentNode];
//	}
 
}
/*
-(void)updateAllOutlines:(QPDFNode *)node
{
	NSLog(@"update all: %@",node);

	if (node != nil)
	{
		[outlines[0] reloadItem:node reloadChildren:NO];
	//	if ([node parentNode] != nil)
	//		[outlines[0] reloadItem:[node parentNode] reloadChildren:NO];

		[outlines[1] reloadItem:nil reloadChildren:NO];
		// object view doesn't have the parent you're looking for
	//	if ([node parentNode] != nil)
	//		[outlines[1] reloadItem:[node parentNode] reloadChildren:NO];

		[outlines[2] reloadItem:node reloadChildren:NO];
		if ([node parentNode] != nil)
			[outlines[1] reloadItem:[node parentNode] reloadChildren:NO];

	}
}
*/
-(void)invalidateAll
{
	// NSLog(@"QPDFWindow Invalidate All");

	[(OutlineQPDF*)[outlines[0] dataSource] invalidate]; [outlines[0] reloadData];
	[(OutlineQPDFPage*)[outlines[2] dataSource] invalidate]; [outlines[2] reloadData];
	[(OutlineQPDFObj*)[outlines[1] dataSource] invalidate]; [outlines[1] reloadData];
	
}

+(NSSegmentedControl*)addRemoveSegment
{
	NSSegmentedControl* oSegment = [[NSSegmentedControl alloc] init];
	[oSegment setSegmentStyle:NSSegmentStyleSmallSquare];
	[oSegment setSegmentCount:3];
	[oSegment setImage:[NSImage imageNamed:NSImageNameAddTemplate] forSegment:0];
	[oSegment setImage:[NSImage imageNamed:NSImageNameRemoveTemplate] forSegment:1];
	[oSegment setTrackingMode:NSSegmentSwitchTrackingMomentary];
	[oSegment setWidth:32 forSegment:0];
	[oSegment setWidth:32 forSegment:1];
	[oSegment setEnabled:NO forSegment:1];
	[oSegment setEnabled:NO forSegment:2];
	[oSegment setTarget:nil];
	[oSegment setAction:@selector(addRemove:)];
	return oSegment;
}

+(NSScrollView*)hvScrollView:(NSView*)doc
{
	NSScrollView* scView = [[[NSScrollView alloc] init] autorelease];
	[scView setHasVerticalScroller:YES];
	[scView setHasHorizontalScroller:YES];
	[scView setDocumentView:doc];
	
	return scView;
}

+(NSStackView*)stackScroll:(NSView*)scroll andSegment:(NSView*)seg
{
	NSStackView* scsView = [[NSStackView alloc] init];
	[scsView setOrientation:NSUserInterfaceLayoutOrientationVertical];
	[scsView setAlignment:NSLayoutAttributeLeading];
	[scsView addView:scroll inGravity:NSStackViewGravityLeading];
	[scsView addView:seg inGravity:NSStackViewGravityLeading];
	return scsView;
}

+(NSTextView*)textEditorView
{
	
	NSFont* tfont = [NSFont fontWithName:@"AndaleMono" size:11]; // prefs...
	
	NSRect vRect = NSZeroRect; // Err maybe because initWithFrame, needs a frame?
	
	// See NSRulerView
	
	NSTextView *tView = [[NSTextView alloc] initWithFrame:vRect];
	[tView setTextContainerInset:NSMakeSize(8.0, 8.0)];
	[tView setEditable:NO];
	[tView setRichText:NO];
	[tView setAllowsUndo:YES];
	[tView setSelectable:YES];
	[tView setUsesRuler:YES];
	[tView setRulerVisible:YES];
	
	[tView setFont:tfont];  // user prefs
	[tView setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
	
	return tView;
}

-(instancetype)initWithContentRect:(NSRect)rect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backing
{
	self = [super initWithContentRect:rect styleMask:style backing:backing defer:NO];

	if (self)
	{
		// Outline View Columns

		outlines[0] = [OutlineQPDF newView];
		outlines[1] = [OutlineQPDFObj newView];
		outlines[2] = [OutlineQPDFPage newView];
	
		segments[0] = [QPDFWindow addRemoveSegment];
		NSScrollView* scView = [QPDFWindow hvScrollView:outlines[0]];
		NSStackView* scsView = [QPDFWindow stackScroll:scView andSegment:segments[0]];
		
		segments[1] = [QPDFWindow addRemoveSegment];
		NSScrollView* socView = [QPDFWindow hvScrollView:outlines[1]];
		NSStackView* socsView = [QPDFWindow stackScroll:socView andSegment:segments[1]];

		segments[2] = [QPDFWindow addRemoveSegment];
		NSScrollView* spcView = [QPDFWindow hvScrollView:outlines[2]];
		NSStackView* spcsView = [QPDFWindow stackScroll:spcView andSegment:segments[2]];

		// unused constraints, maybe
		// [[oSegment widthAnchor] constraintEqualToAnchor:[scView widthAnchor]],
		// [[oSegment leadingAnchor] constraintEqualToAnchor:[scView leadingAnchor]],
		
		[NSLayoutConstraint activateConstraints:@[
												  [[segments[0] topAnchor] constraintEqualToAnchor:[scView bottomAnchor]],
												  [[segments[0] trailingAnchor] constraintEqualToAnchor:[scsView trailingAnchor]],
												  [[scView widthAnchor] constraintEqualToAnchor:[scsView widthAnchor]],
												  [[segments[1] topAnchor] constraintEqualToAnchor:[socView bottomAnchor]],
												  [[segments[1] trailingAnchor] constraintEqualToAnchor:[socsView trailingAnchor]],
												  [[socView widthAnchor] constraintEqualToAnchor:[socsView widthAnchor]],
												  [[segments[2] topAnchor] constraintEqualToAnchor:[spcView bottomAnchor]],
												  [[segments[2] trailingAnchor] constraintEqualToAnchor:[spcsView trailingAnchor]],
												  [[spcView widthAnchor] constraintEqualToAnchor:[spcsView widthAnchor]],
												  ]];
		

		
		tView = [QPDFWindow textEditorView];

		NSScrollView* sctView = [[[NSScrollView alloc] init] autorelease];
		[sctView setHasVerticalScroller:YES];
		[sctView setDocumentView:tView];
		
		dView = [[[PDFView alloc] init] autorelease];
		[dView setDisplayMode:kPDFDisplaySinglePage];

		NSRect vRect = NSZeroRect; // Err maybe because initWithFrame, needs a frame?

		sView[1]=[[[NSSplitView alloc] initWithFrame:vRect] autorelease];
		[sView[1] setVertical:NO];
		[sView[1] addArrangedSubview:scsView];
		[sView[1] addArrangedSubview:socsView];
		[sView[1] addArrangedSubview:spcsView];
		[sView[1] setPostsFrameChangedNotifications:YES];

		// and the windows windows
		sView[0]=[[[NSSplitView alloc] initWithFrame:vRect] autorelease];
		[sView[0] setVertical:YES];
		[sView[0] addArrangedSubview:sView[1]];
		[sView[0] addArrangedSubview:sctView];
		[sView[0] addArrangedSubview:dView];

		NSWindowCollectionBehavior behavior = [self collectionBehavior];
		behavior |= NSWindowCollectionBehaviorFullScreenPrimary;
		[self setCollectionBehavior:behavior];
		[self setContentView:sView[0]];
		[self orderFrontRegardless];
	}
	return self;
}



@end
