#import "QPDFWindow.h"

@implementation QPDFWindow

@synthesize textContainer;
@synthesize layout;
@synthesize textView;
@synthesize documentView;
@synthesize textFont;

-(void)editorEnabled:(BOOL)ena
{
	[self.textView setEditable:ena];
}

-(void)setDocument:(PDFDocument*)pdf
{
	[self.documentView setDocument:pdf];
}

/*
-(void)setText:(NSString*)text
{
	NSLog(@"%@",[[self.textView textStorage] string]);
	if (text)
		[[self.textView textStorage] setString:text];
	//	[self.textView setString:text];
}


-(void)setFont:(NSFont*)font
{
	self.textFont = font;
	[[self.textView textStorage] setFont:font];  // user prefs
	// heres hoping textView has a strong reference.
	// [tfont retain];  // but how does it release
}
*/
/*
-(NSFont*)textFont
{
	return textFont;
}
*/
/*
-(NSString*)text
{
	return [self.textView string];
}
*/
-(void)addEnabled:(BOOL)ena forIndex:(int)index
{
	[segments[index] setEnabled:ena forSegment:0];
}

-(void)removeEnabled:(BOOL)ena forIndex:(int)index
{
	[segments[index] setEnabled:ena forSegment:1];
}

-(NSSegmentedControl*)segmentAtIndex:(NSInteger)index
{
	if (index>=0 && index<=2)
		return segments[index];
	return nil;

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
}

+(NSSegmentedControl*)addRemoveSegmentWithMenu:(BOOL)menu
{
	NSSegmentedControl* oSegment = [[NSSegmentedControl alloc] init];
	[oSegment setTranslatesAutoresizingMaskIntoConstraints:NO];
	QPDFSegmentedCell* csell = [[QPDFSegmentedCell alloc] init];
	oSegment.cell = csell;
	
	NSArray* newTypes = @[@"Null",@"Bool",@"Integer",
						  @"Real",@"String",@"Name",
						  @"Array",@"Dictionary",@"Stream"];
	
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
	if (menu) {
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
	}
	
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
/*
+(NSTextContainer*)textContainer
{
	NSSize sz = NSMakeSize(0,0);
	NSTextContainer* ts = [[[NSTextContainer alloc] initWithContainerSize:sz] autorelease];
	
	
}
*/
//+(NSTextView*)textEditorViewWithFont:(NSFont*)tfont container:(NSTextContainer*)tCon
+(NSTextView*)textEditorViewWithContainer:(NSTextContainer*)tCon

{
	
	NSRect vRect = NSZeroRect; // Err maybe because initWithFrame, needs a frame?
	
	// See NSRulerView
	
	NSTextView *tView = [[[NSTextView alloc] initWithFrame:vRect textContainer:tCon] autorelease];
	//[tView setTranslatesAutoresizingMaskIntoConstraints:NO];

	[tView setTextContainerInset:NSMakeSize(8.0, 8.0)];
	[tView setEditable:NO];
	[tView setRichText:NO];
	[tView setAllowsUndo:YES];
	[tView setSelectable:YES];
	
	//[tView setUsesRuler:YES];
	//[tView setRulerVisible:YES];
	
	// [tView setFont:tfont];  // user prefs
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
	
		segments[0] = [QPDFWindow addRemoveSegmentWithMenu:YES];
		outlines[0].relatedSegment = segments[0];
		[segments[0] setTag:0];
		
		NSScrollView* scView = [QPDFWindow hvScrollView:outlines[0]];
		// scView.translatesAutoresizingMaskIntoConstraints = NO;
		NSStackView* scsView = [QPDFWindow stackScroll:scView andSegment:segments[0]];
		// scsView.translatesAutoresizingMaskIntoConstraints = NO;

		segments[1] = [QPDFWindow addRemoveSegmentWithMenu:YES];
		outlines[1].relatedSegment = segments[1];
		[segments[1] setTag:1];

		NSScrollView* socView = [QPDFWindow hvScrollView:outlines[1]];
		//socView.translatesAutoresizingMaskIntoConstraints = NO;

		NSStackView* socsView = [QPDFWindow stackScroll:socView andSegment:segments[1]];
		// socsView.translatesAutoresizingMaskIntoConstraints = NO;

		segments[2] = [QPDFWindow addRemoveSegmentWithMenu:NO];
		outlines[2].relatedSegment = segments[2];
		[segments[2] setTag:2];

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

		NSSize sz = NSMakeSize(0,FLT_MAX);
		NSTextContainer* tc =  [[NSTextContainer alloc] initWithContainerSize:sz];
		self.textContainer = tc;

		/*
		[NSLayoutConstraint activateConstraints:@[
												  [[tc leadingAnchor]]
												  ]];
		*/
		self.layout = [[NSLayoutManager alloc] init];
		[self.layout addTextContainer:self.textContainer];
		
		self.textFont = [NSFont fontWithName:@"AndaleMono" size:11]; // prefs...
		self.textView = [QPDFWindow textEditorViewWithContainer:self.textContainer];
		
		[self.textContainer setWidthTracksTextView:YES];
	//	[self.textContainer setHeightTracksTextView:YES];

		
		// [self.textView setTextStorage:textStorage];  // textStorage readonly
					   
	//	NSLog(@"text - %@ : %@",self.textView,[self.textView textStorage]);
		NSTextStorage* nts =[self.textView textStorage];
		[nts setFont:self.textFont];
		// NSLog(@"textStorage (%@)",nts);

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
