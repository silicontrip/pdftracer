#import "QPDFWindowController.h"

#import "OutlineQPDF.h"
#import "OutlineQPDFObj.h"
#import "OutlineQPDFPage.h"

@interface QPDFWindowController()
{

}

@end

@implementation QPDFWindowController

- (instancetype)initWithWindow:(NSWindow*)nsw
{
	self = [super initWithWindow:nsw]; // I just wanted to call this variable NSW, although I'm from Victoria
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
	[w setDocument:[[self document] pdfdocument]];
	
	NSString* documentName = [[self document] displayName];
	
	[[w splitAtIndex:1] setAutosaveName:[NSString stringWithFormat:@"SplitOutline-%@",documentName]];
	[[w splitAtIndex:0] setAutosaveName:[NSString stringWithFormat:@"SplitMain-%@",documentName]];
	[w setFrameAutosaveName:[NSString stringWithFormat:@"MainWindow-%@",documentName]];
	
	NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
	
	[dc addObserver:self selector:@selector(textDidEndEditing:) name:@"NSControlTextDidEndEditingNotification" object:[w outlineAtIndex:0]];
	[dc addObserver:self selector:@selector(textDidEndEditing:) name:@"NSControlTextDidEndEditingNotification" object:[w outlineAtIndex:1]];
	[dc addObserver:self selector:@selector(textDidEndEditing:) name:@"NSControlTextDidEndEditingNotification" object:[w outlineAtIndex:2]];
	
	[dc addObserver:self selector:@selector(changeNotification0:) name:@"NSOutlineViewSelectionDidChangeNotification" object:[w outlineAtIndex:0]];
	[dc addObserver:self selector:@selector(changeNotification1:) name:@"NSOutlineViewSelectionDidChangeNotification" object:[w outlineAtIndex:1]];
	[dc addObserver:self selector:@selector(changeNotification2:) name:@"NSOutlineViewSelectionDidChangeNotification" object:[w outlineAtIndex:2]];
}

// MARK: View state change
-(void)updatePDF
{
	PDFDocument* tpDoc = [[self document] pdfdocument];
	[(QPDFWindow*)[self window] setDocument:tpDoc];
}

- (void)updateOutline:(QPDFOutlineView*)outline forNode:(QPDFNode*)node
{
	[(QPDFWindow*)[self window] updateOutline:outline forNode:node];
}

- (NSString*)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	return displayName;
}

- (void)selectChangeNotification:(QPDFOutlineView*)no
{
	NSLog(@"selectChangeNotification: %@",no);
	selectedView = no;
	selectedRow = [selectedView selectedRow];
	[self changeRow:selectedRow forSource:selectedView];
}

