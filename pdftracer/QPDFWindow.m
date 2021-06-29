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

/* Use NSNotification */
-(void)updateOutline:(NSOutlineView*)ov forHandle:(ObjcQPDFObjectHandle*)nn
{
	
	NSLog(@"this Node: %@",nn);
	ObjcQPDFObjectHandle * pp = [nn parent];
	NSLog(@"OutlineView: %@ parentQPDFNode: %@",ov,pp);
	
	[ov reloadItem:nn];
}

/*
-(void)outlineNodeChanged:(NSNotification *)notification
{
	QPDFNode* nn = [notification object];
	QPDFNode* pp = [nn parentNode];

	// get all the outlines
}
*/

// Should move all these static UI creators to their own class.

+(NSSegmentedControl*)addRemoveSegmentWithMenu:(BOOL)menu
{
	NSSegmentedControl* oSegment = [[NSSegmentedControl alloc] init];
	[oSegment setTranslatesAutoresizingMaskIntoConstraints:NO];
	QPDFSegmentedCell* csell = [[[QPDFSegmentedCell alloc] init] autorelease];
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
		NSMenu *myMenu = [[NSMenu new] autorelease];

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
	NSStackView* scsView = [[[NSStackView alloc] init] autorelease];
	scsView.translatesAutoresizingMaskIntoConstraints = NO;
	scsView.spacing = 0.0;
	
	[scsView setOrientation:NSUserInterfaceLayoutOrientationVertical];
	[scsView setAlignment:NSLayoutAttributeLeading];
	[scsView addView:scroll inGravity:NSStackViewGravityLeading];
	[scsView addView:seg inGravity:NSStackViewGravityLeading];
	return scsView;
}

