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
@synthesize selectedView;
@synthesize selectedNode;

- (instancetype)initWithWindow:(NSWindow*)nsw
{
	self = [super initWithWindow:nsw]; // I just wanted to call this variable NSW,
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
	
	[dc addObserver:self selector:@selector(selectChangeNotification:) name:@"NSOutlineViewSelectionDidChangeNotification" object:[w outlineAtIndex:0]];
	[dc addObserver:self selector:@selector(selectChangeNotification:) name:@"NSOutlineViewSelectionDidChangeNotification" object:[w outlineAtIndex:1]];
	[dc addObserver:self selector:@selector(selectChangeNotification:) name:@"NSOutlineViewSelectionDidChangeNotification" object:[w outlineAtIndex:2]];
}

- (NSString*)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	return displayName;
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

- (NSString*)editText
{
	if (selectedRow >= 0)
	{
		ObjcQPDFObjectHandle* qpdf = [selectedNode object];
		
		if ([qpdf isStream]) {
			return [[[NSString alloc] initWithData:[qpdf stream] encoding:NSMacOSRomanStringEncoding ] autorelease];
		} else {
			 return [qpdf unparseResolved];
		}
	}
	return nil;
}

- (void)setEditText:(NSString*)s
{
	[(QPDFWindow*)[self window] setText:s];
}
- (void)setEditEnable:(BOOL)ee
{
	[(QPDFWindow*)[self window] editorEnabled:ee];
}

// how many of these should I show ?
- (ObjcQPDFObjectHandle*)selectedObject
{
	return [[self selectedNode] object];
}

- (BOOL)editEnabled
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

- (BOOL)addEnabled
{
	NSLog(@"addEnabled? %@",[selectedNode object]);
	return [[selectedNode object] isExpandable];
}

- (BOOL)removeEnabled
{
	NSLog(@"removeEnabled? %@",[selectedNode object]);
	return [self isSelected];
}

- (void)setAddEnabled:(BOOL)ena
{
	[[selectedView relatedSegment] setEnabled:ena forSegment:0];
}

- (void)setRemoveEnabled:(BOOL)ena
{
	[[selectedView relatedSegment] setEnabled:ena forSegment:1];
}


/*
- (void)enableAddRemove:(NSSegmentedControl*)ctrl forRow:(NSInteger)row outline:(QPDFOutlineView*)qov
{
	NSSegmentedControl* related = [qov relatedSegment];
	if (row >= 0 )
	{
		[[qov relatedSegment] setEnabled:YES forSegment:0];
		[[qov relatedSegment] setEnabled:YES forSegment:1];

		QPDFNode* selNode = [selectedView itemAtRow:selectedRow];
		
		if ([[selNode object] isExpandable])
			[[qov relatedSegment] setEnabled:YES forSegment:0];
		else
			[[qov relatedSegment] setEnabled:NO forSegment:0];
	}
	else
		[[qov relatedSegment] setEnabled:NO forSegment:0];

	//	[(QPDFWindow*)[self window] removeEnabled:NO forIndex:outl];
}
*/

// changeText -> refreshOutline, setText, refreshPDF, documentChanged

- (void)changeText:(NSInteger)row forSource:(QPDFOutlineView*)qov with:(NSString*)es
{
	
}

// addRow -> refreshOutline, setRow, setText, enaAR, refreshPDF, documentChanged

- (void)addObject:(ObjcQPDFObjectHandle*)obj to:(ObjcQPDFObjectHandle*)container
{
	if ([container isArray])
	{
		//NSLog(@"Parent is array");
		[container addObject:obj];
	} else if ([container isDictionary]) {
		// find unique name
		// NSString* uniqueName = @"/Untitled";
		// NSLog(@"Parent is Dictionary");
		
		[container replaceObject:obj forKey:@"/New"];
	} else {
		NSLog(@"Adding to unknown type");
	}

}

/*
- (void)addRow:(NSInteger)row forSource:(QPDFOutlineView*)qov ofType:(object_type_e)type
{
	QPDFNode *item = [qov itemAtRow:row];
	
//	QPDFNode *parent = [item parentNode];  // no not adding to parent, adding to selected branch object.
//	ObjcQPDFObjectHandle* parentObject = [parent object];
	
	QPDFWindow *win = (QPDFWindow*)[self window];

	if (parent) {
	}
	// do we tell document that something has been added
//	NSLog(@"new parent: %@",[parent unparseResolved]);
	
	NSLog(@"chindex for parent %ld",(long)[qov childIndexForItem:parent]);
	NSLog(@"chindex for  %ld",(long)[qov childIndexForItem:item]);

	[qov reloadItem:parent reloadChildren:YES];
	
	PDFDocument* doc = [[self document] pdfdocument];
	[win.documentView setDocument:doc];
	
	[self selectRow:[qov selectedRow] forSource:qov];

}
*/

//deleteRow -> deleteRow, refreshOutline, setRow, setText, enaAddRemove, refreshPDF, documentChanged

