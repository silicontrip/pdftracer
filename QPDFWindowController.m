#import "QPDFWindowController.h"

@implementation QPDFWindowController

- (instancetype)initWithDocument:(QPDFDocument*)qp
{
	NSLog(@"QPDFWindowController initWithDocument:%@",self);
	self = [super init];
	if (self) {
		[self setDocument:qp];
		
		// Outline View Columns

		oView = [OutlineQPDF view];
		ooView = [OutlinePDFObj view];
		opView = [OutlinePDFPage view];

		pdfDS = [[OutlineQPDF alloc] initWithPDF:[qp qpdf]];
		objDS = [[OutlinePDFObj alloc] initWithPDF:[qp qpdf]];
		pageDS = [[OutlinePDFPage alloc] initWithPDF:[qp qpdf]];
		
		[oView setDataSource:pdfDS];
		[ooView setDataSource:objDS];
		[opView setDataSource:pageDS];
		
		// scroll view, because you can't fit it all on the screen
		NSScrollView* scView = [[NSScrollView alloc] init];
		[scView setHasVerticalScroller:YES];
		[scView setHasHorizontalScroller:YES];
		[scView setDocumentView:oView];

		NSScrollView* socView = [[NSScrollView alloc] init];
		[socView setHasVerticalScroller:YES];
		[socView setHasHorizontalScroller:YES];
		[socView setDocumentView:ooView];

		NSScrollView* spcView = [[NSScrollView alloc] init];
		[spcView setHasVerticalScroller:YES];
		[spcView setHasHorizontalScroller:YES];
		[spcView setDocumentView:opView];

		tfont = [NSFont fontWithName:@"AndaleMono" size:11]; // prefs...

		// this should also be in a scroll
		
		NSRect vRect = NSMakeRect(0,0,0,0);
		
		tView = [[NSTextView alloc] initWithFrame:vRect];
		[tView setTextContainerInset:NSMakeSize(8.0, 8.0)];
		[tView setEditable:NO];
		tView.richText = NO;
		[tView setAllowsUndo:YES];

		[tView setFont:tfont];  // user prefs
		[tView setDelegate:self];
		tView.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable;
		
		NSScrollView* sctView = [[NSScrollView alloc] init];
		[sctView setHasVerticalScroller:YES];
		[sctView setDocumentView:tView];

		dView = [[PDFView alloc] init];
		pDoc = [[self document] pdfdocument];
		//NSLog(@"QPDFWindowController pdfdocument pdf : %@",pDoc);
		[dView setDocument:pDoc];

		
		NSSplitView* soView=[[NSSplitView alloc] initWithFrame:vRect];
		[soView setVertical:NO];
		[soView addArrangedSubview:scView];
		[soView addArrangedSubview:socView];
		[soView addArrangedSubview:spcView];
		[soView setPostsFrameChangedNotifications:YES];

		NSSplitView* sView=[[NSSplitView alloc] initWithFrame:vRect];
		[sView setVertical:YES];
		[sView addArrangedSubview:soView];
		[sView addArrangedSubview:sctView];
		[sView addArrangedSubview:dView];

		NSUInteger windowStyle =  NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable;
		
		[self setWindow:[[NSWindow alloc] initWithContentRect:vRect styleMask:windowStyle backing:NSBackingStoreBuffered defer:NO]];

		NSWindowCollectionBehavior behavior = [[self window] collectionBehavior];
		behavior |= NSWindowCollectionBehaviorFullScreenPrimary;
		[[self window] setCollectionBehavior:behavior];
		[[self window] setContentView:sView];
		[[self window] orderFrontRegardless];
		
		[[self window]  setTitle:[[self document] filePath]];

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

		[[self window] setFrameAutosaveName:@"MainWindow"];

		[soView setAutosaveName:@"SplitOutline"];
		[sView setAutosaveName:@"SplitMain"];
		
	}
	return self;
}

