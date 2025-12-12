#import "QPDFWindowController.h"

#import "OutlineQPDF.h"
#import "OutlineQPDFObj.h"
#import "OutlineQPDFPage.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

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
	
		lastUpdate = 0;
		updateDocumentLock = [NSLock new];
		
		QPDFWindow* qpw = (QPDFWindow*)nsw;
		documentCenter = [dc retain];
		
		syntaxer = [[QPDFSyntaxHighlighter alloc] init];
		syntaxer.asyncView = qpw.textView;
		
		[documentCenter addObserver:self selector:@selector(documentChange:) name:@"QPDFUpdateDocument" object:nil];
		[documentCenter addObserver:self selector:@selector(rowChangedContent:) name:@"QPDFSelectOutlineRow" object:nil];
		[documentCenter addObserver:self selector:@selector(textSetContent:) name:@"QPDFUpdateTextview" object:nil];

		self.selectedPage = 0;
		
		[self synchronizeWindowTitleWithDocumentName];
		[self setSelectedRow:-1];
		
		//NSLog(@"doc-view: %@",[qpw documentView]);
		//NSLog(@"DOCUMENT: %@",[self document]);
		
	//	[[qpw documentView] setDocument:[[self document] pdfdocument]];
	}
	return self;
}


-(void)initDataSource
{
	// QPDFWindowController* nwc = [self windowController];
	// QPDFDocument* qp = [self document];
	
	ObjcQPDF* qDoc = [[self document] doc];
	QPDFWindow* w = (QPDFWindow*)[self window];

	//No autorelease here, the outline views only have a weak reference to their datasources.
	OutlineQPDF* pdfDS = [[OutlineQPDF alloc] initWithPDF:qDoc];
	OutlineQPDFObj* objDS = [[OutlineQPDFObj alloc] initWithPDF:qDoc];
	OutlineQPDFPage* pageDS = [[OutlineQPDFPage alloc] initWithPDF:qDoc];
	
	[[w outlineAtIndex:0] setDataSource:pdfDS];
	[[w outlineAtIndex:1] setDataSource:objDS];
	[[w outlineAtIndex:2] setDataSource:pageDS];
	
	[[w textView] setDelegate:self];

	[documentCenter postNotificationName:@"QPDFUpdateDocument" object:@(0)];

	NSString* documentName = [[self document] displayName];
	
	[[w splitAtIndex:1] setAutosaveName:[NSString stringWithFormat:@"SplitOutline-%@",documentName]];
	[[w splitAtIndex:0] setAutosaveName:[NSString stringWithFormat:@"SplitMain-%@",documentName]];
	[w setFrameAutosaveName:[NSString stringWithFormat:@"MainWindow-%@",documentName]];
	
	NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
	
	
	// as we don't post these ourselves they must use the default centre
	[dc addObserver:self selector:@selector(textDidEndEditing:) name:@"NSControlTextDidEndEditingNotification" object:[w outlineAtIndex:0]];
	[dc addObserver:self selector:@selector(textDidEndEditing:) name:@"NSControlTextDidEndEditingNotification" object:[w outlineAtIndex:1]];
	[dc addObserver:self selector:@selector(textDidEndEditing:) name:@"NSControlTextDidEndEditingNotification" object:[w outlineAtIndex:2]];
	
	[dc addObserver:self selector:@selector(selectChangeNotification:) name:@"NSOutlineViewSelectionDidChangeNotification" object:[w outlineAtIndex:0]];
	[dc addObserver:self selector:@selector(selectChangeNotification:) name:@"NSOutlineViewSelectionDidChangeNotification" object:[w outlineAtIndex:1]];
	[dc addObserver:self selector:@selector(selectChangeNotification:) name:@"NSOutlineViewSelectionDidChangeNotification" object:[w outlineAtIndex:2]];
	
	
	// not enough performance
	[dc addObserver:self selector:@selector(textViewScrollNotification:) name:NSViewBoundsDidChangeNotification object:[w.scrollTextView contentView]] ;
	// [dc addObserver:self selector:@selector(boundsDidChange:) name:NSViewBoundsDidChangeNotification object:contentView];

	NSLog(@"<<< [QPDFWindowController initDataSource");
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
	NSDate *startTime = [NSDate date];
	NSLog(@">>> [textSetContent] Starting");
	
	// Cancel any in-progress colorization from previous selection
	[syntaxer cancelColorization];
	
	NSString* s = (NSString*)[n object];
	if(!s) { s = @""; }
	
	QPDFWindow* w = (QPDFWindow*)[self window];
	QPDFTextView* ntv = w.textView;
	
	// Size thresholds for performance optimization
	#define MAX_EFFICIENT_SIZE (100 * 1024)  // 100 KB - disable spell check above this
	#define MAX_FULL_HIGHLIGHT_SIZE (20 * 1024)  // 20 KB - only highlight visible range above this
	
	BOOL isLarge = [s length] > MAX_EFFICIENT_SIZE;
	
	// Measure text view loading
	//NSLog(@"⏱ [textSetContent] About to call setString with %lu chars", (unsigned long)[s length]);
	NSDate *setStringStart = [NSDate date];
	[ntv setString:s];
	NSTimeInterval setStringTime = [[NSDate date] timeIntervalSinceDate:setStringStart];
	//NSLog(@"⏱ [textSetContent] setString returned: %.3f seconds", setStringTime);
	
	NSDate *afterSetString = [NSDate date];
	// Deliberately do nothing here to see if freeze happens after setString returns
	NSTimeInterval gapTime = [[NSDate date] timeIntervalSinceDate:afterSetString];
	//NSLog(@"⏱ [textSetContent] Time after setString: %.3f seconds", gapTime);
	
	// Skip spell checking for large streams (saves ~1.5 seconds for 500KB)
	if (isLarge) {
		NSLog(@"[textSetContent] Skipping checkTextInDocument for large stream (%lu chars)", (unsigned long)[s length]);
		// Disable continuous spell checking for this text view
		[ntv setContinuousSpellCheckingEnabled:NO];
	} else {
		NSDate *checkStart = [NSDate date];
		[ntv checkTextInDocument:nil];
		NSTimeInterval checkTime = [[NSDate date] timeIntervalSinceDate:checkStart];
		NSLog(@"[textSetContent] checkTextInDocument: %.3f seconds", checkTime);
	}
	
	// Force line number view to recalculate before next draw to prevent stale indices
	NSDate *rulerStart = [NSDate date];
	[w.scrollTextView.verticalRulerView setNeedsDisplay:YES];
	NSTimeInterval rulerTime = [[NSDate date] timeIntervalSinceDate:rulerStart];
	//NSLog(@"⏱ [textSetContent] ruler setNeedsDisplay: %.3f seconds", rulerTime);
	
	// Colorization now enabled for all stream sizes (asan was the real bottleneck)
	// this one for quickly colouring the displayed text
	NSDate *layoutStart = [NSDate date];
	NSRange glyphRange = [w.textView.layoutManager glyphRangeForBoundingRect:w.scrollTextView.documentVisibleRect
													  inTextContainer:w.textView.textContainer];

	NSRange visRange = [w.textView.layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
	NSTimeInterval layoutTime = [[NSDate date] timeIntervalSinceDate:layoutStart];
	//NSLog(@"⏱ [textSetContent] layout manager range calc: %.3f seconds (vis range: %lu,%lu)", layoutTime, (unsigned long)visRange.location, (unsigned long)visRange.length);
	
	// Measure syntax highlighting
	NSDate *highlightStart = [NSDate date];
	if ([s length] > MAX_FULL_HIGHLIGHT_SIZE) {
		// Only highlight visible range for medium-sized streams
		[syntaxer colouriseRange:visRange];
	} else {
		// Full highlighting for small streams
		[syntaxer colouriseRangeThenAll:visRange];
	}
	NSTimeInterval highlightTime = [[NSDate date] timeIntervalSinceDate:highlightStart];
	//NSLog(@"⏱ [textSetContent] Syntax highlighting: %.3f seconds", highlightTime);
	
	NSTimeInterval totalTime = [[NSDate date] timeIntervalSinceDate:startTime];
	//NSLog(@"⏱ [textSetContent] TOTAL: %.3f seconds", totalTime);
}
/*
- (void)textSetContentDirect:(NSString*)s
{
	 // NSString* s = (NSString*)[n object];
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
*/

- (void)setEditEnable:(BOOL)ee
{
	[(QPDFWindow*)[self window] editorEnabled:ee];
}

- (BOOL)isSelected
{
	return ([self selectedRow]>=0);
}

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
			// Allow adding if expandable OR if nothing is selected (add to root)
			BOOL canAdd = (selHandle == nil) || [selHandle isExpandable];
			[outadd setEnabled:canAdd forSegment:0];
		} else {
			[outadd setEnabled:YES forSegment:0];
		}
		
	}
}