- (void)deleteRow:(NSInteger)row forSource:(QPDFOutlineView*)qov
{
	QPDFNode *item = [qov itemAtRow:row];
	QPDFNode *parent = [item parentNode];
	QPDFWindow *win = (QPDFWindow*)[self window];
	
	[[self document] deleteNode:item];  // the document should record that it's changed.
	// what about deleting from the view, rather than
	// refresh outline
	[qov reloadItem:parent];
	
	PDFDocument* doc = [[self document] pdfdocument];
	[win.documentView setDocument:doc];
	
	//[self setSelectedRow:[qov selectedRow]];
	[self selectRow:[qov selectedRow] forSource:qov];
	

}

// selectRow -> #setOV, #setRow, #setText, enaEdit, #enaAddRemove;

- (void)selectRow:(NSInteger)sr forSource:(QPDFOutlineView*)qov
{
	// setOV, setRow
	[self setSelectedRow:sr];
	[self setSelectedView:qov];
	[self setSelectedNode:[qov itemAtRow:[self selectedRow]]];

	// setText
	[self setEditText:[self editText]];

	// ena Text edit
	[self setEditEnable:[self editEnabled]];

	//[self enableAddRemoveForRow:selectedRow outline:selectedView];
	[self setAddEnabled:[self addEnabled]];
	[self setRemoveEnabled:[self removeEnabled]];
	
}

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

		[self changeText:selectedRow forSource:selectedView with:editor];
		
	}
	NSLog(@"<<< textDidEndEditing %@",ov);  // from outline

}


- (void)selectChangeNotification:(NSNotification*)nn
{
	//	NSLog(@"changeNotification: %@ UI:%@",nn,[nn userInfo]);
	QPDFOutlineView* sv = [nn object];
	[self selectRow:[sv selectedRow] forSource:sv];
}

- (void)selectObject:(id)sender
{
	QPDFOutlineView* evv = (QPDFOutlineView*)sender;
	[self selectRow:[evv selectedRow] forSource:evv];
}

-(void)changeFont:(id)sender
{
	//	NSLog(@"changing font: %@",sender);
	NSFontManager* fm = (NSFontManager*)sender;
	NSLog(@"changing font: %@",[fm selectedFont]);  // why is this nil?
	
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
/*
- (BOOL)canAdd
{
	NSLog(@"canadd? %@",[selectedNode parentNode]);
	return [[selectedNode parent] isExpandable];
}

- (BOOL)canDelete
{
	return (selectedRow != -1);

}
 */

- (void)addType:(id)sender;
{
	NSInteger osr = self.selectedRow;
	QPDFOutlineView* ov = self.selectedView;
	QPDFNode *item = [ov itemAtRow:osr];
	ObjcQPDFObjectHandle *toObj = [item object];
	
	object_type_e type = (object_type_e)((NSMenuItem*)sender).tag;
	
	NSLog(@"ADD sender: %@ %d",sender,(int)((NSMenuItem*)sender).tag);
	ObjcQPDFObjectHandle* newobj = nil;
	switch (type) {
		case ot_null:
			newobj = [ObjcQPDFObjectHandle newNull];
			break;;
		case ot_boolean:
			newobj=[ObjcQPDFObjectHandle newBool:NO];
			break;;
		case ot_integer:
			newobj=[ObjcQPDFObjectHandle newInteger:0];
			break;;
		case ot_real:
			newobj=[ObjcQPDFObjectHandle newInteger:0.0];
			break;;
		case ot_string:
			newobj=[ObjcQPDFObjectHandle newString:@""];
			break;;
		case ot_name:
			newobj=[ObjcQPDFObjectHandle newName:@""];
			break;;
		case ot_array:
			newobj=[ObjcQPDFObjectHandle newArray];
			break;;
		case ot_dictionary:
			newobj=[ObjcQPDFObjectHandle newDictionary];
			break;;
		case ot_stream:
			newobj=[ObjcQPDFObjectHandle newStreamForQPDF:[toObj owner]];
			break;
		default:
			NSLog(@"You're creating a wha-?");
	}

	if (newobj)
	{
		QPDFWindow *win = (QPDFWindow*)[self window];
	
		[self addObject:newobj to:toObj];
	
		[ov reloadItem:item reloadChildren:YES];
	
		PDFDocument* doc = [[self document] pdfdocument];
		[win.documentView setDocument:doc];
	
		[self selectRow:[ov selectedRow] forSource:ov];
	}
	
//	[self addRow:osr forSource:ov ofType:type];

}

- (void)addRemove:(id)sender
{
	NSSegmentedControl* sc = (NSSegmentedControl*)sender;
		// NSLog(@"selected: %ld",(long)[sc selectedSegment]);
	NSInteger osr = self.selectedRow;
	QPDFOutlineView* ov = self.selectedView;
	
	NSInteger selectedSeg = [sc selectedSegment];
	// this should never be true
//	if (selectedSeg == 0 ) { // add
		// QPDFNode* selNode = [selectedView itemAtRow:selectedRow];
		// NSLog(@"### add ###");

		//[self addRow:osr forSource:ov];
		
//	}
	if (selectedSeg==1)
	{
		NSLog(@"### delete ###");
		[self deleteRow:osr forSource:ov];

	}
	
}

- (void)delete:(id)sender
{
	NSLog(@"DELETE: %@",sender);
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
