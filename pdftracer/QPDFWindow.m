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
		pp =[nn parentNode];
		NSLog(@"OutlineView: %@ parentQPDFNode: %@",ov,pp);
		[ov reloadItem:nn];
		
		nn = [nn parentNode];
	}
}

-(void)updateAllOutlines:(QPDFNode *)node
{
	NSLog(@"update all: %@",node);
	[self updateOutline:oView withNode:node];
	[self updateOutline:ooView withNode:node];
	[self updateOutline:opView withNode:node];

}
-(instancetype)initWithContentRect:(NSRect)rect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backing
{
	self = [super initWithContentRect:rect styleMask:style backing:backing defer:NO];

	if (self)
	{
		// Outline View Columns

		oView = [OutlineQPDF newView];
		ooView = [OutlinePDFObj newView];
		opView = [OutlinePDFPage newView];

		NSScrollView* scView = [[[NSScrollView alloc] init] autorelease];
		[scView setHasVerticalScroller:YES];
		[scView setHasHorizontalScroller:YES];
		[scView setDocumentView:oView];

		NSScrollView* socView = [[[NSScrollView alloc] init] autorelease];
		[socView setHasVerticalScroller:YES];
		[socView setHasHorizontalScroller:YES];
		[socView setDocumentView:ooView];

		NSScrollView* spcView = [[[NSScrollView alloc] init] autorelease];
		[spcView setHasVerticalScroller:YES];
		[spcView setHasHorizontalScroller:YES];
		[spcView setDocumentView:opView];

		tfont = [NSFont fontWithName:@"AndaleMono" size:11]; // prefs...

		NSRect vRect = NSZeroRect; // Err maybe because initWithFrame, needs a frame?
		
		// See NSRulerView
		
		tView = [[NSTextView alloc] initWithFrame:vRect];
		[tView setTextContainerInset:NSMakeSize(8.0, 8.0)];
		[tView setEditable:NO];
		tView.richText = NO;
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
		[soView addArrangedSubview:scView];
		[soView addArrangedSubview:socView];
		[soView addArrangedSubview:spcView];
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
	objDS = [[OutlinePDFObj alloc] initWithPDF:[qp doc]];
	pageDS = [[OutlinePDFPage alloc] initWithPDF:[qp doc]];
	
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
