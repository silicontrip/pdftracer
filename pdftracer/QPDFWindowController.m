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

@synthesize selectedView;
@synthesize selectedNode;

- (instancetype)initWithWindow:(NSWindow*)nsw
{
	self = [super initWithWindow:nsw]; // I just wanted to call this variable NSW,
	[self setSelectedRow:-1];
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

// textForSelectedObject
- (NSString*)textForSelectedObject
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
	return [[selectedNode object] isExpandable];
}
/*
- (BOOL)removeEnabled
{
//	NSLog(@"removeEnabled? %@",[selectedNode object]);
	return [self isSelected];
}
*/
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
			QPDFNode* selnode = [outview itemAtRow:[outview selectedRow]];
			[outadd setEnabled:[[selnode object] isExpandable] forSegment:0];

		} else
			[outadd setEnabled:YES forSegment:0];
		
	}
}

// changeText -> refreshOutline, setText, refreshPDF, documentChanged

//- (void)changeText:(NSInteger)row column:(NSInteger)column forSource:(QPDFOutlineView*)qov with:(NSString*)es
- (void)changeText:(QPDFOutlineView*)qov with:(NSString*)es
{
	NSInteger row = [qov editedRow];
	NSInteger col = [qov editedColumn];
	
	QPDFNode* node = [qov itemAtRow:row];
	ObjcQPDFObjectHandle* parent = [node parent];
	NSString* name = [node name];  // dictionary key or array index value

	NSLog(@"changeText: row %ld col:%ld view for:%@ new value with:%@",(long int)row,(long int)col,qov,es);
	// something else is changing...
	// NSLog(@"not doing anything");
	
	if (col == 0) {
			//Changing Name
		if ([parent isDictionary])
		{
			[parent removeObjectForKey:name];
			[parent replaceObject:[node object] forKey:es];
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
		}
	}
}

