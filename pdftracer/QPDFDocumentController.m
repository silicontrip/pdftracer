#import "QPDFDocumentController.h"

@implementation QPDFDocumentController

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

- (QPDFDocument*)makeDocumentWithContentsOfURL:(NSURL*)url ofType:(NSString *)type error:(NSError**)outError
{
	//[super makeDocumentWithContentsOfURL:url ofType:type error:outError];
	// this is called from another QPDFDocumentController method
	// NSLog(@"QDocControl: makeDocumentWithContentsOfURL: %@",url);
	NSError* theError;
	
	QPDFDocument* newDoc=[[[QPDFDocument alloc] initWithContentsOfURL:url ofType:@"PDF" error:&theError] autorelease];
	[self addDocument:newDoc];
	return newDoc;
}

/*
-(void)beginOpenPanelWithCompletionHandler:(void (^)(NSArray<NSURL *> * __nullable))completionHandler
{
	
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];  // nsopenpanel *opn = NSOpenPanel::openPanel();
	[openDlg setCanChooseFiles:YES];
	[openDlg setAllowsMultipleSelection:NO];
	[openDlg setCanChooseDirectories:NO];
	
	NSArray<NSString*>* types = @[ @"PDF" ];
	
	[self beginOpenPanel:openDlg forTypes:types completionHandler:
	 ^(NSInteger result){
		 NSLog(@"QDocControl complettionHandler");
		 
		 if (result == NSModalResponseOK) {
			 NSURL* url = [[openDlg URLs] firstObject];
			 NSError* theError;
			 // Open  the document.
			 NSLog(@"QDocControl .. makeDocument:");
			 [self makeDocumentWithContentsOfURL:url ofType:@"PDF" error:&theError];
			 
		 }
	 }];
	
	
}
*/
//  Handled in super???
// yeah but not without crashing.
- (void)openDocument:(id)sender
{
	// [super openDocument:sender];
	NSLog(@"QDocControl: openDocument sender: %@",sender);  // open document menu is failing

	NSOpenPanel* openDlg = [NSOpenPanel openPanel];  // nsopenpanel *opn = NSOpenPanel::openPanel();
	[openDlg setCanChooseFiles:YES];
	[openDlg setAllowsMultipleSelection:NO];
	[openDlg setCanChooseDirectories:NO];
	
	[openDlg beginWithCompletionHandler:^(NSInteger result)
	{
		NSLog(@"QDocControl complettionHandler");
		
		if (result == NSModalResponseOK) {
			NSURL* url = [[openDlg URLs] firstObject];
			NSError* theError;
			// Open  the document.
			NSLog(@"QDocControl .. makeDocument:");
			[self makeDocumentWithContentsOfURL:url ofType:@"PDF" error:&theError];
			
			QPDFDocument* newDoc = [[[QPDFDocument alloc] initWithContentsOfURL:url ofType:@"PDF" error:&theError] autorelease];

			[self addDocument:newDoc];
			[newDoc makeWindowControllers];
			[newDoc showWindows];
			 
		}
	}];

}



- (void)newDocument:(id)sender
{
	[super newDocument:sender];

	NSLog(@"QDocControl: newDocument");

	NSError* theError;
	[self openUntitledDocumentAndDisplay:YES error:&theError];
	// why is there even an error return here?
	// cannot create new document... file not found, file corrupt, permission denied? this is not the new document you are looking for?
}

- (QPDFDocument*) openUntitledDocumentAndDisplay:(BOOL)dd error:(NSError **)outError
{
	NSLog(@"QDocControl: openUntitledDocumentAndDisplay: %d",dd);

	
	QPDFDocument* newDoc = [self makeUntitledDocumentOfType:@"PDF" error:outError];
	[self addDocument:newDoc];
	if (dd) {
		[newDoc makeWindowControllers];
	}
	return newDoc;
}

- (QPDFDocument*)makeUntitledDocumentOfType:(NSString*)pdf error:(NSError **)outError
{
	// NSLog(@"QDocControl: makeUntitledDocumentOfType");

	// we only ever deal with PDF
	return [[[QPDFDocument alloc] init] autorelease];
}

- (void)openPDF:(NSString*)filename
{
	NSLog(@"QDocControl: openPDF: %@",filename);

	NSURL* url = [NSURL fileURLWithPath:filename];
	NSError* theError;
	[self makeDocumentWithContentsOfURL:url ofType:@"PDF" error:&theError];
	// QPDFDocument* nd = [[[QPDFDocument alloc] initWithContentsOfURL:url ofType:@"" error:&theError] autorelease];
	// do want to check this error
//	[self addDocument:nd];
}

/*
- (BOOL)respondsToSelector:(SEL)aSelector
{
	NSString* selstr =NSStringFromSelector(aSelector);
	if (![selstr isEqualToString:@"validModesForFontPanel:"])
	{
		NSLog(@"DocumentController EVENT -> %@",NSStringFromSelector(aSelector));
		if( [QPDFWindowController instancesRespondToSelector:aSelector] ) {
			// invoke the inherited method
			return YES;
		}
	}
	return [super respondsToSelector:aSelector];
}
*/
@end
