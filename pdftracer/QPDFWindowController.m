#import "QPDFWindowController.h"

#import "OutlineQPDF.h"
#import "OutlinePDFObj.h"
#import "OutlinePDFPage.h"

@interface QPDFWindowController()
{

}

@end

@implementation QPDFWindowController

- (instancetype)initWithWindow:(NSWindow*)nsw
{
	self = [super initWithWindow:nsw];
	
	NSLog(@"Window controller window: %@",[self window]);
	NSLog(@"window controller document: %@",[self document]);
	
	return self;
}

-(void)updatePDF
{
	PDFDocument* tpDoc = [[self document] pdfdocument];
	[(QPDFWindow*)[self window]  setDocument:tpDoc];
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
	
	NSString *editor = [(QPDFWindow*)[self window] editorText];
	[self replaceQPDFNode:node withString:editor];
}

- (void)textDidEndEditing:(NSNotification*)aNotification {
	
	NSTextView * fieldEditor = [[aNotification userInfo] objectForKey:@"NSFieldEditor"];
	if (fieldEditor)
	{

		QPDFNode* node = [selectedView itemAtRow:selectedRow];
		//	QPDFObjectHandle* qpdf = [node object];
		
		NSString * theString = [[fieldEditor textStorage] string];
		[(QPDFWindow*)[self window] setEditor:theString];
		
		[self replaceQPDFNode:node withString:theString];
		[self setDocumentEdited:YES];
		[[self window] setDocumentEdited:YES];

	}
}

- (void)selectChangeNotification:(NSOutlineView*)no
{
	NSLog(@"selectChangeNotification %@",no);

	selectedView = no;
	selectedRow = [selectedView selectedRow];
	[self changeRow:selectedRow forSource:selectedView];
}

- (void)changeNotification:(NSNotification*)nn {
	
//	NSLog(@"QPDFWindowController changeNotification %@",nn);
//	NSLog(@"FR: %@",[[self window] firstResponder]);
	
	selectedView = [nn object];
	selectedRow = [selectedView selectedRow];
	[self changeRow:selectedRow forSource:selectedView];
	
}

- (void)changeRow:(NSInteger)row forSource:(NSOutlineView*)ov { // void QPDFWindowController::changeRow (NSInteger row, NSOutlineView* ov) {
																// for those who can't read Objective-C function definitions
	NSLog(@"QPDFWindowController: ChangeRow:%d forSource:%@",(int)row,ov);
	if (row >= 0)
	{
		NSString* objText;
		
		QPDFNode* node = [ov itemAtRow:row];  // QPDFNode* node = ov->itemAtRow(row);
		ObjcQPDFObjectHandle* qpdf = [node object]; // QPDFObjectHandle qpdf = node->object();
		
	//	NSLog (@"obj selected %s",qpdf->getTypeName());
		if ([qpdf isStream]) {
			objText= [[[NSString alloc] initWithData:[qpdf stream] encoding:NSMacOSRomanStringEncoding ] autorelease];
				
			//	NSLog(@"=======: %@",objText);
				
				[(QPDFWindow*)[self window] enableEditor:YES];
		//	} catch (QPDFExc e) {
				; // pop up alert.
		//	}
			
		} else {
			BOOL allowEdit = ![qpdf childrenContainIndirects];
			
			//		NSLog(@"set editable: %d",allowEdit);
			[(QPDFWindow*)[self window] enableEditor:allowEdit];
			// NSString* objText = [NSString stringWithUTF8String:qpdf->unparse().c_str()];
			objText = [qpdf unparseResolved];
		}
		[(QPDFWindow*)[self window] setEditor:objText];
	} else {
		[(QPDFWindow*)[self window] enableEditor:NO];
		//[tView setString:@"can you see what I see?"];
	}
}

- (void)selectObject:(id)sender {
	
	selectedView = (NSOutlineView*)sender;
	selectedRow = [selectedView selectedRow];
	
	[self changeRow:selectedRow forSource:selectedView];
}

- (void)replaceQPDFNode:(QPDFNode*)node withString:(NSString*)editor
{
	ObjcQPDFObjectHandle* qpdf = [node object];
	if ([qpdf isNull])
		return;
	if ([editor length]>0)
	{
		if([qpdf isStream])
		{
			NSLog(@"edit stream");
			//NSData* replData = [editor dataUsingEncoding:NSMacOSRomanStringEncoding];
			[qpdf replaceStreamData:editor];
			//NSLog(@"replace stream data finish");
		} else {
			//	try {
			ObjcQPDFObjectHandle* rePDFObj = [[[ObjcQPDFObjectHandle alloc] initWithString:editor] autorelease];
			
			// work out if rePDFObj is valid
			ObjcQPDFObjectHandle* parent = [node parent];
			//NSLog(@"parse object: %@",editor);
			
			if ([parent isArray])
			{
				NSLog(@"Edit Array");
				[parent replaceObjectAtIndex:[[node name] integerValue] withObject:rePDFObj];
			} else if ([parent isDictionary]) {
				NSLog(@"Edit Dictionary");
				//	std::string name = std::string([[node name] UTF8String]); // might have to change this to the correct PDF encoding
				NSLog(@"replace dictionary key: %@",[node name]);
				//		parent.replaceKey(name, rePDFObj);
				
				[parent replaceObject:rePDFObj forKey:[node name]];
				
			} else {
				// oh no the dreaded child of neither a dictionary or array
				NSLog(@"unknown parent");
				// err that's because I have an object array view, of course they don't have parents
				/*
				QPDF_DLL
				void replaceObject(QPDFObjGen const& og, QPDFObjectHandle);
				QPDF_DLL
				void replaceObject(int objid, int generation, QPDFObjectHandle);
				 */
			}
			// no need to update if stream editing.
			[self updateOutlines:node];
			
			//	NSLog(@"error parsing");
			//		}
		}
		[self updatePDF];
		//*  update outlines
	}
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

-(void)forwardInvocation:(NSInvocation*)inv
{
	NSLog(@"window Controller: %@",inv);
}

-(void)exportText:(id)sender
{
	// get from QPDF
	
	NSData * fileData;
	QPDFNode* node = [selectedView itemAtRow:selectedRow];  // QPDFNode* node = ov->itemAtRow(row);
	ObjcQPDFObjectHandle* qpdf = [node object]; // QPDFObjectHandle qpdf = node->object();
		
		//	NSLog (@"obj selected %s",qpdf->getTypeName());
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
//			BOOL success = [tstr writeToURL:theFile atomically:NO encoding:NSMacOSRomanStringEncoding error:&theError];
			// Write the contents in the new format.
			//[[[self windowControllers] firstObject] setDocumentEdited:NO];
			NSLog(@"error: %x %@",success,theError);
		}
	}];
	[p autorelease];

	/*
	NSError* err;
	NSURL* urlFile = [NSURL fileURLWithPath:@"/Users/mark/Documents/20200605-pdftext/export_test.txt"];
	
	[tstr writeToURL:urlFile atomically:NO encoding:NSMacOSRomanStringEncoding error:&err];
	*/
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
