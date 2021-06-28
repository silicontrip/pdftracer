#import "QPDFWindowController.h"

#import "OutlineQPDF.h"
#import "OutlineQPDFObj.h"
#import "OutlineQPDFPage.h"

@interface QPDFWindowController()
{

}

@end

@implementation QPDFWindowController

@synthesize selectedRow;
@synthesize selectedColumn;
@synthesize selectedPage;

@synthesize selectedView;
@synthesize selectedHandle;

- (instancetype)initWithWindow:(NSWindow*)nsw notificationCenter:(NSNotificationCenter*)dc
{
	self = [super initWithWindow:nsw]; // I just wanted to call this variable NSW,
	if (self) {
	// NSLog(@"win title: %@",[nsw title]);
	
		QPDFWindow* qpw = (QPDFWindow*)nsw;
		documentCenter = dc;
		
		syntaxer = [[QPDFSyntaxHighlighter alloc] init];
		syntaxer.asyncView = qpw.textView;
		
		[dc addObserver:self selector:@selector(documentChange:) name:@"QPDFUpdateDocument" object:nil];
		[dc addObserver:self selector:@selector(rowChangedContent:) name:@"QPDFSelectOutlineRow" object:nil];
		[dc addObserver:self selector:@selector(textSetContent:) name:@"QPDFUpdateTextview" object:nil];
		self.selectedPage = 0;
		
		[self synchronizeWindowTitleWithDocumentName];
		[self setSelectedRow:-1];
	}
	return self;
}


-(void)initDataSource
{
	// QPDFWindowController* nwc = [self windowController];
	// QPDFDocument* qp = [self document];
	
	ObjcQPDF* qDoc = [[self document] doc];
	QPDFWindow* w = (QPDFWindow*)[self window];
	
	pdfDS = [[OutlineQPDF alloc] initWithPDF:qDoc];
	objDS = [[OutlineQPDFObj alloc] initWithPDF:qDoc];
	pageDS = [[OutlineQPDFPage alloc] initWithPDF:qDoc];
	
	[[w outlineAtIndex:0] setDataSource:pdfDS];
	[[w outlineAtIndex:1] setDataSource:objDS];
	[[w outlineAtIndex:2] setDataSource:pageDS];
	
	[[w textView] setDelegate:self];
	
	//[qp pdfdocument];
	[documentCenter postNotificationName:@"QPDFUpdateDocument" object:@(0)];
	//PDFDocument* ppdf = [[self document] pdfDocumentPage:0];
	// [w setDocument:ppdf];
	
	NSString* documentName = [[self document] displayName];
	
	[[w splitAtIndex:1] setAutosaveName:[NSString stringWithFormat:@"SplitOutline-%@",documentName]];
	[[w splitAtIndex:0] setAutosaveName:[NSString stringWithFormat:@"SplitMain-%@",documentName]];
	[w setFrameAutosaveName:[NSString stringWithFormat:@"MainWindow-%@",documentName]];
	
	NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
	
	
	// as we don't post these ourselves they must use the default centre
	[dc addObserver:self selector:@selector(textDidEndEditing:) name:@"NSControlTextDidEndEditingNotification" object:[w outlineAtIndex:0]];
	[dc addObserver:self selector:@selector(textDidEndEditing:) name:@"NSControlTextDidEndEditingNotification" object:[w outlineAtIndex:1]];
	[dc addObserver:self selector:@selector(textDidEndEditing:) name:@"NSControlTextDidEndEditingNotification" object:[w outlineAtIndex:2]];

// NSOutlineViewSelectionDidChangeNotification
	
	[dc addObserver:self selector:@selector(selectChangeNotification:) name:@"NSOutlineViewSelectionDidChangeNotification" object:[w outlineAtIndex:0]];
	[dc addObserver:self selector:@selector(selectChangeNotification:) name:@"NSOutlineViewSelectionDidChangeNotification" object:[w outlineAtIndex:1]];
	[dc addObserver:self selector:@selector(selectChangeNotification:) name:NSOutlineViewSelectionDidChangeNotification object:[w outlineAtIndex:2]];
	
	
	// not enough performance
	[dc addObserver:self selector:@selector(textViewScrollNotification:) name:NSViewBoundsDidChangeNotification object:[w.scrollTextView contentView]] ;
	// [dc addObserver:self selector:@selector(boundsDidChange:) name:NSViewBoundsDidChangeNotification object:contentView];

}

// MARK: View state change
/*
-(void)updatePDF
{
	PDFDocument* tpDoc = [[self document] pdfdocument];
	[(QPDFWindow*)[self window] setDocument:tpDoc];
}
*/