- (void)setText:(NSInteger)row forSource:(QPDFOutlineView*)ov {
	
	NSLog(@"QPDFWindowController: ChangeRow:%d forSource:%@",(int)row,ov);
	
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

- (void)enableAddRemoveForRow:(NSInteger)row outline:(QPDFOutlineView*)qov
{
	int outl = 0;
	if (row >= 0 )
	{
		[(QPDFWindow*)[self window] removeEnabled:YES forIndex:outl];
		
		QPDFNode* selNode = [selectedView itemAtRow:selectedRow];
		if ([[selNode object] isExpandable])
			[(QPDFWindow*)[self window] addEnabled:YES forIndex:outl];
		else
			[(QPDFWindow*)[self window] addEnabled:NO forIndex:outl];
	}
	else
		[(QPDFWindow*)[self window] removeEnabled:NO forIndex:outl];
}

- (void)deleteRow:(NSInteger)row forOutline:(QPDFOutlineView*)qov
{
	QPDFNode *item = [qov itemAtRow:row];
	QPDFNode *parent = [item parentNode];
	
	[[self document] deleteNode:item];
	// refresh outline
	[qov reloadItem:parent];
	// setRow
	selectedRow = [qov selectedRow];
	[self changeRow:selectedRow forSource:selectedView];
	
	//setText
	QPDFNode *newItem = [qov itemAtRow:selectedRow];
	[(QPDFWindow*)[self window] setText:[newItem unparse]];
	
}


/*
- (void)changesMadeWithNode:(QPDFNode*)qn
{
	[selectedView reloadItem:qn reloadChildren:YES];

	[self updatePDF];
	[[self document] updateChangeCount:NSChangeDone];
}
*/

// MARK: interface events
- (void)textDidChange:(NSNotification *)notification
{
	// NSLog(@"textDidChange %@",notification); // from textview
	QPDFNode* node = [selectedView itemAtRow:selectedRow];
	
	[[self document] updateChangeCount:NSChangeDone];
	
	NSString *editor = [(QPDFWindow*)[self window] text];
	
	[[self document] replaceQPDFNode:node withString:editor];

}

// This notification is sent when enter is pressed after editing a text cell
- (void)textDidEndEditing:(NSNotification*)aNotification {
	
	// NSLog(@"textDidEndEditing %@ UI:%@",aNotification,[aNotification userInfo]);  // from outline

	//which column is being edited...
	QPDFOutlineView* ov = [aNotification object];
	
	 NSLog(@"textDidEndEditing %@",ov);  // from outline

	
	NSTextView * fieldEditor = [[aNotification userInfo] objectForKey:@"NSFieldEditor"];
	
	if (fieldEditor)
	{
		NSString * editor = [[fieldEditor textStorage] string];
	//	NSLog(@"textDidEndEditing: %@",editor);

		QPDFNode* node = [selectedView itemAtRow:selectedRow];
		
		//	NSLog(@"fieldEditor... %@",node);
		//	QPDFObjectHandle* qpdf = [node object];
		// NSString * editor = [[fieldEditor textStorage] string];
		[(QPDFWindow*)[self window] setText:editor];
		[[self document] replaceQPDFNode:node withString:editor];
	
		[self changesMadeWithNode:node];
		
		// [self invalidateAll];  // this changes nodes...
		
		[self updatePDF];
		[[self document] updateChangeCount:NSChangeDone];

		// refreshOutline
		// setText
		// refresh PDF
		
	}
	
}

- (void)changeNotification0:(NSNotification*)nn { [self changeNotification:nn index:0]; }
- (void)changeNotification1:(NSNotification*)nn { [self changeNotification:nn index:1]; }
- (void)changeNotification2:(NSNotification*)nn { [self changeNotification:nn index:2]; }


- (void)changeNotification:(NSNotification*)nn index:(int)outl
{
	//	NSLog(@"changeNotification: %@ UI:%@",nn,[nn userInfo]);
	
	selectedView = [nn object];
	selectedRow = [selectedView selectedRow];
	
	[self changeRow:selectedRow forSource:selectedView];
	[self enableAddRemoveForRow:selectedRow outline:selectedView];
	
	// set Text
	
}

- (void)selectObject:(id)sender {
	
	selectedView = (QPDFOutlineView*)sender;
	selectedRow = [selectedView selectedRow];
	
//	NSView* pp = [selectedView superview];
//	NSArray<NSView*> *sibs =  [pp subviews];
	
//	NSLog(@"%@ %@" , pp, sibs);
	
	[self changeRow:selectedRow forSource:selectedView];
	// set text
	// add Remove buttons
}

-(void)changeFont:(id)sender
{
	//	NSLog(@"changing font: %@",sender);
	NSFontManager* fm = (NSFontManager*)sender;
	NSLog(@"changing font: %@",[fm selectedFont]);  // why is this mil?
	
	//	[(QPDFWindow*)[self window] setFont:[fm selectedFont]];
	
}

-(void)exportText:(id)sender
{
	// get from QPDF
	
	NSData * fileData;
	QPDFNode* node = [selectedView itemAtRow:selectedRow];  // QPDFNode* node = ov->itemAtRow(row);
	ObjcQPDFObjectHandle* qpdf = [node object]; // QPDFObjectHandle qpdf = node->object();
	
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

- (void)addRemove:(id)sender
{
	
	NSSegmentedControl* sc = (NSSegmentedControl*)sender;
	//	NSLog(@"selected: %ld",(long)[sc selectedSegment]);
	int osr = selectedRow;
	
	
	NSInteger selectedSeg = [sc selectedSegment];
	if (selectedSeg == 0 ) { // add
		QPDFNode* selNode = [selectedView itemAtRow:selectedRow];
		
		NSLog(@"add to: %@",selNode);
		
		ObjcQPDFObjectHandle* target = [selNode object];
		
		if ([target isArray])
		{
			ObjcQPDFObjectHandle* placeHolder = [[[ObjcQPDFObjectHandle alloc] initWithString:@"()"] autorelease];
			[target addObject:placeHolder];
			//			[selectedView reloadItem:selNode];
			//			[[(QPDFWindow*)[self window] outlineAtIndex:1] reloadItem:nil];
		} else if ([target isDictionary]) {
			// come up with unique name
			ObjcQPDFObjectHandle* placeHolder = [[[ObjcQPDFObjectHandle alloc] initWithString:@"()"] autorelease];
			[target replaceObject:placeHolder forKey:@"/New"];
		}
		
		[self changesMadeWithNode:selNode];
		
		// [(QPDFWindow*)[self window] updateOutline:selectedView forNode:selNode];
		// [self updateOutlines:selNode];
		
		[selectedView reloadItem:selNode reloadChildren:YES];
		selectedRow = [selectedView selectedRow];
		[self changeRow:selectedRow forSource:selectedView];
		
		
	}
	if (selectedSeg==1)
	{
		NSLog(@"### delete ###");
		
		QPDFNode* selNode = [selectedView itemAtRow:selectedRow];
		QPDFNode* parentNode = [selNode parentNode];
		ObjcQPDFObjectHandle* target = [selNode parent];
		if (target != nil) {
			
			NSLog(@"### Delete from Parent ###");
			if ([target isArray])
			{
				NSLog(@"remove array: %@",[selNode name]);
				int ix = [[selNode name] intValue];
				[target removeObjectAtIndex:ix];
			} else if ([target isDictionary]) {
				NSLog(@"remove dictionary: %@",[selNode name]);
				[target removeObjectForKey:[selNode name]];
			}
			// [selectedView reloadItem:parentNode reloadChildren:YES];
			[self changesMadeWithNode:parentNode];
			selectedRow = [selectedView selectedRow];
			NSLog(@"old : %d : New : %d",osr,(int)selectedRow);
			[self changeRow:selectedRow forSource:selectedView];
			
			// [(QPDFWindow*)[self window] updateOutline:selectedView forNode:parentNode];
		}
	}
	
}

- (void)delete:(id)sender
{
	NSLog(@"DELETE: %@",sender);
	[self deleteRow:selectedRow forOutline:selectedView];
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
	SEL theAction = [anItem action];
	NSLog(@"VALIDATE: %@",NSStringFromSelector(theAction));
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