- (void)addObject:(ObjcQPDFObjectHandle*)obj to:(ObjcQPDFObjectHandle*)container
{
	if ([container isArray])
	{
		[container addObject:obj];
	} else if ([container isDictionary]) {
		// find unique name
		NSString* uniqueName = @"/Untitled";
		int version=1;
		ObjcQPDFObjectHandle* found = [container objectForKey:uniqueName];
		while (found) {
			uniqueName = [NSString stringWithFormat:@"/Untitled-%d",version++];
			found = [container objectForKey:uniqueName];
		}
		
		[container replaceObject:obj forKey:uniqueName];
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



// selectRow -> #setOV, #setRow, #setText, enaEdit, #enaAddRemove;

- (void)selectRow:(NSInteger)sr forSource:(QPDFOutlineView*)qov
{
	// setOV, setRow
	[self setSelectedRow:sr];
	[self setSelectedView:qov];
	[self setSelectedNode:[qov itemAtRow:[self selectedRow]]];

	// setText
	[self setEditText:[self textForSelectedObject]];

	// ena Text edit
	[self setEditEnable:[self canEditSelectedObject]];

	//[self enableAddRemoveForRow:selectedRow outline:selectedView];
	//[self setAddEnabled:[self canAddToSelectedObject]];
	//[self setRemoveEnabled:[self isSelected]];
	
	[self updateOutlineAddRemove];
	
}

// MARK: interface events


// this happens after each keypres..?
- (void)textDidChange:(NSNotification *)notification
{
	//  NSLog(@"textDidChange %@",notification); // from textview
	//QPDFNode* node = [selectedView itemAtRow:selectedRow];
	
	[[self document] updateChangeCount:NSChangeDone];
	
	NSString *editor = [(QPDFWindow*)[self window] text];
	
//	NSLog(@"%@",editor);
	
	if (selectedNode != nil) {
		[[self document] replaceQPDFNode:selectedNode withString:editor];
		PDFDocument* doc = [[self document] pdfdocument];
		[[(QPDFWindow*)[self window] documentView] setDocument:doc];
		[[self document] updateChangeCount:NSChangeDone];
	}
}

// This notification is sent when enter is pressed after editing a text cell
- (void)textDidEndEditing:(NSNotification*)aNotification {
	
	NSLog(@"textDidEndEditing");
	
	selectedView = [aNotification object];
	NSTextView * fieldEditor = [[aNotification userInfo] objectForKey:@"NSFieldEditor"];
	
	if (fieldEditor)
	{
		
		selectedRow = [selectedView editedRow];
		selectedColumn = [selectedView editedColumn];

		
		selectedNode = [selectedView itemAtRow:selectedRow];
		
		NSString * editor = [[fieldEditor textStorage] string];
		[self changeText:selectedView with:editor];
		
		// refresh outline, refreshPDF, documentChange
		NSLog(@"reloading: %@",selectedNode);
		[selectedView reloadItem:[selectedNode parentNode] reloadChildren:YES];
	//	[selectedView expandItem:[selectedNode parentNode]];
		
		PDFDocument* doc = [[self document] pdfdocument];
		[[(QPDFWindow*)[self window] documentView] setDocument:doc];
		[[self document] updateChangeCount:NSChangeDone];
	}
//	NSLog(@"<<< textDidEndEditing %@",ov);  // from outline

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

// addRow -> refreshOutline, setRow, setText, enaAR, refreshPDF, documentChanged

- (void)addType:(id)sender
{
	NSInteger osr = self.selectedRow;
	QPDFOutlineView* ov = self.selectedView;
	QPDFNode *item = [ov itemAtRow:osr];
	ObjcQPDFObjectHandle *toObj = [item object];
//	ObjcQPDF* toQPDF = [toObj owner];
	
	object_type_e type = (object_type_e)((NSMenuItem*)sender).tag;
	
NSLog(@"ADD sender: %@ %d",sender,(int)((NSMenuItem*)sender).tag);
	
	ObjcQPDFObjectHandle* newobj = nil;
// if adding to dictionary auto highlight edit /Name
	// if adding to array auto highlight edit value
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
			newobj=[ObjcQPDFObjectHandle newName:@"/Name"];
			break;;
		case ot_array:
			newobj=[ObjcQPDFObjectHandle newArray];
			break;;
		case ot_dictionary:
			newobj=[ObjcQPDFObjectHandle newDictionary];
			break;;
		case ot_stream:
			NSLog(@"creating stream");
			newobj=[ObjcQPDFObjectHandle newStreamForQPDF:[item owner] withString:@" "];
			break;
		default:
			NSLog(@"You're creating a wha-?");
	}

	if (newobj)
	{
		QPDFWindow *win = (QPDFWindow*)[self window];
	
		// addRow -> refreshOutline, setRow, setText, enaAR, refreshPDF, documentChanged

		[ov beginUpdates];
		
		[self addObject:newobj to:toObj];  // Add Row
		[ov reloadItem:item reloadChildren:YES]; // refresh Outline
		[self selectRow:[ov selectedRow] forSource:ov]; // setRow

		[ov expandItem:item];
	
		
		// set Text
		// set the textView with text for the current selected object or stream
		[self setEditText:[self textForSelectedObject]];  // seems kind of superfluous, there must be some better named logical expression for this.

		// ena A R
		// enable the add/Remove buttons depending on what's selected.
		[self setAddEnabled:[self canAddToSelectedObject]]; // i'm seeing a pattern here
		[self setRemoveEnabled:[self isSelected]];
		
		// refresh PDF
		PDFDocument* doc = [[self document] pdfdocument];
		[win.documentView setDocument:doc];

		//documentChanged
		[[self document] updateChangeCount:NSChangeDone];
		[ov endUpdates];

	}
	
}

//deleteRow -> deleteRow, refreshOutline, setRow, setText, enaAddRemove, refreshPDF, documentChanged

- (void)deleteRow:(NSInteger)row forSource:(QPDFOutlineView*)qov
{
	QPDFNode *item = [qov itemAtRow:row];
	QPDFNode *parent = [item parentNode];
	QPDFWindow *win = (QPDFWindow*)[self window];
	
	[[self document] deleteNode:item];  // the document should record that it's changed.
	// what about deleting from the view, rather than
	
	// refresh outline
	[qov reloadItem:parent reloadChildren:YES];
	[self selectRow:[qov selectedRow] forSource:qov];
	
	[self updateOutlineAddRemove];
	
	[self setEditText:[self textForSelectedObject]];
	
	PDFDocument* doc = [[self document] pdfdocument];
	[win.documentView setDocument:doc];
	
	//[self setSelectedRow:[qov selectedRow]];
	
	[[self document] updateChangeCount:NSChangeDone];

}

- (void)addRemove:(id)sender
{
	// other non menu add buttons events end up here
	NSSegmentedControl* sc = (NSSegmentedControl*)sender;
	
	// could be add page
	NSInteger outlineTag = [sc tag];
	NSInteger selectedSegment = [sc selectedSegment];

	/*
	NSLog(@"add/remove event: %@",sender);
	NSLog(@"selected: %ld",(long)selectedSegment);
	NSLog(@"outline tag: %ld",(long)outlineTag);
	 */
	QPDFOutlineView* sv = [(QPDFWindow*)[self window] outlineAtIndex:outlineTag];
	[self selectRow:[sv selectedRow] forSource:sv];
	
	// this seems to work for all outlines
	if (selectedSegment == 1)  // remove
	{
		NSInteger osr = self.selectedRow;
		QPDFNode* pnode = nil;
		if (outlineTag == 0)
		{
			pnode = [selectedNode parentNode];
			//NSLog(@"### delete ###");
		}
		[self deleteRow:osr forSource:sv];
		[sv reloadItem:pnode reloadChildren:YES];

	}
	else
	{
		if (outlineTag == 2) //page outline
		{
			if (selectedSegment == 0) // add
			{
				//NSLog(@"outline Page add... row: %ld",(long)selectedRow);
				// add page
				
				ObjcQPDFObjectHandle* newpage = [ObjcQPDFObjectHandle newDictionary];
				ObjcQPDFObjectHandle* mbox = [ObjcQPDFObjectHandle newArray];
				ObjcQPDFObjectHandle* type = [ObjcQPDFObjectHandle newName:@"/Page"];
				[mbox addObject:[ObjcQPDFObjectHandle newInteger:0]];
				[mbox addObject:[ObjcQPDFObjectHandle newInteger:0]];
				[mbox addObject:[ObjcQPDFObjectHandle newInteger:0]];
				[mbox addObject:[ObjcQPDFObjectHandle newInteger:0]];
				
				[newpage replaceObject:type forKey:@"/Type"];
				[newpage replaceObject:mbox forKey:@"/MediaBox"];
				
				if (selectedRow == -1)
				{
					[[[self document] doc] addPage:newpage atStart:NO];
				} else {
					ObjcQPDFObjectHandle* existingPage = [selectedNode object];
					[[[self document] doc] addPage:newpage before:YES page:existingPage];
				}
				NSLog(@"reloadinating the outline side");
			//	[sv reloadItem:nil reloadChildren:YES];
				[sv reloadData];
				
				// QPDFOutlineView* tree = [(QPDFWindow*)[self window] outlineAtIndex:0];
				QPDFOutlineView* object = [(QPDFWindow*)[self window] outlineAtIndex:1];
				QPDFOutlineView* page = [(QPDFWindow*)[self window] outlineAtIndex:2];

				[object reloadData];  // this doesn't move the view
				// [object reloadItem:nil]; // this one moves
				[page reloadData];
				
				//[[(QPDFWindow*)[self window] outlineAtIndex:2] reloadData];
				//[[(QPDFWindow*)[self window] outlineAtIndex:1] reloadData];
				//[[(QPDFWindow*)[self window] outlineAtIndex:0] reloadData];

				//[[(QPDFWindow*)[self window] outlineAtIndex:1] reloadItem:nil reloadChildren:YES];
				//[[(QPDFWindow*)[self window] outlineAtIndex:2] reloadItem:nil reloadChildren:YES];
				//[[(QPDFWindow*)[self window] outlineAtIndex:0] reloadItem:nil reloadChildren:YES];

			}
		}
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
