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
	NSError* theError;
	return [[[QPDFDocument alloc] initWithContentsOfURL:url ofType:@"" error:&theError] autorelease];
}

- (void)openDocument:(id)sender
{

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

}
 

- (void)newDocument:(id)sender
{
	NSError* theError;
	[self openUntitledDocumentAndDisplay:YES error:&theError];
	// why is there even an error return here?
	// cannot create new document... file not found, file corrupt, permission denied?
}

- (QPDFDocument*) openUntitledDocumentAndDisplay:(BOOL)dd error:(NSError **)outError
{
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
	// we only ever deal with PDF
	return [[[QPDFDocument alloc] init] autorelease];
}

- (void)openPDF:(NSString*)filename
{
	NSURL* url = [NSURL fileURLWithPath:filename];
	NSError* theError;
	QPDFDocument* nd = [[[QPDFDocument alloc] initWithContentsOfURL:url ofType:@"" error:&theError] autorelease];
	// do want to check this error
	[self addDocument:nd];
}

@end