// changeText -> refreshOutline, setText, refreshPDF, documentChanged

- (void)changeText:(QPDFOutlineView*)qov with:(NSString*)es
{
	NSInteger row = [qov editedRow];
	NSInteger col = [qov editedColumn];
	
//	QPDFNode* node = [qov itemAtRow:row];
	ObjcQPDFObjectHandle* handle = [qov itemAtRow:row];
	ObjcQPDFObjectHandle* parent = [handle parent];
	NSString* name = [handle elementName];  // dictionary key or array index value

	NSLog(@">>> [changeText] row:%ld col:%ld", (long)row, (long)col);
	NSLog(@">>> [changeText] handle: %@ (type: %@, isIndirect: %d)", handle, [handle typeName], [handle isIndirect]);
	NSLog(@">>> [changeText] parent: %@ (type: %@, isDict: %d, isArray: %d)", parent, [parent typeName], [parent isDictionary], [parent isArray]);
	NSLog(@">>> [changeText] elementName: %@", name);

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
		NSLog(@">>> [changeText] Column 2 edit - input: '%@'", es);
		
		// Parse value with PDF document context (handles indirect refs automatically)
		NSError *error = nil;
		ObjcQPDFObjectHandle* newobj = [[ObjcQPDFObjectHandle alloc] initWithString:es forQPDF:[[self document] doc] error:&error];
		
		NSLog(@">>> [changeText] newobj created: %@, error: %@", newobj ? @"YES" : @"NO", error);
		
		if (!newobj && error) {
			NSAlert *alert = [[[NSAlert alloc] init] autorelease];
			[alert setMessageText:@"Invalid PDF Syntax"];
			[alert setInformativeText:[NSString stringWithFormat:@"%@\n\nInput: %@", [error localizedDescription], es]];
			[alert addButtonWithTitle:@"OK"];
			[alert runModal];
		}
		
		if (newobj) {
			ObjcQPDFObjectHandle* updatedObject = nil;
			
			if (parent) {
				// Object is in a container (dictionary or array)
				NSLog(@">>> [changeText] Replacing in parent (type: %@)", [parent typeName]);
				if ([parent isArray])
				{
					[parent replaceObjectAtIndex:[name integerValue] withObject:newobj];
					NSLog(@">>> [changeText] Replaced in array at index %@", name);
				} else if ([parent isDictionary]) {
					[parent replaceObject:newobj forKey:name];
					NSLog(@">>> [changeText] Replaced in dictionary for key %@", name);
				} else {
					NSLog(@"parent is not dictionary or array");
				}
				// After replacement, newobj is the current object
				updatedObject = newobj;
			} else {
				// No parent - this is an indirect object in the flat list
				// We need to replace the object's content, not the object itself
				NSLog(@">>> [changeText] No parent - editing indirect object directly");
				
				// Copy the new object's content into the existing indirect object
				if ([handle isDictionary] && [newobj isDictionary]) {
					// Replace dictionary contents
					for (NSString* key in [handle keys]) {
						[handle removeObjectForKey:key];
					}
					for (NSString* key in [newobj keys]) {
						[handle replaceObject:[newobj objectForKey:key] forKey:key];
					}
					NSLog(@">>> [changeText] Replaced dictionary contents");
				} else if ([handle isArray] && [newobj isArray]) {
					// Replace array contents
					while ([handle count] > 0) {
						[handle removeObjectAtIndex:0];
					}
					for (NSUInteger i = 0; i < [newobj count]; i++) {
						[handle addObject:[newobj objectAtIndex:i]];
					}
					NSLog(@">>> [changeText] Replaced array contents");
				} else {
					NSLog(@">>> [changeText] Cannot replace - type mismatch or unsupported type");
					NSAlert *alert = [[[NSAlert alloc] init] autorelease];
					[alert setMessageText:@"Cannot Edit Indirect Object"];
					[alert setInformativeText:@"Editing indirect objects in the list view is not yet supported for this type. Try editing from the tree view instead."];
					[alert addButtonWithTitle:@"OK"];
					[alert runModal];
				}
				// After modifying in place, handle is still the current object
				updatedObject = handle;
			}
			[newobj autorelease];
			
			// Reload parent to show the new indirect reference in the outline
			NSLog(@">>> [changeText] Posting update notification");
			if (parent) {
				[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:parent userInfo:@{@"reloadChildren":@(YES)}];
			} else {
				// Reload the entire view for indirect object changes
				[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:nil];
			}
			
			// Update text view to show the edited object's new content
			if (updatedObject) {
				[documentCenter postNotificationName:@"QPDFUpdateTextview" object:[updatedObject text]];
			}
		} 
	}
	// update outlines
	// update textview
	// update Document
}