- (void)updateOutline:(QPDFOutlineView*)outline forHandle:(ObjcQPDFObjectHandle*)handle
{
	[(QPDFWindow*)[self window] updateOutline:outline forHandle:handle];
}

- (void)textSetContent:(NSNotification*)n
{
	NSString* s = (NSString*)[n object];
	if(!s) { s = @""; }
	
	QPDFWindow* w = (QPDFWindow*)[self window];
	QPDFTextView* ntv = w.textView;
	
	// Now I discover that textView has a setColour forRange...
	[ntv setString:s]; // yeah getting desperate now
	[ntv checkTextInDocument:nil];
	
	// this one for quickly colouring the displayed text
	NSRange glyphRange = [w.textView.layoutManager glyphRangeForBoundingRect:w.scrollTextView.documentVisibleRect
															 inTextContainer:w.textView.textContainer];
	NSRange visRange = [w.textView.layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
	
	[syntaxer colouriseRangeThenAll:visRange];  // no more concurrent update crashes??
	
}


- (void)setEditEnable:(BOOL)ee
{
	[(QPDFWindow*)[self window] editorEnabled:ee];
}

// how many of these should I show ?
/*
- (ObjcQPDFObjectHandle*)selectedObject
{
	return [[self selectedNode] object];
}
*/

/*
- (BOOL)canEditSelectedObject
{
	if ([self isSelected])
	{
		ObjcQPDFObjectHandle* qpdf = [selectedNode object];
		if ([qpdf isStream])
			return YES;
		else
			return ![qpdf childrenContainIndirects];
	}
	return NO;
}
*/

- (BOOL)isSelected
{
	return ([self selectedRow]>=0);
}

/*
- (void)setText:(NSInteger)row forSource:(QPDFOutlineView*)ov {
	
	NSLog(@"QPDFWindowController: selectRow:%d forSource:%@",(int)row,ov);
	
	if (row >= 0)
	{
		NSString* objText;
		
		QPDFNode* node = [ov itemAtRow:row];  // QPDFNode* node = ov->itemAtRow(row);
		ObjcQPDFObjectHandle* qpdf = [node object]; // QPDFObjectHandle qpdf = node->object();
		
		//	NSLog (@"obj selected %s",qpdf->getTypeName());
		if ([qpdf isStream]) {
			objText= [[[NSString alloc] initWithData:[qpdf stream] encoding:NSMacOSRomanStringEncoding ] autorelease];
			[(QPDFWindow*)[self window] editorEnabled:YES];
		} else {
			// BOOL allowEdit = ![qpdf childrenContainIndirects];
			
			//NSLog(@"set editable: %d",allowEdit);
			[(QPDFWindow*)[self window] editorEnabled:NO];
			// NSString* objText = [NSString stringWithUTF8String:qpdf->unparse().c_str()];
			objText = [qpdf unparseResolved];
		}
		[(QPDFWindow*)[self window] setText:objText];
	} else {
		[(QPDFWindow*)[self window] editorEnabled:NO];
		//NSError* err;
		//NSData* pdfRep = [[self document] dataOfType:@"QDF" error:&err];
		//NSString* objText=[[[NSString alloc] initWithData:pdfRep encoding:NSMacOSRomanStringEncoding] autorelease];
		//[(QPDFWindow*)[self window]setText:objText];
		// disable delete button
		[(QPDFWindow*)[self window] setText:@""];
		//[tView setString:@"can you see what I see?"];
	}
}
*/

- (BOOL)canAddToSelectedObject
{
	//NSLog(@"addEnabled? %@",[selectedNode object]);
	return [selectedHandle isExpandable];
}

- (void)setAddEnabled:(BOOL)ena
{
	[[selectedView relatedSegment] setEnabled:ena forSegment:0];
}

- (void)setRemoveEnabled:(BOOL)ena
{
	[[selectedView relatedSegment] setEnabled:ena forSegment:1];
}

- (void)updateOutlineAddRemove
{
	for (int outcount=0; outcount<3; ++outcount)
	{
		QPDFOutlineView* outview = [(QPDFWindow*)[self window] outlineAtIndex:outcount];
		NSSegmentedControl* outadd = [(QPDFWindow*)[self window] segmentAtIndex:outcount];
		
		// set remove
		[outadd setEnabled:([outview selectedRow]!=-1) forSegment:1];
		
		if (outcount==0)
		{
			ObjcQPDFObjectHandle* selHandle = [outview itemAtRow:[outview selectedRow]];
			[outadd setEnabled:[selHandle isExpandable] forSegment:0];
		} else {
			[outadd setEnabled:YES forSegment:0];
		}
		
	}
}

// changeText -> refreshOutline, setText, refreshPDF, documentChanged

//- (void)changeText:(NSInteger)row column:(NSInteger)column forSource:(QPDFOutlineView*)qov with:(NSString*)es
- (void)changeText:(QPDFOutlineView*)qov with:(NSString*)es
{
	NSInteger row = [qov editedRow];
	NSInteger col = [qov editedColumn];
	
//	QPDFNode* node = [qov itemAtRow:row];
	ObjcQPDFObjectHandle* handle = [qov itemAtRow:row];
	ObjcQPDFObjectHandle* parent = [handle parent];
	NSString* name = [handle elementName];  // dictionary key or array index value

	// NSLog(@"changeText: row %ld col:%ld view for:%@ new value with:%@",(long int)row,(long int)col,qov,es);
	// something else is changing...
	// NSLog(@"not doing anything");
	
	if (col == 0) {
			//Changing Name
		if ([parent isDictionary])
		{
			[parent removeObjectForKey:name];
			[parent replaceObject:handle forKey:es];
			[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:parent userInfo:@{@"reloadChildren":@(YES)}];
		} else {
			NSLog(@"Cannot Change");
		}
	}
	if (col == 2) {
		// make indirect object
		
		ObjcQPDFObjectHandle* newobj;
		
		NSArray<NSString*>* objElem= [es componentsSeparatedByString:@" "];
		if (([objElem count] == 3) &&
			([[objElem objectAtIndex:2] isEqualToString:@"R"]) &&
			([[objElem objectAtIndex:0] integerValue] != 0))
			{
				newobj = [ObjcQPDFObjectHandle newIndirect:es for:[[self document] doc]];
			}
			else
			{
				NSLog(@"object elem: %lu",(unsigned long)[objElem count]);
				newobj = [[ObjcQPDFObjectHandle alloc] initWithString:es];
			}
		if (newobj) {
			if ([parent isArray])
			{
				[parent replaceObjectAtIndex:[name integerValue] withObject:newobj];
			} else if ([parent isDictionary]) {
				[parent replaceObject:newobj forKey:name];
			} else {
				// who's your daddy?
				NSLog(@"parent is not dictionary or array");  // so wtf is it?
			}
			[newobj autorelease];
			[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:parent];

		}
	}
	// update outlines
	// update textview
	// update Document
}

- (void)rowChangedContent:(NSNotification*)notification
{
	// NSLog(@"RowChangedContent notification");
	
	NSString* text = nil;
	if (selectedRow >= 0)
	{
		ObjcQPDFObjectHandle* qpdf = selectedHandle;
		
		if ([qpdf isStream]) {
			text =  [[[NSString alloc] initWithData:[qpdf stream] encoding:NSMacOSRomanStringEncoding ] autorelease];
			[self setEditEnable:YES];

		} else {
			text = [qpdf unparseResolved];
			[self setEditEnable:YES];
		}
	}
	
	// or post another notification
	QPDFWindow* w = (QPDFWindow*)[self window];
	
	QPDFTextView* ntv = w.textView;

	[ntv setString:text];
	[ntv checkTextInDocument:nil];
	
	// this one for quickly colouring the displayed text
	NSRange glyphRange = [w.textView.layoutManager glyphRangeForBoundingRect:w.scrollTextView.documentVisibleRect
															 inTextContainer:w.textView.textContainer];
	NSRange visRange = [w.textView.layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
	
	[syntaxer colouriseRangeThenAll:visRange];  // no more concurrent update crashes??
	
}

// selectRow -> #setOV, #setRow, #setText, enaEdit, #enaAddRemove;

- (void)selectRow:(NSInteger)sr forSource:(QPDFOutlineView*)qov
{
	NSLog(@"wincon selectRow -> %ld",(long)sr);
	NSLog(@"wincon selectView -> %@",qov);
	
	// setOV, setRow
	[self setSelectedRow:sr];
	[self setSelectedView:qov];
	[self setSelectedHandle:[qov itemAtRow:[self selectedRow]]];  // selected row can be -1
	//Parameter is NSInteger. no mention of out of range value, assume returns nil
	// setText

	NSLog(@"wincon selectHandle -> %@",selectedHandle);

	if (selectedHandle)
	{
	
		[documentCenter postNotificationName:@"QPDFUpdateTextview" object:[selectedHandle text]];
	
		if ([selectedHandle isStream])
			[self setEditEnable:YES];
		else
			[self setEditEnable:NO];

	 // think I could get text from here...  I did, see above
		// and that's not all I can get from selectedHandle. look page numbers now.
		NSInteger nPage = [selectedHandle pageNumber];
		// NSLog(@"selected Handle says... %ld",nPage);
		
		// if we've selected another non-page object, then don't change the page.
		if (nPage>=0 && nPage != self.selectedPage)
		{
			// OK, now what page is it?  // Ha Ha, sucks to be you, I found it.
			// and I then made it into a method in ObjcQPDFObjectHandle, ner nerny ner ner
			self.selectedPage = nPage;
			[documentCenter postNotificationName:@"QPDFUpdateDocument" object:@(nPage)];
		}
	} else {
		// but if we've selected no object, then unselect the page.
		// make sense?
		self.selectedPage = -1;
		// how do we "unselect" the document
		[documentCenter postNotificationName:@"QPDFUpdateDocument" object:@(-1)];

	}
	// update selectedPageNumber
	
	[self updateOutlineAddRemove];
	// NSLog(@"end selectRow");
}

- (void)setMediabox:(id)sender
{
	NSMenuItem* nmi = (NSMenuItem*)sender;
	
	NSString * sz =[[QPDFMenu pageSizes] objectAtIndex:[nmi tag]];

	/*
	NSString* selType = [selectedHandle dictionaryType];
	if ([selType isEqualToString:@"/Pages"])
	{
		NSLog(@"Adding to pages");
	 // despite reading that if a page has no size it is read from the /Pages object
	 // this does not appear to be the case.
		[[self document] setPagesSize:sz];  // data changes here.
	}
	else {
	 */
	NSLog(@"Adding to page: %ld",self.selectedPage);
	[[self document] setSize:sz forPage:self.selectedPage];  // data changes here.
	// }
		
//	NSLog(@"Page size selected: %ld",(long)[nmi tag]);
//	NSLog(@"Page size: %@", sz);
//	NSLog(@"selected Page: %ld",self.selectedPage);
	

	// update outline page objects.
	
	// postNotificationName
	[documentCenter postNotificationName:@"QPDFUpdateDocument" object:@(self.selectedPage)];
	[documentCenter postNotificationName:@"QPDFUpdateTextview" object:[selectedHandle text]];
	[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:nil];
	
	// and something to refresh the outlines showing the mediabox
	// [self updateCurrentPage];

}

- (void)printPDF:(id)sender
{
	[[self document] print:sender];
}

/* - (void)saveDocumentAs:(id)sender
{
	NSLog(@"save as:\n%@",[NSThread callStackSymbols]);  // remember this for next time so you don't have to go searching the internet

	[[self nextResponder] saveDocumentAs:sender];
}
*/

// MARK: interface events

void printView (NSView* n)
{
	NSArray<NSView*>* ch = [n subviews];
	for (NSView *v in ch)
	{
		NSRect rr = [v frame];
		NSArray<NSView*>* cha = [v subviews];
		
		NSLog(@"%@ (%lu) [%@]",v,(unsigned long)[cha count],NSStringFromRect(rr));
		
		if ([cha count] > 0)
			printView(v);
	}
	
}

// this happens after each keypress.
- (void)textDidChange:(NSNotification *)notification
{
	// would like to capture the keydown event... not update if space is pressed.
	// NSLog(@"QPDFWinCon textDidChange %@",notification); // from textview
	
	QPDFTextView* notifview = [notification object];
	
	[[self document] updateChangeCount:NSChangeDone];
	[self setDocumentEdited:YES];

	// [[self document] setDocumentEdited:YES];
	
	NSRange editRange = [notifview rangeForUserTextChange];
	NSString *editor = [notifview string];  // much of a muchness
	NSRange lineRange = [editor lineRangeForRange:editRange];
	
	//NSString *editor = [[(QPDFWindow*)[self window] textView] string];
	// NSString *editor = [textStore string];
	//	NSLog(@"%@",editor);
	
	// NSLog(@"textchange: %@", NSStringFromRange([notifview rangeForUserTextChange]));
	
	[syntaxer colouriseRange:lineRange];
	// [syntaxer colouriseAll];  // no no no no, huge waste of resources
	
	// so which page???
	
	if (selectedHandle != nil) {
		
		// [[self document] replaceQPDFNode:selectedNode withString:editor];  // is this actually working
		[[self document] replaceHandle:selectedHandle withString:editor];
		//PDFDocument* doc = [[self document] pdfdocument];
		
// getting desperate, curse you spacebar bug...
	//[visRect scrollRectToVisible:saveRect];
	//[pv setDocument:doc];
	//[visRect scrollRectToVisible:saveRect];

	//	[self performSelector:@selector(updateDoc:) withObject:doc afterDelay:0.1];
		
		// post NSNotification
		[documentCenter postNotificationName:@"QPDFUpdateDocument" object:nil];

//		[self updateCurrentPage];

//		[self updateDoc:doc];
		
//		[NSObject cancelPreviousPerformRequestsWithTarget:self];
//		[self performSelector:@selector(restoreDocRect:) withObject:[NSValue valueWithRect:saveRect] afterDelay:1];
		
		[[self document] updateChangeCount:NSChangeDone];
		[self setDocumentEdited:YES];
		
	//	[visRect scrollRectToVisible:saveRect];
		
		//NSRect save2Rect = [visRect visibleRect];
		//NSLog(@"after: %@",NSStringFromRect(save2Rect));
		
	//	[[self document] setDocumentEdited:YES];


	}
}



- (void)restoreDocRect:(NSValue*)nsrect
{
	QPDFWindow* qwin = (QPDFWindow*)[self window];
	QPDFView* pv = [qwin documentView];
	
	NSView* visRect = [[[[pv subviews] firstObject] subviews] firstObject];
	
	// PDFDocument* doc = [[self document] pdfDocumentPage:self.selectedPage];  // arrays are zero indexed...

	[visRect scrollRectToVisible:[nsrect rectValue]];

}

/* use NSNotification */
/*
- (void)updateCurrentPage
{
	PDFDocument* doc = [[self document] pdfDocumentPage:self.selectedPage];  // arrays are zero indexed...
	[self updateDoc:doc];
}
*/

- (void)documentChange:(NSNotification*)notification
{
	NSNumber* page = [notification object];
	int selPage = [page intValue];
	
	// NSLog(@"getting page: %d",selPage);
	
	PDFDocument* doc = nil;
	// wonder if passing a nil object to set document will grey it out.
	if (selPage >= 0)
		doc = [[self document] pdfDocumentPage:selPage];  // arrays are zero indexed...
	
	QPDFWindow* qwin = (QPDFWindow*)[self window];
	QPDFView* pv = [qwin documentView];
	
	NSView* visRect = [[[[pv subviews] firstObject] subviews] firstObject];
	NSRect saveRect = [visRect visibleRect];
	
	[visRect scrollRectToVisible:saveRect];
	[pv setDocument:doc];
	[visRect scrollRectToVisible:saveRect];
}

/*
// why is this separate from updateCurrentPage
- (void)updateDoc:(PDFDocument*)doc
{
	// [syntaxer colouriseRange:lineRange];

	// probably a bad idea
	// dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	// maybe a better idea?
//		dispatch_async(dispatch_get_main_queue(), ^{

		QPDFWindow* qwin = (QPDFWindow*)[self window];
		QPDFView* pv = [qwin documentView];
	
		NSView* visRect = [[[[pv subviews] firstObject] subviews] firstObject];
		NSRect saveRect = [visRect visibleRect];
	
	 [visRect scrollRectToVisible:saveRect];
		[pv setDocument:doc];
		[visRect scrollRectToVisible:saveRect];
//	} );

}
*/

// This notification is sent when enter is pressed after editing a text cell
- (void)textDidEndEditing:(NSNotification*)aNotification {
	
//	NSLog(@"windowcontroller textDidEndEditing: %@",aNotification);
	
	selectedView = [aNotification object];
	QPDFTextView * fieldEditor = [[aNotification userInfo] objectForKey:@"NSFieldEditor"];
	
	if (fieldEditor)
	{
	//	NSLog(@"textDidEndEditing fieldEditor");
		selectedRow = [selectedView editedRow];
		selectedColumn = [selectedView editedColumn];
		selectedHandle = [selectedView itemAtRow:selectedRow];
		
	//	NSLog(@"selected Node: %@",selectedHandle);
		
		NSString * editor = [[fieldEditor textStorage] string];
		[self changeText:selectedView with:editor];
		
		// refresh outline, refreshPDF, documentChange
	//	NSLog(@"reloading: %@",selectedHandle);
		// post NSNotification
		/*
		NSDictionary* ui = @{@"reloadChildren": @(YES) };
		[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:[selectedHandle parent] userInfo:ui];
		*/
		//[selectedView reloadItem:[selectedNode parentNode] reloadChildren:YES];
	//	[selectedView expandItem:[selectedNode parentNode]];
		
		// this is not causing the space scrolling issue.
		[documentCenter postNotificationName:@"QPDFUpdateDocument" object:nil];
		
	//	[self updateCurrentPage];
//		PDFDocument* doc = [[self document] pdfdocument];
//		[[(QPDFWindow*)[self window] documentView] setDocument:doc];
		
		[[self document] updateChangeCount:NSChangeDone];
		[self setDocumentEdited:YES];
		// [[self document] setDocumentEdited:YES];
	}
//	NSLog(@"<<< textDidEndEditing %@",ov);  // from outline

}

- (void)textViewScrollNotification:(NSNotification*)nn
{
	// NSLog(@"WinCon scrolly: %@",nn);
	QPDFWindow* w = (QPDFWindow*)[self window];

	NSRange glyphRange = [w.textView.layoutManager glyphRangeForBoundingRect:w.scrollTextView.documentVisibleRect inTextContainer:w.textView.textContainer];

	[syntaxer colouriseRange:glyphRange];
}

- (void)selectChangeNotification:(NSNotification*)nn
{
	// NSLog(@"changeNotification: %@ UI:%@",nn,[nn userInfo]);
	QPDFOutlineView* sv = [nn object];
	[self selectRow:[sv selectedRow] forSource:sv];
}

- (void)selectObject:(id)sender
{
	// NSLog(@"select object: %@",sender);

	QPDFOutlineView* evv = (QPDFOutlineView*)sender;
	[self selectRow:[evv selectedRow] forSource:evv];
}

-(void)changeFont:(id)sender
{
//	NSLog(@"changing font: %@",sender);
	NSFontManager* fm = (NSFontManager*)sender;
	
	QPDFWindow* win=(QPDFWindow*)[self window];
	
//	NSLog(@"changing font: %@",[fm selectedFont]);  // why is this nil?
	
	NSFont* tf = [win textFont];
	NSLog(@"old font: %@",tf);
	if (tf) {
		NSFont* nf = [fm convertFont:tf];
		NSLog(@"new font: %@",nf);

		[win setFont:nf];
	}
}

-(void)exportText:(id)sender
{
	// get from QPDF
	
	NSData * fileData;
	ObjcQPDFObjectHandle* qpdf = [selectedView itemAtRow:selectedRow];  // QPDFNode* node = ov->itemAtRow(row);
	//ObjcQPDFObjectHandle* qpdf = [node object]; // QPDFObjectHandle qpdf = node->object();
	
	if ([qpdf isStream]) {
		fileData = [qpdf stream];
	} else {
		fileData= [[qpdf unparseResolved] dataUsingEncoding:NSMacOSRomanStringEncoding];
	}
	
	NSString * fn = [[[self document] displayName] stringByDeletingPathExtension];
	NSWindow* w = [self window];
	
	NSSavePanel* p = [NSSavePanel savePanel];
	[p retain];
	[p setNameFieldStringValue:fn];
	[p beginSheetModalForWindow:w completionHandler:^(NSInteger result){
		if (result == NSModalResponseOK)
		{
			NSURL*  theFile = [p URL];
			NSError *theError = nil;
			// I checked the documentation the Options values are only available in big sur.
			// this is stupid.
			BOOL success = [fileData writeToURL:theFile options:0 error:&theError];
			
			// should look at what NSData may return in error
			if (!success)
				NSLog(@"error: %x %@",success,theError);
		}
	}];
	[p autorelease];
}

- (void)insertFont:(id)sender
{
	if (selectedPage >= 0)
	{
		// NSLog(@"we are here:\n%@",[NSThread callStackSymbols]);  // remember this for next time so you don't have to go searching the internet
		// NSLog(@"selected view is a: %@",[self.selectedView className]);
	
		NSLog(@"WC -> insertFont: %@",sender);
		
		NSMenuItem* nmi = (NSMenuItem*)sender;
		
		NSString * sz =[[QPDFMenu standardFonts] objectAtIndex:[nmi tag]];
		
		//	NSLog(@"Page size selected: %ld",(long)[nmi tag]);
		NSLog(@"font : %@", sz);
		//	NSLog(@"selected Page: %lu",self.selectedPage);
		
		// - (void)addStandardFont:(NSString*)fontName toPage:(NSInteger)pageNumber;

		[(QPDFDocument*)[self document] addStandardFont:sz toPage:self.selectedPage];

		
		// [[self document] setSize:sz forPage:self.selectedPage];
		//[self updateCurrentPage];
		[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:selectedHandle userInfo:nil];
		[documentCenter postNotificationName:@"QPDFUpdateDocument" object:nil];

	}
}

- (void)insertFontFile:(id)sender
{

	// file dialog
	// data from file
	// stream from data
	// insert into indirect
}


// addRow -> refreshOutline, setRow, setText, enaAR, refreshPDF, documentChanged

- (void)addType:(id)sender
{
	// NSInteger osr = self.selectedRow;
	
	// How did this become a textview?
	
	// NSLog(@"we are here:\n%@",[NSThread callStackSymbols]);  // remember this for next time so you don't have to go searching the internet
	// NSLog(@"selected view is a: %@",[self.selectedView className]);
	
	QPDFOutlineView* ov = self.selectedView;
	
	object_type_e type = (object_type_e)((NSMenuItem*)sender).tag;

	//NSLog(@"before: %@",[selectedHandle text]);
	
	if ([[self document] addItemOfType:type toObject:selectedHandle])
	{
		//	NSLog(@"after: %@",[selectedHandle text]);
		
		// addRow -> refreshOutline, setRow, setText, enaAR, refreshPDF, documentChanged

		[ov beginUpdates];
	
		// post NSNotification
		NSDictionary* user = @{@"reloadChildren":@(YES)};
 
		[documentCenter postNotificationName:@"QPDFUpdateTextview" object:[selectedHandle text]];
		[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:selectedHandle userInfo:user];
		[documentCenter postNotificationName:@"QPDFUpdateDocument" object:@(selectedPage)];

//		toObj = [ov itemAtRow:[ov selectedRow]];
		//if ([ov isExpandable:selectedHandle])
		//	[ov expandItem:selectedHandle];  // but not if it's an object
	
		// enable the add/Remove buttons depending on what's selected.
		// I'm thinking another notification observer...
		// should be something in selectedHandle to tell us.
		[self setAddEnabled:[self canAddToSelectedObject]]; // i'm seeing a pattern here
		[self setRemoveEnabled:[self isSelected]];
		
		//documentChanged
		[[self document] updateChangeCount:NSChangeDone];
		[self setDocumentEdited:YES];

		[ov endUpdates];
	}
	// now to highlight the new object...
}

- (void)setProc:(id)sender
{
	NSMenuItem* menuItem = sender;
	if (selectedPage != -1)
	{
		
		NSControlStateValue sstate = menuItem.state;
		NSLog(@"menu item name: %@",menuItem.title);
//		NSLog(@"menuitem state: %ld",menuItem.state);
		
		ObjcQPDFObjectHandle* pageDict = [(QPDFDocument*)[self document] pageObject:selectedPage];
		if (pageDict)
		{
			ObjcQPDFObjectHandle* res = [pageDict objectForKey:@"/Resources"];
			if (res) {
				ObjcQPDFObjectHandle* procset = [res objectForKey:@"/ProcSet"];
				if (procset)
				{
					NSString* menuName = [NSString stringWithFormat:@"/%@",[menuItem title]];
					if (sstate == NSControlStateValueOn)
					{

						// add remove from procset array
						int deleteIndex = -1;
						for (int pe =0; pe < [procset count]; ++pe)
						{
							ObjcQPDFObjectHandle* pse = [procset objectAtIndex:pe];
							if ([menuName isEqualToString:[pse name]]) {
								// delete this element from
								deleteIndex = pe;
							}
						}
						if (deleteIndex>=0) {
							[procset removeObjectAtIndex:deleteIndex];
							[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:procset userInfo:@{@"ReloadChildren":@(YES)}];
							[documentCenter postNotificationName:@"QPDFUpdateTextview" object:[selectedHandle text]];

						}
					} else {
						ObjcQPDFObjectHandle* proc = [ObjcQPDFObjectHandle newName:menuName];
						[procset addObject:proc];
						[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:procset userInfo:@{@"ReloadChildren":@(YES)}];
						[documentCenter postNotificationName:@"QPDFUpdateTextview" object:[selectedHandle text]];

					}
					
				}
			}
		}
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if (selectedPage == -1)
	{
		[menuItem setState:NSControlStateValueOff];
		return NO;
	}
	// NSString* tt = [menuItem title];
	
	ObjcQPDFObjectHandle* pageDict = [(QPDFDocument*)[self document] pageObject:selectedPage];
	if (pageDict)
	{
		ObjcQPDFObjectHandle* res = [pageDict objectForKey:@"/Resources"];
		if (res) {
			ObjcQPDFObjectHandle* procset = [res objectForKey:@"/ProcSet"];
			if (procset)
			{
				NSString* menuName = [NSString stringWithFormat:@"/%@",[menuItem title]];
				for (int pe =0; pe < [procset count]; ++pe)
				{
					ObjcQPDFObjectHandle* pse = [procset objectAtIndex:pe];
					if ([menuName isEqualToString:[pse name]]) {
						[menuItem setState:NSControlStateValueOn];
						return YES;
					}
				}
				
			}
		}
	}
	[menuItem setState:NSControlStateValueOff];
	return YES;
}


//deleteRow -> deleteRow, refreshOutline, setRow, setText, enaAddRemove, refreshPDF, documentChanged

- (void)deleteRow:(NSInteger)row forSource:(QPDFOutlineView*)qov
{
	ObjcQPDFObjectHandle *item = [qov itemAtRow:row];
	ObjcQPDFObjectHandle *parent = [item parent];
	//QPDFWindow *win = (QPDFWindow*)[self window];
	
	[[self document] deleteHandle:item];  // the document should record that it's changed.
	// what about deleting from the view, rather than
	
	// refresh outline
	// NSNotification
	[qov reloadItem:parent reloadChildren:YES];
	[self selectRow:[qov selectedRow] forSource:qov];
	
	[self updateOutlineAddRemove];
	
	NSLog(@"deleteRow: setEditText");
	// NSNotification
//	[self setEditText:[self textForSelectedObject]];
//	NSLog(@"deleteRow: end setEditText");

	// post NSNotification
	[documentCenter postNotificationName:@"QPDFUpdateTextview" object:[selectedHandle text]];
	[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:selectedHandle userInfo:nil];
	[documentCenter postNotificationName:@"QPDFUpdateDocument" object:nil];
	
	[[self document] updateChangeCount:NSChangeDone];
	[self setDocumentEdited:YES];
//	[[self document] setDocumentEdited:YES];

}

// This should probably go into the QPDFDocument class.
// this is only called from the Page Outline Add/Remove
- (void)addRemove:(id)sender
{
	// NSLog(@"add / Remove clicked");
	
	// other non menu add buttons events end up here
	NSSegmentedControl* sc = (NSSegmentedControl*)sender;
	
	// could be add page
	NSInteger outlineTag = [sc tag];
	NSInteger selectedSegment = [sc selectedSegment];

	QPDFOutlineView* sv = [(QPDFWindow*)[self window] outlineAtIndex:outlineTag];
	[self selectRow:[sv selectedRow] forSource:sv];
	
	// this seems to work for all outlines
	if (selectedSegment == 1)  // remove
	{
		// silly question, but does the Document get a reference in this?

		NSInteger osr = self.selectedRow;
		ObjcQPDFObjectHandle* phandle = nil;
		if (outlineTag == 0)
		{
			phandle = [selectedHandle parent];
			//NSLog(@"### delete ###");
		}
		[self deleteRow:osr forSource:sv];
		// post NSNotification
		[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:phandle userInfo:@{@"reloadChildren":@(YES)}];

	}
	else
	{
		if (outlineTag == 2) //page outline
		{
			// NSLog(@"Add page...");
			if (selectedSegment == 0) // add
			{
				// NSLog(@"outline Page add... row: %ld",(long)selectedRow);
				// add page
				
				if (selectedPage == -1)
				{
					[[self document] newPageAtEnd];
					// post NSNotification

				} else {
					// post NSNotification... below

					// ObjcQPDFObjectHandle* existingPage = [(QPDFDocument*)[self document] pageAtIndex];
					// what if the selected handle isn't a page?
					[[self document] newPageBeforePageNumber:selectedPage];
					
				}
				// post NSNotification
				[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:nil userInfo:nil];

			}
		}
	}
}

- (void)delete:(id)sender
{
	// NSLog(@"DELETE: %@",sender);
	// post NSNotification

	[self deleteRow:selectedRow forSource:selectedView];  // need to pick one... forSource or forOutline
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
	SEL theAction = [anItem action];
	//NSLog(@"VALIDATE: %@",NSStringFromSelector(theAction));
	//	NSLog(@"current %@ %ld",selectedView,(long)selectedRow);
	
	if (theAction == @selector(delete:)) {
		if (selectedView == nil || selectedRow == 0)
			return NO;
		// NSLog(@"delete... %@ %d",selectedView,selectedRow);
		return YES;
	}
	// return [super validateUserInterfaceItem:anItem];
	return YES;
}



- (void)zoomAct:(id)sender
{
	((QPDFWindow*)[self window]).documentView.scaleFactor = 1.0;
}
- (void)zoomFit:(id)sender
{
	((QPDFWindow*)[self window]).documentView.scaleFactor = ((QPDFWindow*)[self window]).documentView.scaleFactorForSizeToFit ;
}
- (void)zoomIn:(id)sender
{
	[((QPDFWindow*)[self window]).documentView zoomIn:sender];
}
- (void)zoomOut:(id)sender
{
	[((QPDFWindow*)[self window]).documentView zoomOut:sender];
}

- (void)zoomSel:(id)sender
{
	
}

/*
- (BOOL)respondsToSelector:(SEL)aSelector
{
	NSString* selstr =NSStringFromSelector(aSelector);
 	NSSet* ignore = [NSSet setWithArray:@[@"_installTrackingRect:assumeInside:userData:trackingNum:"]];
 	if (![ignore containsObject:selstr])
	{
		NSLog(@"WindowController EVENT -> %@",NSStringFromSelector(aSelector));
		if( [QPDFWindowController instancesRespondToSelector:aSelector] ) {
			// invoke the inherited method
			return YES;
		}
	}
	return [super respondsToSelector:aSelector];
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
