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
	NSLog(@"QDocControl: makeDocumentWithContentsOfURL");
	NSError* theError;
	
	QPDFDocument* newDoc=[[[QPDFDocument alloc] initWithContentsOfURL:url ofType:@"PDF" error:&theError] autorelease];
	[self addDocument:newDoc];
	return newDoc;
}

- (void)openDocument:(id)sender
{
	NSLog(@"QDocControl: openDocument");

	NSOpenPanel* openDlg = [NSOpenPanel openPanel];  // nsopenpanel *opn = NSOpenPanel::openPanel();
	[openDlg setCanChooseFiles:YES];
	[openDlg setAllowsMultipleSelection:NO];
	[openDlg setCanChooseDirectories:NO];
	
	[openDlg beginWithCompletionHandler:^(NSInteger result){
		if (result == NSModalResponseOK) {
			NSURL* url = [[openDlg URLs] firstObject];
			NSError* theError;
			// Open  the document.

			[self makeDocumentWithContentsOfURL:url ofType:@"PDF" error:&theError];
			/*
			QPDFDocument* newDoc = [[[QPDFDocument alloc] initWithContentsOfURL:url ofType:@"" error:&theError] autorelease];
			[self addDocument:newDoc];
			[newDoc makeWindowControllers];
			[newDoc showWindows];
			 */
		}
	}];

}

- (void)newDocument:(id)sender
{
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
	NSLog(@"QDocControl: makeUntitledDocumentOfType");

	// we only ever deal with PDF
	return [[[QPDFDocument alloc] init] autorelease];
}

- (void)openPDF:(NSString*)filename
{
	NSLog(@"QDocControl: openPDF");

	NSURL* url = [NSURL fileURLWithPath:filename];
	NSError* theError;
	[self makeDocumentWithContentsOfURL:url ofType:@"PDF" error:&theError];
	// QPDFDocument* nd = [[[QPDFDocument alloc] initWithContentsOfURL:url ofType:@"" error:&theError] autorelease];
	// do want to check this error
//	[self addDocument:nd];
}

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

@end
