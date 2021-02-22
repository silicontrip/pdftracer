#import "QPDFWindow.h"

@implementation QPDFWindow

-(NSString*)editorText
{
	return [tView string];
}

-(void)enableEditor:(BOOL)ena
{
	[tView setEditable:ena];
}

-(void)setDocument:(PDFDocument*)pd
{
	[dView setDocument:pd];
}

-(void)setEditor:(NSString*)text
{
	[tView setString:text];
}

-(void)updateOutline:(NSOutlineView*)ov withNode:(QPDFNode*)nn
{
	
	NSLog(@"this Node: %@",nn);
	QPDFNode * pp =[nn parentNode];
	NSLog(@"OutlineView: %@ parentQPDFNode: %@",ov,pp);
	
	[ov reloadItem:nn];
	
	while (nn != nil)
	{
		NSLog(@"getting parent of %@",nn);
		pp =[nn parentNode];
		NSLog(@"OutlineView: %@ parentQPDFNode: %@",ov,pp);
		[ov reloadItem:nn];
		
		nn = [nn parentNode];
	}
}

-(void)updateAllOutlines:(QPDFNode *)node
{
	NSLog(@"update all: %@",node);
//	[self updateOutline:oView withNode:node];
	
	// [self updateOutline:ooView withNode:node];
//	[ooView reloadItem:node];

//	[self updateOutline:opView withNode:node];

	[oView reloadItem:nil reloadChildren:YES];
	[ooView reloadItem:nil reloadChildren:YES];
	[opView reloadItem:nil reloadChildren:YES];

}

