#import "QPDFWindow.h"

@implementation QPDFWindow

-(void)editorEnabled:(BOOL)ena
{
	[self.textView setEditable:ena];
}

-(void)setDocument:(PDFDocument*)pdf
{
	[self.documentView setDocument:pdf];
}

-(void)setText:(NSString*)text
{
	if (text)
		[self.textView setString:text];
}

-(void)setFont:(NSFont*)font
{
	
	self.textFont = font;
	[self.textView setFont:self.textFont];  // user prefs

	// [tfont retain];  // but how does it release
}

/*
-(NSTextView*)self.textView
{
	return textView;
}
*/

-(NSString*)text
{
	return [self.textView string];
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
	[oSegment setTranslatesAutoresizingMaskIntoConstraints:NO];
	QPDFSegmentedCell* csell = [[QPDFSegmentedCell alloc] init];
	oSegment.cell = csell;
	
//	oSegment.cellClass = [QPDFSegmentedCell class];

	NSArray* newTypes = @[@"Null",@"Bool",@"Integer",
						  @"Real",@"String",@"Name",
						  @"Array",@"Dictionary"];
	
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
	
	// TEST CODE
	NSMenu *myMenu = [NSMenu new];

	//[NSUserDefault setConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints];
	
	// NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints to YES to have -[NSWindow visualizeConstraints:]
	
	NSMenuItem *mi;
	//loop item
	NSInteger tagNo = 2;
	for (NSString* menuString in newTypes)
	{
		mi = [[NSMenuItem new] autorelease];
		[mi setTitle:menuString];
		[mi setEnabled:YES];
		[mi setTarget:nil];
		[mi setAction:@selector(addType:)];
		[mi setTag:tagNo++];
		[myMenu addItem:mi];
	}
	
	
	[myMenu setAutoenablesItems:YES];

	[oSegment setMenu:myMenu forSegment:0];
	[oSegment setShowsMenuIndicator:YES forSegment:0];
	[oSegment setAutoresizesSubviews:YES];
	

	// Class=[QPDFSegmentedCell class];
	
	
	
//	[oSegment setCell];
	
	return oSegment;
}

+(NSScrollView*)hvScrollView:(NSView*)doc
{
	NSScrollView* scView = [[[NSScrollView alloc] init] autorelease];
	[scView setTranslatesAutoresizingMaskIntoConstraints:NO];

	[scView setHasVerticalScroller:YES];
	[scView setHasHorizontalScroller:YES];
	[scView setDocumentView:doc];
	
	return scView;
}

+(NSStackView*)stackScroll:(NSView*)scroll andSegment:(NSView*)seg
{
	NSStackView* scsView = [[NSStackView alloc] init];
	scsView.translatesAutoresizingMaskIntoConstraints = NO;
	scsView.spacing = 0.0;
	
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
	//[tView setTranslatesAutoresizingMaskIntoConstraints:NO];

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
		outlines[0].relatedSegment = segments[0];
		
		NSScrollView* scView = [QPDFWindow hvScrollView:outlines[0]];
		//scView.translatesAutoresizingMaskIntoConstraints = NO;
		NSStackView* scsView = [QPDFWindow stackScroll:scView andSegment:segments[0]];
		// scsView.translatesAutoresizingMaskIntoConstraints = NO;

		segments[1] = [QPDFWindow addRemoveSegment];
		outlines[1].relatedSegment = segments[1];

		NSScrollView* socView = [QPDFWindow hvScrollView:outlines[1]];
		//socView.translatesAutoresizingMaskIntoConstraints = NO;

		NSStackView* socsView = [QPDFWindow stackScroll:socView andSegment:segments[1]];
		// socsView.translatesAutoresizingMaskIntoConstraints = NO;

		segments[2] = [QPDFWindow addRemoveSegment];
		outlines[2].relatedSegment = segments[2];

		NSScrollView* spcView = [QPDFWindow hvScrollView:outlines[2]];
		// spcView.translatesAutoresizingMaskIntoConstraints = NO;

		NSStackView* spcsView = [QPDFWindow stackScroll:spcView andSegment:segments[2]];
		// spcsView.translatesAutoresizingMaskIntoConstraints = NO;

		// unused constraints, maybe
		// [[oSegment widthAnchor] constraintEqualToAnchor:[scView widthAnchor]],
		// [[oSegment leadingAnchor] constraintEqualToAnchor:[scView leadingAnchor]],
	

		// scsView : Outline StackView
		// scView : Outline ScrollView
		// outlines[0] : Outline OutlineView
		
		// outlines[1] : Object OutlineView
		// socView : Object Scroll
		// socsView : object Stack
		
		// outlines[2] : Page Outline
		// spcView : Page Scroll
		// spcsView : Page Stack
		
		[NSLayoutConstraint activateConstraints:@[
												  [[segments[0] topAnchor] constraintEqualToAnchor:[scView bottomAnchor]],
												  [[segments[0] trailingAnchor] constraintEqualToAnchor:[scsView trailingAnchor]],
												  [[scView widthAnchor] constraintEqualToAnchor:[scsView widthAnchor]],
												  [[segments[1] topAnchor] constraintEqualToAnchor:[socView bottomAnchor]],
												  [[segments[1] trailingAnchor] constraintEqualToAnchor:[socsView trailingAnchor]],
												  [[socView widthAnchor] constraintEqualToAnchor:[socsView widthAnchor]],
												  [[segments[2] topAnchor] constraintEqualToAnchor:[spcView bottomAnchor]],
												  [[segments[2] trailingAnchor] constraintEqualToAnchor:[spcsView trailingAnchor]],
												  [[spcView widthAnchor] constraintEqualToAnchor:[spcsView widthAnchor]]
												  ]];

		self.textView = [QPDFWindow textEditorView];

		NSScrollView* sctView = [[[NSScrollView alloc] init] autorelease];
		sctView.translatesAutoresizingMaskIntoConstraints = NO;

		[sctView setHasVerticalScroller:YES];
		[sctView setDocumentView:self.textView];
		
		self.documentView = [[[PDFView alloc] init] autorelease];
		[self.documentView setTranslatesAutoresizingMaskIntoConstraints:NO];

		[self.documentView setDisplayMode:kPDFDisplaySinglePage];

		NSRect vRect = NSZeroRect; // Err maybe because initWithFrame, needs a frame?

		sView[1]=[[[NSSplitView alloc] initWithFrame:vRect] autorelease];
		[sView[1] setTranslatesAutoresizingMaskIntoConstraints:NO];
		[sView[1] setVertical:NO];
		[sView[1] addArrangedSubview:scsView];
		[sView[1] addArrangedSubview:socsView];
		[sView[1] addArrangedSubview:spcsView];
		[sView[1] setPostsFrameChangedNotifications:YES];

		// and the windows windows
		sView[0]=[[[NSSplitView alloc] initWithFrame:vRect] autorelease];
		[sView[0] setTranslatesAutoresizingMaskIntoConstraints:NO];

		[sView[0] setVertical:YES];
		[sView[0] addArrangedSubview:sView[1]];
		[sView[0] addArrangedSubview:sctView];
		[sView[0] addArrangedSubview:self.documentView];

		NSWindowCollectionBehavior behavior = [self collectionBehavior];
		behavior |= NSWindowCollectionBehaviorFullScreenPrimary;
		[self setCollectionBehavior:behavior];
		[self setContentView:sView[0]];
		[self orderFrontRegardless];
	}
	
	return self;
}



@end