- (void)rowChangedContent:(NSNotification*)notification
{
	NSLog(@"[QPDFWindowController RowChangedContent:%@]", notification);
	
	NSDate *startTime = [NSDate date];
	NSDate *stepTime = startTime;
	
	NSString* text = nil;
	if (selectedRow >= 0)
	{
		ObjcQPDFObjectHandle* qpdf = selectedHandle;
		
		if ([qpdf isStream]) {
			// Measure stream decoding
			NSDate *decodeStart = [NSDate date];
			NSData* streamData = [qpdf stream];
			NSTimeInterval decodeTime = [[NSDate date] timeIntervalSinceDate:decodeStart];
			NSLog(@"⏱ Stream decode: %.3f seconds (%lu bytes)", decodeTime, (unsigned long)[streamData length]);
			
			// Measure string conversion
			NSDate *convertStart = [NSDate date];
			text = [[[NSString alloc] initWithData:streamData encoding:NSMacOSRomanStringEncoding] autorelease];
			NSTimeInterval convertTime = [[NSDate date] timeIntervalSinceDate:convertStart];
			NSLog(@"⏱ String conversion: %.3f seconds (%lu chars)", convertTime, (unsigned long)[text length]);
			
			[self setEditEnable:YES];
		} else {
			NSDate *unparseStart = [NSDate date];
			text = [qpdf unparseResolved];
			NSTimeInterval unparseTime = [[NSDate date] timeIntervalSinceDate:unparseStart];
			NSLog(@"⏱ Unparse: %.3f seconds", unparseTime);
			[self setEditEnable:YES];
		}
		
		// or post another notification
		QPDFWindow* w = (QPDFWindow*)[self window];
		
		QPDFTextView* ntv = w.textView;

		// Measure text view loading
		NSDate *setStringStart = [NSDate date];
		[ntv setString:text];
		NSTimeInterval setStringTime = [[NSDate date] timeIntervalSinceDate:setStringStart];
		NSLog(@"⏱ Text view setString: %.3f seconds", setStringTime);
		
		[ntv checkTextInDocument:nil];
		
		// Force line number view to recalculate before next draw to prevent stale indices
		[w.scrollTextView.verticalRulerView setNeedsDisplay:YES];
		
		// this one for quickly colouring the displayed text
		NSRange glyphRange = [w.textView.layoutManager glyphRangeForBoundingRect:w.scrollTextView.documentVisibleRect
														  inTextContainer:w.textView.textContainer];
		NSRange visRange = [w.textView.layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
		
		// Measure syntax highlighting
		NSDate *highlightStart = [NSDate date];
		if ([text length] > 20000) {
			[syntaxer colouriseRange:visRange];
		} else {
			[syntaxer colouriseRangeThenAll:visRange];
		}
		NSTimeInterval highlightTime = [[NSDate date] timeIntervalSinceDate:highlightStart];
		NSLog(@"⏱ Syntax highlighting: %.3f seconds", highlightTime);
		
		NSTimeInterval totalTime = [[NSDate date] timeIntervalSinceDate:startTime];
		NSLog(@"⏱ TOTAL rowChangedContent: %.3f seconds", totalTime);
	}
}

// selectRow -> #setOV, #setRow, #setText, enaEdit, #enaAddRemove;

- (void)selectRow:(NSInteger)sr forSource:(QPDFOutlineView*)qov
{
	NSDate *selectStartTime = [NSDate date];
	NSLog(@">>> [selectRow] Starting selection");
	
	// setOV, setRow
	[self setSelectedRow:sr];
	[self setSelectedView:qov];
	[self setSelectedHandle:[qov itemAtRow:[self selectedRow]]];  // selected row can be -1
	//Parameter is NSInteger. no mention of out of range value, assume returns nil
	// setText

//	NSLog(@"wincon selectHandle -> %@",selectedHandle);

	if (selectedHandle)
	{
		NSDate *textGenStart = [NSDate date];
		NSString* handleText = [selectedHandle text];
		NSTimeInterval textGenTime = [[NSDate date] timeIntervalSinceDate:textGenStart];
		NSLog(@"⏱ [selectRow] Getting text from handle: %.3f seconds (%lu chars)", textGenTime, (unsigned long)[handleText length]);
		
		// Set edit enable BEFORE loading text to avoid 2-second freeze
		// (NSTextView is slow when changing editable state with large text already loaded)
		NSDate *editEnableStart = [NSDate date];
		if ([selectedHandle isStream])
			[self setEditEnable:YES];
		else
			[self setEditEnable:NO];
		NSTimeInterval editEnableTime = [[NSDate date] timeIntervalSinceDate:editEnableStart];
		//NSLog(@"⏱ [selectRow] setEditEnable (before text load): %.3f seconds", editEnableTime);
		
		NSDate *notifyStart = [NSDate date];
		//NSLog(@"⏱ [selectRow] About to post QPDFUpdateTextview notification");
		[documentCenter postNotificationName:@"QPDFUpdateTextview" object:handleText];
		NSTimeInterval notifyTime = [[NSDate date] timeIntervalSinceDate:notifyStart];
		//NSLog(@"⏱ [selectRow] Notification posted and all observers returned: %.3f seconds", notifyTime);

		// [self textSetContentDirect:handleText];

	 // think I could get text from here...  I did, see above
		// and that's not all I can get from selectedHandle. look page numbers now.
		NSDate *pageStart = [NSDate date];
		NSInteger nPage = [selectedHandle pageNumber];
		// NSLog(@"selected Handle says... %ld",nPage);
		
		// if we've selected another non-page object, then don't change the page.
		if (nPage>=0 && nPage != self.selectedPage)
		{
			// OK, now what page is it?  // Ha Ha, sucks to be you, I found it.
			// and I then made it into a method in ObjcQPDFObjectHandle, called pageNumber, ner nerny ner ner
			self.selectedPage = nPage;
			[documentCenter postNotificationName:@"QPDFUpdateDocument" object:@(nPage)];
		}
		NSTimeInterval pageTime = [[NSDate date] timeIntervalSinceDate:pageStart];
		NSLog(@"⏱ [selectRow] Page handling: %.3f seconds", pageTime);
	} else {
		// but if we've selected no object, then unselect the page.
		// make sense?
		self.selectedPage = -1;
		// how do we "unselect" the document
		[documentCenter postNotificationName:@"QPDFUpdateDocument" object:@(-1)];

	}
	// update selectedPageNumber
	
	[self updateOutlineAddRemove];
	
	NSTimeInterval selectTotalTime = [[NSDate date] timeIntervalSinceDate:selectStartTime];
	NSLog(@"⏱ [selectRow] TOTAL: %.3f seconds", selectTotalTime);
	// NSLog(@"end selectRow");
}

- (void)setMediabox:(id)sender
{
	NSMenuItem* nmi = (NSMenuItem*)sender;
	
	NSString * sz =[[QPDFMenu pageSizes] objectAtIndex:[nmi tag]];

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
	NSLog(@">>> [QPDFWindowController textDidChange:%@]",notification); // from textview
	
	QPDFTextView* notifview = [notification object];
	
	[[self document] updateChangeCount:NSChangeDone];
	[self setDocumentEdited:YES];

	// [[self document] setDocumentEdited:YES];
	
	NSRange editRange = [notifview rangeForUserTextChange];
	NSString *editor = [notifview string];  // much of a muchness
	NSRange lineRange = [editor lineRangeForRange:editRange];

// where does paste end up?

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
		[documentCenter postNotificationName:@"QPDFUpdateDocument" object:@(self.selectedPage)];

//		[self updateCurrentPage];

//		[self updateDoc:doc];
		
//		[NSObject cancelPreviousPerformRequestsWithTarget:self];
//		[self performSelector:@selector(restoreDocRect:) withObject:[NSValue valueWithRect:saveRect] afterDelay:1];
		
		//[[self document] updateChangeCount:NSChangeDone];
		//[self setDocumentEdited:YES];
		
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

- (void)documentChange:(NSNotification*)notification
{
	/*
	// why am I using notification user info?
	NSNumber* page = [notification object];
	int selPage = [page intValue];
	
	// NSLog(@"getting page: %d",selPage);
	
	PDFDocument* doc = nil;
	// wonder if passing a nil object to set document will grey it out.
	if (selPage >= 0)
		doc = [[self document] pdfDocumentPage:selPage];  // arrays are zero indexed...
	*/
	
	[self updatePDFView];
	
}
- (void)updatePDFView
{
	// if timer not running {
	if (selectedPage>=0)
	{
		ObjcQPDF* objdoc;


// testing control of the release
//		PDFDocument* doc;
//		doc = [[self document] pdfDocumentPage:selectedPage];  // arrays are zero indexed...


		objdoc = [[[self document] copyDocumentPage:selectedPage] autorelease];

		[CATransaction begin];
		QPDFWindow* qwin = (QPDFWindow*)[self window];
		QPDFView* pv = [qwin documentView];

		/*
		NSLog(@"[updatePDFView PDF view frame: %@]",
			  NSStringFromRect(pv.frame)
			  );

		NSLog(@"[updatePDFView PDF view bounds: %@]",
			  NSStringFromRect(pv.bounds)
			  );


		NSView* dv = [pv documentView];

		NSLog(@"PDF document frame: %@",
			  NSStringFromRect(dv.frame)
			  );

		NSLog(@"PDF document bounds: %@",
			  NSStringFromRect(dv.bounds)
			  );
*/

	// [updateDocumentLock lock];  // hoping this will prevent the update display crash.
	//[visRect scrollRectToVisible:saveRect];
	
	// [pv setCanDrawConcurrently:NO];
//	if (time(NULL) != lastUpdate)  // must reset NSTimer trigger
//	{
		// NSView* visRect = [[[[pv subviews] firstObject] subviews] firstObject];
		// NSRect saveRect = [visRect visibleRect];

		PDFDestination* cDest = [pv currentDestination];
		NSLog(@"[updatePDFView Point: %@ zoom: %f]",NSStringFromPoint([cDest point]),[cDest zoom]);
		CGPoint cPoint = [cDest point];
		CGFloat cZoom = [cDest zoom];


		[CATransaction setValue:(id)kCFBooleanTrue
						 forKey:kCATransactionDisableActions];  // this might fix the crashing... // no
	
		[pv setDocument:[objdoc document]];
		//[visRect scrollRectToVisible:saveRect];

//		lastUpdate = time(NULL);
		[CATransaction commit];
		NSLog(@"[updatePDFView Point: %@ zoom: %f]",NSStringFromPoint([cDest point]),[cDest zoom]);

		PDFDestination *nDest = [[PDFDestination alloc] initWithPage:[[objdoc document] pageAtIndex:0] atPoint:cPoint];
		if (cZoom != kPDFDestinationUnspecifiedValue) {
			nDest.zoom = cZoom;
		}
		[pv goToDestination:nDest];

	}
//	[pv layoutDocumentView];  // does not work, as the document is static in memory
	// [updateDocumentLock unlock];
	// } end if
	// cancel old timer
	// create new
	
}

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
		
		NSLog(@"Changed to: %@",editor);
		
		[self changeText:selectedView with:editor];  // why is this needed?
		
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

- (void)selectChangeNotification:(NSNotification*)notification
{
	NSDate *notificationStartTime = [NSDate date];
	NSLog(@">>> [QPDFWindowController selectChangeNotification:%@] [NSNotification %@]",notification,[notification object]);
	
	QPDFOutlineView* sv = (QPDFOutlineView*)[notification object];
	
	[self selectRow:[sv selectedRow] forSource:sv];
	
	NSTimeInterval notificationTime = [[NSDate date] timeIntervalSinceDate:notificationStartTime];
	NSLog(@"⏱ [selectChangeNotification] TOTAL: %.3f seconds", notificationTime);
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
	
				win.textFont = nf;
			}}

-(void)exportText:(id)sender
{
	// get from QPDF
	
	NSData * fileData;
	ObjcQPDFObjectHandle* qpdf = [selectedView itemAtRow:selectedRow];  // QPDFNode* node = ov->itemAtRow(row);
	//ObjcQPDFObjectHandle* qpdf = [node object]; // QPDFObjectHandle qpdf = node->object();
	
	if ([qpdf isStream]) {
		fileData = [qpdf stream];
		if (!fileData) {
			// Decoding failed (e.g. DCTDecode not supported by QPDF).
			// Try getting the raw stream data (e.g. the JPEG file itself).
			fileData = [qpdf rawStream];
			
			if (!fileData) {
				NSAlert *alert = [[[NSAlert alloc] init] autorelease];
				[alert setMessageText:@"Export Failed"];
				[alert setInformativeText:@"Could not retrieve stream data (decoded or raw). The stream might be corrupted."];
				[alert addButtonWithTitle:@"OK"];
				[alert runModal];
				return;
			}
		}
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
	NSInteger tag = [sender tag];
	NSString* sz = [[QPDFMenu standardFonts] objectAtIndex:tag];
	
	if (sz)
	{
		NSLog(@"WC -> insertFont: %@",sender);
		// NSLog(@"WC -> insertFont: %@",sz);
		// NSLog(@"WC -> insertFont: %ld",self.selectedPage);
		
		// - (void)addStandardFont:(NSString*)fontName toPage:(NSInteger)pageNumber;
		
		[(QPDFDocument*)[self document] addStandardFont:sz toPage:self.selectedPage];
		
		// Reload the outline view to show the new font
		[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:selectedHandle userInfo:nil];
	}
}

- (void)insertColorSpace:(id)sender
{
	NSInteger tag = [sender tag];
	
	NSLog(@"WC -> insertColorSpace: tag=%ld", (long)tag);
	
	[(QPDFDocument*)[self document] addColorSpace:tag toPage:self.selectedPage];
	
	// Reload the outline view to show the new ColorSpace
	[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:nil];
	[documentCenter postNotificationName:@"QPDFUpdateDocument" object:nil];
	
	// Update text view if page is currently displayed
	if (selectedHandle) {
		[documentCenter postNotificationName:@"QPDFUpdateTextview" object:[selectedHandle text]];
	}
}

- (void)insertExtGState:(id)sender
{
	NSInteger tag = [sender tag];
	
	NSLog(@"WC -> insertExtGState: tag=%ld", (long)tag);
	
	[(QPDFDocument*)[self document] addExtGState:tag toPage:self.selectedPage];
	
	// Reload the outline view to show the new ExtGState
	[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:nil];
	[documentCenter postNotificationName:@"QPDFUpdateDocument" object:nil];
	
	// Update text view if page is currently displayed
	if (selectedHandle) {
		[documentCenter postNotificationName:@"QPDFUpdateTextview" object:[selectedHandle text]];
	}
}

- (void)insertFontFile:(id)sender
{

	// file dialog
	// data from file
	// stream from data
	// insert into indirect
}

- (void)insertXObject:(id)sender
{
	if (selectedPage >= 0)
	{
		NSOpenPanel* panel = [NSOpenPanel openPanel];
		[panel setCanChooseFiles:YES];
		[panel setCanChooseDirectories:NO];
		[panel setAllowsMultipleSelection:NO];
		if (@available(macOS 11.0, *)) {
			[panel setAllowedContentTypes:@[UTTypeJPEG, UTTypePNG, UTTypeTIFF]];
		}
		
		[panel beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse result) {
			if (result == NSModalResponseOK)
			{
				NSURL* url = [panel URL];
				if (url)
				{
					[(QPDFDocument*)[self document] insertImage:[url path] onPage:self.selectedPage];
					
					// Force a full reload of the outlines to show the new object and the updated page structure
					// Passing nil triggers reloadData, which now preserves expansion state.
					[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:nil userInfo:@{@"reloadChildren":@(YES)}];
					
					// Also refresh the document view
					[documentCenter postNotificationName:@"QPDFUpdateDocument" object:nil];
				}
			}
		}];
	}
}

- (void)performFindPanelAction:(id)sender
{
	[[(QPDFWindow*)[self window] textView] performTextFinderAction:sender];
}

- (void)performTextFinderAction:(id)sender
{
	[[(QPDFWindow*)[self window] textView] performTextFinderAction:sender];
}


// addRow -> refreshOutline, setRow, setText, enaAR, refreshPDF, documentChanged

- (void)addType:(id)sender
{
	// NSInteger osr = self.selectedRow;
	
	// How did this become a textview?
	
	// NSLog(@"we are here:\n%@",[NSThread callStackSymbols]);  // remember this for next time so you don't have to go searching the internet
	// NSLog(@"selected view is a: %@",[self.selectedView className]);
	
	QPDFOutlineView* ov = self.selectedView;
	
	QPDFObjectTypeEnum type = (QPDFObjectTypeEnum)((NSMenuItem*)sender).tag;

	QPDFOutlineView* activeView = self.selectedView;
	if ([sender isKindOfClass:[NSMenuItem class]] && [[sender representedObject] isKindOfClass:[QPDFOutlineView class]]) {
		activeView = [sender representedObject];
	}

	//NSLog(@"before: %@",[selectedHandle text]);
	
	ObjcQPDFObjectHandle* target = selectedHandle;
	if (target == nil) {
		// If in Object List (Tag 1), create new Indirect Object instead of adding to Root
		if ([activeView relatedSegment].tag == 1) {
			// Create the object first
			ObjcQPDFObjectHandle* newobj = nil;
			// We need a temporary parent or just create it?
			// addItemOfType needs a parent to add to.
			// Refactor: We should create the object first, then decide where to put it.
			
			// HACK: Use document helper to create the object instance directly
			// But addItemOfType logic is inside QPDFDocument.
			// Let's rely on QPDFDocument to create it, but we need a way to say "Don't add to parent".
			
			// Alternative: Create a dummy parent? No.
			// We need to move the object creation logic out of addItemOfType or replicate it here.
			
			// Let's duplicate the creation logic here for this special case (safest change).
			switch (type) {
				case QPDFObjectTypeNull: newobj = [ObjcQPDFObjectHandle newNull]; break;
				case QPDFObjectTypeBoolean: newobj = [ObjcQPDFObjectHandle newBool:NO]; break;
				case QPDFObjectTypeInteger: newobj = [ObjcQPDFObjectHandle newInteger:0]; break;
				case QPDFObjectTypeReal: newobj = [ObjcQPDFObjectHandle newReal:0.0]; break;
				case QPDFObjectTypeString: newobj = [ObjcQPDFObjectHandle newString:@""]; break;
				case QPDFObjectTypeName: newobj = [ObjcQPDFObjectHandle newName:@"/Name"]; break;
				case QPDFObjectTypeArray: newobj = [ObjcQPDFObjectHandle newArray]; break;
				case QPDFObjectTypeDictionary: newobj = [ObjcQPDFObjectHandle newDictionary]; break;
				case QPDFObjectTypeStream:
					newobj=[ObjcQPDFObjectHandle newStreamForQPDF:[[self document] doc] withString:@""];
					break;
				default: break;
			}
			
			if (newobj) {
				[[[self document] doc] makeIndirectObject:newobj];
				// Full reload
				[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:nil userInfo:@{@"reloadChildren":@(YES)}];
				[[self document] updateChangeCount:NSChangeDone];
				[self setDocumentEdited:YES];
			}
			[ov endUpdates];
			return; // Done
		}
		
		target = [[[self document] doc] copyTrailer];
	}

	if ([[self document] addItemOfType:type toObject:target])
	{
		//	NSLog(@"after: %@",[selectedHandle text]);
		
		// addRow -> refreshOutline, setRow, setText, enaAR, refreshPDF, documentChanged

		[ov beginUpdates];
	
		// post NSNotification
		NSDictionary* user = @{@"reloadChildren":@(YES)};
 
		[documentCenter postNotificationName:@"QPDFUpdateTextview" object:[selectedHandle text]];
		
		// Use object:nil to force full reload (for Flat View update)
		// QPDFOutlineView now preserves expansion state, so this is safe.
		[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:nil userInfo:user];
		
		[documentCenter postNotificationName:@"QPDFUpdateDocument" object:@(selectedPage)];

//		toObj = [ov itemAtRow:[ov selectedRow]];
		//if ([ov isExpandable:selectedHandle])
		//	[ov expandItem:selectedHandle];  // but not if it's an object
	
		// enable the add/Remove buttons depending on what's selected.
		// I'm thinking another notification observer...
		// should be something in selectedHandle to tell us.
		[self setAddEnabled:[self canAddToSelectedObject]]; // i'm seeing a pattern here
		[self setRemoveEnabled:(selectedRow>0)];
		
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
						ObjcQPDFObjectHandle* proc = [[ObjcQPDFObjectHandle newName:menuName] autorelease];
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
	SEL action = [menuItem action];
	
	if (action == @selector(setProc:))
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
	
	// NSLog(@"deleteRow: setEditText");
	// NSNotification
	// [self setEditText:[self textForSelectedObject]];
	// NSLog(@"deleteRow: end setEditText");

	// post NSNotification
	[documentCenter postNotificationName:@"QPDFUpdateTextview" object:[selectedHandle text]];
	[documentCenter postNotificationName:@"QPDFUpdateOutlineview" object:selectedHandle userInfo:nil];
	[documentCenter postNotificationName:@"QPDFUpdateDocument" object:nil];
	
	[[self document] updateChangeCount:NSChangeDone];
	[self setDocumentEdited:YES];
//	[[self document] setDocumentEdited:YES];

}

// This should probably go into the QPDFDocument class.
// this is only called from the Page Outline Add
// Remove can be called from any of the 3 outlines

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
	else // add
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
	
	if (theAction == @selector(exportText:)) {
		return (selectedView != nil && selectedRow >= 0);
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