-(void)invalidateAll
{
	NSLog(@"QPDFWindow Invalidate All");

	[(OutlineQPDF*)[oView dataSource] invalidate]; [oView reloadData];

	[(OutlineQPDFPage*)[opView dataSource] invalidate]; [opView reloadData];

	[(OutlineQPDFObj*)[ooView dataSource] invalidate]; [ooView reloadData];

//	[oView reloadItem:nil reloadChildren:YES];
//	[ooView reloadItem:nil reloadChildren:YES];
//	[opView reloadItem:nil reloadChildren:YES];
	
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
	[oSegment setEnabled:NO forSegment:2];
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

-(instancetype)initWithContentRect:(NSRect)rect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backing
{
	self = [super initWithContentRect:rect styleMask:style backing:backing defer:NO];

	if (self)
	{
		// Outline View Columns

		oView = [OutlineQPDF newView];
		ooView = [OutlineQPDFObj newView];
		opView = [OutlineQPDFPage newView];
	
		oSegment = [QPDFWindow addRemoveSegment];
		NSScrollView* scView = [QPDFWindow hvScrollView:oView];
		NSStackView* scsView = [QPDFWindow stackScroll:scView andSegment:oSegment];
		

		
		ooSegment = [QPDFWindow addRemoveSegment];
		NSScrollView* socView = [QPDFWindow hvScrollView:ooView];
		NSStackView* socsView = [QPDFWindow stackScroll:socView andSegment:ooSegment];

		opSegment = [QPDFWindow addRemoveSegment];
		NSScrollView* spcView = [QPDFWindow hvScrollView:opView];
		NSStackView* spcsView = [QPDFWindow stackScroll:spcView andSegment:opSegment];

		// unused constraints, maybe
		// [[oSegment widthAnchor] constraintEqualToAnchor:[scView widthAnchor]],
		// [[oSegment leadingAnchor] constraintEqualToAnchor:[scView leadingAnchor]],
		
		[NSLayoutConstraint activateConstraints:@[
												  [[oSegment topAnchor] constraintEqualToAnchor:[scView bottomAnchor]],
												  [[oSegment trailingAnchor] constraintEqualToAnchor:[scsView trailingAnchor]],
												  [[scView widthAnchor] constraintEqualToAnchor:[scsView widthAnchor]],
												  [[ooSegment topAnchor] constraintEqualToAnchor:[socView bottomAnchor]],
												  [[ooSegment trailingAnchor] constraintEqualToAnchor:[socsView trailingAnchor]],
												  [[socView widthAnchor] constraintEqualToAnchor:[socsView widthAnchor]],
												  [[opSegment topAnchor] constraintEqualToAnchor:[spcView bottomAnchor]],
												  [[opSegment trailingAnchor] constraintEqualToAnchor:[spcsView trailingAnchor]],
												  [[spcView widthAnchor] constraintEqualToAnchor:[spcsView widthAnchor]],
												  ]];
		
		tfont = [NSFont fontWithName:@"AndaleMono" size:11]; // prefs...

		NSRect vRect = NSZeroRect; // Err maybe because initWithFrame, needs a frame?
		
		// See NSRulerView
		
		tView = [[NSTextView alloc] initWithFrame:vRect];
		[tView setTextContainerInset:NSMakeSize(8.0, 8.0)];
		[tView setEditable:NO];
		[tView setRichText:NO];
		[tView setAllowsUndo:YES];
		[tView setSelectable:YES];
		[tView setUsesRuler:YES];
		[tView setRulerVisible:YES];


		
		[tView setFont:tfont];  // user prefs
	//	[tView setDelegate:self];
		tView.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable;

		NSScrollView* sctView = [[[NSScrollView alloc] init] autorelease];
		[sctView setHasVerticalScroller:YES];
		[sctView setDocumentView:tView];
		
		dView = [[[PDFView alloc] init] autorelease];

		soView=[[[NSSplitView alloc] initWithFrame:vRect] autorelease];
		[soView setVertical:NO];
		[soView addArrangedSubview:scsView];
		[soView addArrangedSubview:socsView];
		[soView addArrangedSubview:spcsView];
		[soView setPostsFrameChangedNotifications:YES];

		// and the windows windows
		sView=[[[NSSplitView alloc] initWithFrame:vRect] autorelease];
		[sView setVertical:YES];
		[sView addArrangedSubview:soView];
		[sView addArrangedSubview:sctView];
		[sView addArrangedSubview:dView];

		NSWindowCollectionBehavior behavior = [self collectionBehavior];
		behavior |= NSWindowCollectionBehaviorFullScreenPrimary;
		[self setCollectionBehavior:behavior];
		[self setContentView:sView];
		[self orderFrontRegardless];
	}
	return self;
}

-(void)setDataSource
{
	QPDFWindowController* nwc = [self windowController];
	QPDFDocument* qp = [nwc document];
	
	pdfDS = [[OutlineQPDF alloc] initWithPDF:[qp doc]];
	objDS = [[OutlineQPDFObj alloc] initWithPDF:[qp doc]];
	pageDS = [[OutlineQPDFPage alloc] initWithPDF:[qp doc]];
	
	
	[oView setDataSource:pdfDS];
	[ooView setDataSource:objDS];
	[opView setDataSource:pageDS];
	
	[tView setDelegate:nwc];

	pDoc = [qp pdfdocument];
	[dView setDocument:pDoc];
	[dView setDisplayMode:kPDFDisplaySinglePage];
	
	NSString* documentName = [qp displayName];
	
	[soView setAutosaveName:[NSString stringWithFormat:@"SplitOutline-%@",documentName]];
	[sView setAutosaveName:[NSString stringWithFormat:@"SplitMain-%@",documentName]];
	
	[self setFrameAutosaveName:[NSString stringWithFormat:@"MainWindow-%@",documentName]];

	
	NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];

	[dc addObserver:nwc selector:@selector(textDidEndEditing:) name:@"NSControlTextDidEndEditingNotification" object:oView];
	[dc addObserver:nwc selector:@selector(textDidEndEditing:) name:@"NSControlTextDidEndEditingNotification" object:ooView];
	[dc addObserver:nwc selector:@selector(textDidEndEditing:) name:@"NSControlTextDidEndEditingNotification" object:opView];
	
	// [dc addObserver:nwc selector:@selector(changeNotification:) name:NSOutlineViewSelectionDidChangeNotification object:oView];
	
	[dc addObserver:nwc selector:@selector(changeNotification:) name:@"NSOutlineViewSelectionDidChangeNotification" object:oView];
	[dc addObserver:nwc selector:@selector(changeNotification:) name:@"NSOutlineViewSelectionDidChangeNotification" object:ooView];
	[dc addObserver:nwc selector:@selector(changeNotification:) name:@"NSOutlineViewSelectionDidChangeNotification" object:opView];
}

@end
