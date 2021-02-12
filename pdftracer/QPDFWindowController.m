#import "QPDFWindowController.h"

#import "OutlineQPDF.h"
#import "OutlinePDFObj.h"
#import "OutlinePDFPage.h"

@interface QPDFWindowController()
{
	

}

@end

@implementation QPDFWindowController

- (instancetype)initWithDocument:(QPDFDocument*)qp
{
	NSLog(@"QPDFWindowController initWithDocument:%@",self);
	self = [super init];
	if (self) {
		[self setDocument:qp];
		
		// Outline View Columns

		oView = [OutlineQPDF newView];
		ooView = [OutlinePDFObj newView];
		opView = [OutlinePDFPage newView];

		pdfDS = [[OutlineQPDF alloc] initWithPDF:[qp doc]];
		objDS = [[OutlinePDFObj alloc] initWithPDF:[qp doc]];
		pageDS = [[OutlinePDFPage alloc] initWithPDF:[qp doc]];
		
		[oView setDataSource:pdfDS];
		[ooView setDataSource:objDS];
		[opView setDataSource:pageDS];
		
		// scroll view, because you can't fit it all on the screen
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

		// this should also be in a scroll
		
		NSRect vRect = NSMakeRect(0,0,0,0);
		
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
		[tView setDelegate:self];
		tView.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable;
		
		NSScrollView* sctView = [[[NSScrollView alloc] init] autorelease];
		[sctView setHasVerticalScroller:YES];
		[sctView setDocumentView:tView];

		dView = [[[PDFView alloc] init] autorelease];
		pDoc = [[self document] pdfdocument];
		//NSLog(@"QPDFWindowController pdfdocument pdf : %@",pDoc);
		[dView setDocument:pDoc];

		
		NSSplitView* soView=[[[NSSplitView alloc] initWithFrame:vRect] autorelease];
		[soView setVertical:NO];
		[soView addArrangedSubview:scView];
		[soView addArrangedSubview:socView];
		[soView addArrangedSubview:spcView];
		[soView setPostsFrameChangedNotifications:YES];

		NSSplitView* sView=[[[NSSplitView alloc] initWithFrame:vRect] autorelease];
		[sView setVertical:YES];
		[sView addArrangedSubview:soView];
		[sView addArrangedSubview:sctView];
		[sView addArrangedSubview:dView];

		NSUInteger windowStyle =  NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable;
		
		[self setWindow:[[NSWindow alloc] initWithContentRect:vRect styleMask:windowStyle backing:NSBackingStoreBuffered defer:NO]];

		NSLog(@"WindowController's window:%@",[self window]);
		
		NSWindow* w =[self window];
		// [w setDelegate:self];
		NSRect forceSize = NSMakeRect(100, 100, 640, 480);  //make these sane starting values
		
		[w setFrame:forceSize display:YES];
		
		//NSRect rw = [w frame];
		
		//NSLog(@"window rect: %@)
		
		NSWindowCollectionBehavior behavior = [[self window] collectionBehavior];
		behavior |= NSWindowCollectionBehaviorFullScreenPrimary;
		[[self window] setCollectionBehavior:behavior];
		[[self window] setContentView:sView];
		[[self window] orderFrontRegardless];
		
		
	//	[[self window]  setTitle:documentName];

		NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
		
	//	[dc addObserver:self selector:@selector(selectChangeNotification:) name:@"NSViewFrameDidChangeNotification" object:oView];
	//	[dc addObserver:self selector:@selector(changeNotification:) name:@"NSViewFrameDidChangeNotification" object:ooView];
	//	[dc addObserver:self selector:@selector(changeNotification:) name:@"NSViewFrameDidChangeNotification" object:opView];
		
		[dc addObserver:self selector:@selector(textDidEndEditing:) name:@"NSControlTextDidEndEditingNotification" object:oView];
		[dc addObserver:self selector:@selector(changeNotification:) name:@"NSOutlineViewSelectionDidChangeNotification" object:oView];
		[dc addObserver:self selector:@selector(textDidEndEditing:) name:@"NSControlTextDidEndEditingNotification" object:ooView];
		[dc addObserver:self selector:@selector(changeNotification:) name:@"NSOutlineViewSelectionDidChangeNotification" object:ooView];
		[dc addObserver:self selector:@selector(textDidEndEditing:) name:@"NSControlTextDidEndEditingNotification" object:opView];
		[dc addObserver:self selector:@selector(changeNotification:) name:@"NSOutlineViewSelectionDidChangeNotification" object:opView];

		NSString *documentName =[[self document] displayName];
		
		[[self window] setFrameAutosaveName:[NSString stringWithFormat:@"MainWindow-%@",documentName]];
		[soView setAutosaveName:[NSString stringWithFormat:@"SplitOutline-%@",documentName]];
		[sView setAutosaveName:[NSString stringWithFormat:@"SplitMain-%@",documentName]];
		
	}
	return self;
}

-(void)updatePDF
{
	PDFDocument* tpDoc = [[self document] pdfdocument];
	[dView setDocument:tpDoc];
}

- (NSString*)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	return displayName;
}

- (void)textDidChange:(NSNotification *)notification
{
	QPDFNode* node = [selectedView itemAtRow:selectedRow];
	
	[self setDocumentEdited:YES];
	[[self window] setDocumentEdited:YES];
	
	NSString *editor = [tView string];
	[self replaceQPDFNode:node withString:editor];;
}

