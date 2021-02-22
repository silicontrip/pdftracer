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

-(void)updatePDF
{
	PDFDocument* tpDoc = [[self document] pdfdocument];
	[(QPDFWindow*)[self window] setDocument:tpDoc];
}

- (NSString*)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	return displayName;
}

/* editing events */
- (void)textDidChange:(NSNotification *)notification
{
	NSLog(@"textDidChange"); // from textview
	QPDFNode* node = [selectedView itemAtRow:selectedRow];
	
	[self setDocumentEdited:[[self document] isDocumentEdited]];
	[[self window] setDocumentEdited:[[self document] isDocumentEdited]];
	
	NSString *editor = [(QPDFWindow*)[self window] editorText];
	
	// NSLog(@"[%@]",editor);
	[[self document] replaceQPDFNode:node withString:editor];
	[self updateOutlines:node];  // are we coming from NSTextView or NSOutlineView
	[self updatePDF];
	[[self document] updateChangeCount:NSChangeDone];

}

- (void)textDidEndEditing:(NSNotification*)aNotification {
	
	// NSLog(@"textDidEndEditing");  // from outline

	NSTextView * fieldEditor = [[aNotification userInfo] objectForKey:@"NSFieldEditor"];
	NSString * editor = [[fieldEditor textStorage] string];
	NSLog(@"textDidEndEditing: %@",editor);
	if (fieldEditor)
	{

		QPDFNode* node = [selectedView itemAtRow:selectedRow];
		//	QPDFObjectHandle* qpdf = [node object];
		
		// NSString * editor = [[fieldEditor textStorage] string];
		[(QPDFWindow*)[self window] setEditor:editor];
		[[self document] replaceQPDFNode:node withString:editor];

		[self invalidateAll];  // this changes nodes... 

	//	[self updateOutlines:node];  // are we coming from NSTextView or NSOutlineView
		
		[self updatePDF];
		// [ invalidate
		// [self setDocumentEdited:[[self document] isDocumentEdited]];
		[[self document] updateChangeCount:NSChangeDone];
	//	[[self window] setDocumentEdited:[[self document] isDocumentEdited]];

	}
}

- (void)selectChangeNotification:(NSOutlineView*)no
{
	//NSLog(@"QPDFWindowController selectChangeNotification %@",no);

	selectedView = no;
	selectedRow = [selectedView selectedRow];
	[self changeRow:selectedRow forSource:selectedView];
}

- (void)changeNotification:(NSNotification*)nn
{
	selectedView = [nn object];
	selectedRow = [selectedView selectedRow];
	[self changeRow:selectedRow forSource:selectedView];
}

- (void)changeRow:(NSInteger)row forSource:(NSOutlineView*)ov { // void QPDFWindowController::changeRow (NSInteger row, NSOutlineView* ov) {
																// for those who can't read Objective-C function definitions
	//NSLog(@"QPDFWindowController: ChangeRow:%d forSource:%@",(int)row,ov);
	if (row >= 0)
	{
		NSString* objText;
		
		QPDFNode* node = [ov itemAtRow:row];  // QPDFNode* node = ov->itemAtRow(row);
		ObjcQPDFObjectHandle* qpdf = [node object]; // QPDFObjectHandle qpdf = node->object();
		
	//	NSLog (@"obj selected %s",qpdf->getTypeName());
		if ([qpdf isStream]) {
			objText= [[[NSString alloc] initWithData:[qpdf stream] encoding:NSMacOSRomanStringEncoding ] autorelease];
			[(QPDFWindow*)[self window] enableEditor:YES];
		} else {
			// BOOL allowEdit = ![qpdf childrenContainIndirects];
			
			//NSLog(@"set editable: %d",allowEdit);
			[(QPDFWindow*)[self window] enableEditor:NO];
			// NSString* objText = [NSString stringWithUTF8String:qpdf->unparse().c_str()];
			objText = [qpdf unparseResolved];
		}
		[(QPDFWindow*)[self window] setEditor:objText];
	} else {
		[(QPDFWindow*)[self window] enableEditor:NO];
		NSError* err;
		[(QPDFWindow*)[self window] setEditor:[[NSString alloc] initWithData:[[self document] dataOfType:@"QDF" error:&err] encoding:NSMacOSRomanStringEncoding]];

		//[tView setString:@"can you see what I see?"];
	}
}

- (void)selectObject:(id)sender {
	
	selectedView = (NSOutlineView*)sender;
	selectedRow = [selectedView selectedRow];
	
	[self changeRow:selectedRow forSource:selectedView];
}

-(void)invalidateAll
{
	[(QPDFWindow*)[self window] invalidateAll];
}

- (void)updateOutlines:(QPDFNode*)node
{
	//QPDFNode* nn = node;
	
	//NSLog(@"WC:updateOutline %@",node);
	[(QPDFWindow*)[self window] updateAllOutlines:node];
	[self updatePDF];
}

-(void)changeFont:(id)sender
{
	NSLog(@"changing font: %@",sender);
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

- (void)delete:(id)sender
{
	NSLog(@"DELETE: %@",sender);
	// QPDFNode* deleteThisNode = [selectedView itemAtRow:selectedRow];
	[[self document] deleteNode:[selectedView itemAtRow:selectedRow]];
		
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
	SEL theAction = [anItem action];
	//NSLog(@"VALIDATE: %@",NSStringFromSelector(theAction));
	NSLog(@"current %@ %d",selectedView,selectedRow);

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