// + (Boolean)hasNoIndirect:(QPDFObjectHandle)qpdfVal;

-(void)updatePDF
{
	// release old pdf doc
	
	/* who owns pDoc?
 	if (pDoc)
		[pDoc release];
	*/
	
	pDoc = [[self document] pdfdocument];
	[dView setDocument:pDoc];
	
}


- (void)textDidChange:(NSNotification *)notification
{
	QPDFNode* node = [selectedView itemAtRow:selectedRow];
	
	[self setDocumentEdited:YES];
	
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
	
	NSLog(@"QPDFWindowController changeNotification %@",nn);
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
		QPDFObjectHandle qpdf = [node object]; // QPDFObjectHandle qpdf = node->object();
		
	//	NSLog (@"obj selected %s",qpdf->getTypeName());
		if (qpdf.isStream()) {
			try {
				PointerHolder<Buffer> bufRef = qpdf.getStreamData();
				Buffer* buf = bufRef.getPointer();
				size_t sz = buf->getSize();
				unsigned char * bb = buf->getBuffer();
				
				/*
				NSLog(@"buffer size: %ld addr: %x",sz,bb);
				
				for (int i=0; i<sz;++i)
				{
					printf("%d ",*(bb+i));
				}
				*/
				// NSError* writeError;
			    // NSData* dd = [[NSData alloc] initWithBytes:bb length:sz];
				objText= [[NSString alloc] initWithBytes:bb length:sz encoding:NSMacOSRomanStringEncoding ];
				
			//	NSLog(@"=======: %@",objText);
				
				[tView setEditable:YES];
			} catch (QPDFExc e) {
				; // pop up alert.
			}
			
		} else {
			Boolean allowEdit = [QPDFDocument hasNoIndirect:qpdf];
			
			//		NSLog(@"set editable: %d",allowEdit);
			[tView setEditable:allowEdit];
			// NSString* objText = [NSString stringWithUTF8String:qpdf->unparse().c_str()];
			objText = [NSString stringWithUTF8String:qpdf.unparseResolved().c_str()];
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
	QPDFObjectHandle qpdf = [node object];
	if (qpdf.isNull())
		return;
	if ([editor length]>0)
	{
		std::string replacement = std::string([editor UTF8String]);
		
		if(qpdf.isStream())
		{
			//	NSLog(@"edit stream");
			qpdf.replaceStreamData(replacement,QPDFObjectHandle::newNull(),QPDFObjectHandle::newNull());
		} else {
			try {
				QPDFObjectHandle rePDFObj = QPDFObjectHandle::parse(replacement);
				
				// work out if rePDFObj is valid
				QPDFObjectHandle parent = [node parent];
				NSLog(@"parse object: %@",editor);
				
				if (parent.isArray())
				{
					int index =(int) [[node name] integerValue];
					NSLog(@"replace array index: %d",index);
					parent.setArrayItem(index, rePDFObj);
				} else if (parent.isDictionary()) {
					std::string name = std::string([[node name] UTF8String]); // might have to change this to the correct PDF encoding
					NSLog(@"replace dictionary key: %@",[node name]);
					parent.replaceKey(name, rePDFObj);
				} else {
					// oh no the dreaded child of neither a dictionary or array
					NSLog(@"unknown parent");
				}
				//	NSIndexSet* indexRow = [NSMutableIndexSet indexSetWithIndex:srow];
				//	NSIndexSet* indexColumn = [NSMutableIndexSet indexSetWithIndex:3];
				
				// notify outline view of change
				//qpdf->replaceTYPE";
				//	[self.outlineView reloadDataForRowIndexes:indexRow columnIndexexs:indexColumn];
				
			} catch (const std::exception& e) {
				NSLog(@"error parsing");
			}
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

/*
- (NSResponder*)nextResponder
{
	return [super nextResponder];
//	return [self document];
}
*/
@end