+(QPDFTextView*)textEditorView // WithContainer:(NSTextContainer*)tCon
{
	
	NSRect vRect = NSZeroRect; // Err maybe because initWithFrame, needs a frame?
	
	// See NSRulerView
	// NSTextView *tView = [[[NSTextView alloc] initWithFrame:vRect textContainer:tCon] autorelease];
	
	QPDFTextView *tView = [[[QPDFTextView alloc] initWithFrame:vRect] autorelease];

	// [tView setTranslatesAutoresizingMaskIntoConstraints:NO];

	[tView setTextContainerInset:NSMakeSize(8.0, 8.0)];
	[tView setEditable:NO];  // custom to indicate un editable PDF object
	[tView setRichText:NO];
	[tView setAllowsUndo:YES];
	[tView setSelectable:YES];
	
	[tView setHorizontallyResizable:YES];
	[tView setVerticallyResizable:YES];
	[tView setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
	
	tView.usesFindBar=YES;
	
	return tView;
}

-(instancetype)initWithContentRect:(NSRect)rect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backing notificationCenter:(NSNotificationCenter*)centre
{
	self = [super initWithContentRect:rect styleMask:style backing:backing defer:NO];

	if (self)
	{
		// Outline View Columns

		outlines[0] = [OutlineQPDF newView];
		outlines[1] = [OutlineQPDFObj newView];
		outlines[2] = [OutlineQPDFPage newView];
	
		[centre addObserver:outlines[0] selector:@selector(dataReload:) name:@"QPDFUpdateOutlineview" object:nil];
		[centre addObserver:outlines[1] selector:@selector(dataReload:) name:@"QPDFUpdateOutlineview" object:nil];
		[centre addObserver:outlines[2] selector:@selector(dataReload:) name:@"QPDFUpdateOutlineview" object:nil];

		segments[0] = [QPDFWindow addRemoveSegmentWithMenu:YES];
		outlines[0].relatedSegment = segments[0];
		[segments[0] setTag:0];
		
		NSScrollView* scView = [QPDFWindow hvScrollView:outlines[0]];
		NSStackView* scsView = [QPDFWindow stackScroll:scView andSegment:segments[0]];

		segments[1] = [QPDFWindow addRemoveSegmentWithMenu:YES];
		outlines[1].relatedSegment = segments[1];
		[segments[1] setTag:1];

		NSScrollView* socView = [QPDFWindow hvScrollView:outlines[1]];
		NSStackView* socsView = [QPDFWindow stackScroll:socView andSegment:segments[1]];

		segments[2] = [QPDFWindow addRemoveSegmentWithMenu:NO];
		outlines[2].relatedSegment = segments[2];
		[segments[2] setTag:2];

		NSScrollView* spcView = [QPDFWindow hvScrollView:outlines[2]];
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
		
		self.textFont = [NSFont fontWithName:@"AndaleMono" size:12]; // prefs...
		self.textView = [QPDFWindow textEditorView]; // WithContainer:self.textContainer];
		
		NSColor* backGround = [NSColor colorWithRed:0.157 green:0.169 blue:0.208 alpha:1.0];  // more prefs
		
		[self.textView setBackgroundColor:backGround];
		[self.textView setTextColor:[NSColor whiteColor]];
		[self.textView setInsertionPointColor:[NSColor whiteColor]];
		[self.textView setFont:self.textFont];
		[self.textView setDrawsBackground:YES];
		[self.textView setPostsBoundsChangedNotifications:YES];

		self.scrollTextView = [[[NSScrollView alloc] init] autorelease];
		self.scrollTextView.translatesAutoresizingMaskIntoConstraints = NO;

		[self.scrollTextView setHasVerticalScroller:YES];
		[self.scrollTextView setDocumentView:self.textView];
		
		NoodleLineNumberView* nln = [[[NoodleLineNumberView alloc] initWithScrollView:self.scrollTextView] autorelease];
		
		//NSColor* backGround = [NSColor colorWithRed:0.157 green:0.169 blue:0.208 alpha:1.0];  // more prefs

		[nln setBackgroundColor:backGround];
		[nln setTextColor:[NSColor whiteColor]];
		[nln setAlternateTextColor:[NSColor grayColor]];
		 
		
		[self.scrollTextView setVerticalRulerView:nln];
		self.scrollTextView.hasVerticalRuler=YES;
		self.scrollTextView.rulersVisible = YES;
		
	//	[[self.scrollTextView contentView] setPostsFrameChangedNotifications:YES];
		
		self.documentView = [[[QPDFView alloc] init] autorelease];
		// [self.documentView setTranslatesAutoresizingMaskIntoConstraints:NO];

	//	[self.documentView setDisplayMode:kPDFDisplaySinglePage];

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
		[sView[0] addArrangedSubview:self.scrollTextView];
		[sView[0] addArrangedSubview:self.documentView];
		
		[sView[1] adjustSubviews];
		[sView[0] adjustSubviews];

		
		NSWindowCollectionBehavior behavior = [self collectionBehavior];
		behavior |= NSWindowCollectionBehaviorFullScreenPrimary;
		[self setCollectionBehavior:behavior];
		[self setContentView:sView[0]];
		[self orderFrontRegardless];
	}
	
	return self;
}

- (void)dealloc
{
	[textContainer release];
	[documentView release];
	[layout release];
	[textFont release];
	[textView release];

	[_scrollTextView release];
	[super dealloc];
}

- (void)mouseDown:(NSEvent *)event
{
	
	NSLog(@"Window Mouse Down: %@",event);
	
}

/*
- (BOOL)respondsToSelector:(SEL)aSelector
{
 	NSString* selstr =NSStringFromSelector(aSelector);

	NSSet* ignore = [NSSet setWithArray:@[@"_installTrackingRect:assumeInside:userData:trackingNum:"]];
	if (![ignore containsObject:selstr])
	{
		NSLog(@"Window EVENT -> %@",NSStringFromSelector(aSelector));
		if( [QPDFWindow instancesRespondToSelector:aSelector] ) {
			// invoke the inherited method
			return YES;
		}
	}
	return [super respondsToSelector:aSelector];
}
*/



@end