- (void)textDidEndEditing:(NSNotification*)aNotification {
	
	NSTextView * fieldEditor = [[aNotification userInfo] objectForKey:@"NSFieldEditor"];
	if (fieldEditor)
	{
		
		//	NSInteger srow = [oView selectedRow];
		//	QPDFNode* node = [oView itemAtRow:srow];
		
		QPDFNode* node = [selectedView itemAtRow:selectedRow];
		
		//	QPDFObjectHandle* qpdf = [node object];
		
		NSString * theString = [[fieldEditor textStorage] string];
		[tView setString:theString];
		
		[self replaceQPDFNode:node withString:theString];
		[self setDocumentEdited:YES];
		[[self window] setDocumentEdited:YES];

	}
}
- (void)selectChangeNotification:(NSOutlineView*)no
{
//	NSLog(@" %@",nn);

	selectedView = no;
	selectedRow = [selectedView selectedRow];
	[self changeRow:selectedRow forSource:no];
	
}
- (void)changeNotification:(NSNotification*)nn {
	
	// NSLog(@"QPDFWindowController changeNotification %@",nn);
	//NSLog(@"FR: %@",[[self window] firstResponder]);
	
	selectedView = [nn object];
	selectedRow = [selectedView selectedRow];
	[self changeRow:selectedRow forSource:selectedView];
}

- (void)changeRow:(NSInteger)row forSource:(NSOutlineView*)ov { // void QPDFWindowController::changeRow (NSInteger row, NSOutlineView* ov) {
																// for those who can't read Objective-C function definitions
	if (row >= 0)
	{
		NSString* objText;
		
		QPDFNode* node = [ov itemAtRow:row];  // QPDFNode* node = ov->itemAtRow(row);
		QPDFObjectHandleObjc* qpdf = [node object]; // QPDFObjectHandle qpdf = node->object();
		
	//	NSLog (@"obj selected %s",qpdf->getTypeName());
		if ([qpdf isStream]) {
			objText= [[[NSString alloc] initWithData:[qpdf stream] encoding:NSMacOSRomanStringEncoding ] autorelease];
				
			//	NSLog(@"=======: %@",objText);
				
				[tView setEditable:YES];
		//	} catch (QPDFExc e) {
				; // pop up alert.
		//	}
			
		} else {
			BOOL allowEdit = ![qpdf childrenContainIndirects];
			
			//		NSLog(@"set editable: %d",allowEdit);
			[tView setEditable:allowEdit];
			// NSString* objText = [NSString stringWithUTF8String:qpdf->unparse().c_str()];
			objText = [qpdf unparseResolved];
		}
		[tView setString:objText];
	} else {
		[tView setEditable:NO];
		[tView setString:@""];
	}
}

- (void)selectObject:(id)sender {
	
	selectedView = (NSOutlineView*)sender;
	selectedRow = [selectedView selectedRow];
	
	[self changeRow:selectedRow forSource:selectedView];
}

- (void)replaceQPDFNode:(QPDFNode*)node withString:(NSString*)editor
{
	QPDFObjectHandleObjc* qpdf = [node object];
	if ([qpdf isNull])
		return;
	if ([editor length]>0)
	{
		if([qpdf isStream])
		{
			//NSLog(@"edit stream");
			//NSData* replData = [editor dataUsingEncoding:NSMacOSRomanStringEncoding];
			[qpdf replaceStreamData:editor];
			//NSLog(@"replace stream data finish");
		} else {
		//	try {
				QPDFObjectHandleObjc* rePDFObj = [[[QPDFObjectHandleObjc alloc] initWithString:editor] autorelease];
				
				// work out if rePDFObj is valid
				QPDFObjectHandleObjc* parent = [node parent];
				//NSLog(@"parse object: %@",editor);
				
				if ([parent isArray])
				{
					[parent replaceObjectAtIndex:[[node name] integerValue] withObject:rePDFObj];
				} else if ([parent isDictionary]) {
				//	std::string name = std::string([[node name] UTF8String]); // might have to change this to the correct PDF encoding
					NSLog(@"replace dictionary key: %@",[node name]);
			//		parent.replaceKey(name, rePDFObj);
					
					[parent replaceObject:rePDFObj forKey:[node name]];
					
				} else {
					// oh no the dreaded child of neither a dictionary or array
					NSLog(@"unknown parent");
				}

			//	NSLog(@"error parsing");
	//		}
		}
		//*  update outlines
		[self updateOutlines:node];
	}
}

- (void)updateOutlines:(QPDFNode*)node
{
	QPDFNode* nn = node;
	[oView reloadItem:nn];
	while ((nn = [nn parentNode]))
		[oView reloadItem:nn];
	
	nn = node;
	[ooView reloadItem:nn];
	while ((nn = [nn parentNode]))
		[ooView reloadItem:nn];
	
	nn = node;
	[opView reloadItem:nn];
	while ((nn = [nn parentNode]))
		[opView reloadItem:nn];
	
	[self updatePDF];
}

-(void)changeFont:(id)sender
{
	NSLog(@"changing font: %@",sender);
}

-(void)forwardInvocation:(NSInvocation*)inv
{
	NSLog(@"window Controller: %@",inv);
}

/*
-(BOOL)paste
{
	NSLog(@"paste ->");
	return YES;
}

-(void)paste:(id)sender
{
	NSLog(@"pasted: %@",sender);
}
*/
/*
- (BOOL)respondsToSelector:(SEL)aSelector
{
	NSString* selstr =NSStringFromSelector(aSelector);
	if (![selstr isEqualToString:@"validModesForFontPanel:"])
	{
		NSLog(@"WC EVENT -> %@",NSStringFromSelector(aSelector));
		if( [NSWindowController instancesRespondToSelector:aSelector] ) {
			// invoke the inherited method
			return YES;
		}
	}
	return NO;
}
*/
/*
- (NSResponder*)nextResponder
{
	return [super nextResponder];
//	return [self document];
}
*/
@end
