#import "QPDFDocumentController.h"

@implementation QPDFDocumentController

/*
//+ (void) load
{
	NSLog(@"QPDFDocumentController load");
	[QPDFDocumentController new];
}
*/
 
- (NSArray<NSString*>*) documentClassNames
{
	return @[@"PDF"];
}

- (NSString*) defaultType
{
	return @"PDF";
}

- (Class)documentClassForType:(NSString *)typeName
{
	return [QPDFDocument class];
}

/*
//- (QPDFDocument*)documentForURL:(NSURL*)uel
{
	NSLog(@"QPDFDocumentController documentForURL");
	//QPDFDocument* fd = nil;
	for (QPDFDocument* qp in [self documents])
	{
		if ([uel isEqualTo:[qp fileURL]])
		{
			return qp;
		}
	}
	return nil;
}
*/
/*
//- (nullable __kindof NSDocument *)documentForWindow:(NSWindow *)window
{
	NSLog(@"QPDFDocumentController documentForWindow");

	for (QPDFDocument* qp in [self documents])
	{
		if ([window isEqualTo:[qp window]])
			return qp;
	}
	return nil;
}
*/

- (QPDFDocument*)makeDocumentWithContentsOfURL:(NSURL*)url ofType:(NSString *)type error:(NSError**)outError
{
	NSError* theError;
	return [[[QPDFDocument alloc] initWithContentsOfURL:url ofType:@"" error:&theError] autorelease];
}

- (void)openDocument:(id)sender
{
//	NSLog(@"QPDFDocumentController openDocument");

	NSOpenPanel* openDlg = [NSOpenPanel openPanel];  // nsopenpanel *opn = NSOpenPanel::openPanel();
	[openDlg setCanChooseFiles:YES];
	[openDlg setAllowsMultipleSelection:NO];
	[openDlg setCanChooseDirectories:NO];
	
	[openDlg beginWithCompletionHandler:^(NSInteger result){
		if (result == NSModalResponseOK) {
			NSURL* url = [[openDlg URLs] firstObject];
			NSError* theError;
			QPDFDocument* newDoc = [[[QPDFDocument alloc] initWithContentsOfURL:url ofType:@"" error:&theError] autorelease];
			[self addDocument:newDoc];
			[newDoc makeWindowControllers];
			[newDoc showWindows];

			// Open  the document.
		}
	}];

	
	/*
	if ( [openDlg runModal] == NSModalResponseOK )
	{
		// Get an array containing the full filenames of all
		// files and directories selected.
		NSURL* url = [[openDlg URLs] firstObject];
		NSError* theError;
		QPDFDocument* nd = [[QPDFDocument alloc] initWithContentsOfURL:url ofType:@"" error:&theError];

		[self addDocument:nd];
	}
	 */
}
 

- (void)newDocument:(id)sender
{
//	NSLog(@"QPDFDocumentController newDocument:sender");

	NSError* theError;
	[self openUntitledDocumentAndDisplay:YES error:&theError];
}

- (QPDFDocument*) openUntitledDocumentAndDisplay:(BOOL)dd error:(NSError **)outError
{
//	NSLog(@"QPDFDocumentController openUntitledDocumentAndDisplay : %d",dd);

	QPDFDocument* newDoc = [self makeUntitledDocumentOfType:@"PDF" error:outError];
	[self addDocument:newDoc];
	if (dd) {
		[newDoc makeWindowControllers];
		[newDoc showWindows];
	}
	return newDoc;
}

- (QPDFDocument*)makeUntitledDocumentOfType:(NSString*)pdf error:(NSError **)outError
{
//	NSLog(@"QPDFDocumentController makeUntitledDocumentOfType");
	// we only ever deal with PDF
	return [[[QPDFDocument alloc] init] autorelease];

}

- (void)openPDF:(NSString*)filename
{
	
	NSURL* url = [NSURL fileURLWithPath:filename];
	NSError* theError;
	QPDFDocument* nd = [[[QPDFDocument alloc] initWithContentsOfURL:url ofType:@"" error:&theError] autorelease];
	
	//NSLog(@"QPDFDocumentController openPDF: open document: %@",nd);
	
	[self addDocument:nd];
	
}

@end
