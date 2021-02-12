//
//  QPDFDocument.m
//  pdftracer
//
//  Created by Mark Heath on 28/1/21.
//  Copyright © 2021 silicontrip. All rights reserved.
//

#import "QPDFDocument.h"

#import "OutlineQPDF.h"
#import "OutlinePDFPage.h"
#import "OutlinePDFObj.h"
#import "QPDFWindowController.h"
#import "QPDFObjc.h"

@implementation QPDFDocument

-(instancetype)init
{
//	NSLog(@"QPDFDocument init");
	self=[super init];
	if (self) {
		pDoc = nil;
		[self setFileURL:nil];
		qDocument = [[QPDFObjc alloc] init];
	}
	return self;
}

// - (instancetype)initWithType:(NSString *)typeName error:(NSError * _Nullable *)outError

- (instancetype)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError
{
	return [self initForURL:url withContentsOfURL:url ofType:@"PDF" error:outError];
}

- (nullable instancetype)initForURL:(nullable NSURL *)urlOrNil withContentsOfURL:(NSURL *)contentsURL ofType:(NSString *)typeName error:(NSError **)outError
{
	self = [super init];
	if (self) {
		[self setFileURL:urlOrNil];
	//	NSLog(@"QPDFDocument %@ initForURL: %@",self,contentsURL);

		pDoc = nil;
		qDocument = [[QPDFObjc alloc] initWithURL:urlOrNil];
	}
	return self;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError
{
//	NSLog(@"QPDFDocument %@ readFromURL: %@",self,url);
	[self setFileURL:url];
	//NSString *fn = [url description];

	//NSData *content = [[NSData dataWithContentsOfURL:url] autorelease]; // read data from file
	//qDocument.processMemoryFile([fn UTF8String], (char*)[content bytes], [content length]);  // initialise QPDF from memory
	
	qDocument = [[QPDFObjc alloc] initWithURL:url];
	
//	[self source];
	
	return YES;
}

/*
- (void)setFileURL:(NSURL *)fu
{
	fileURL = fu;
}

- (NSURL*)fileURL
{
	return fileURL;
}
*/
- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError
{
	return [[qDocument data] writeToURL:url atomically:YES];
}
 
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error if you return nil.
    // Alternatively, you could remove this method and override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
	
	return [qDocument data];
	
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
//	NSLog(@"QPDFDocument readFromData");
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error if you return NO.
    // Alternatively, you could remove this method and override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you do, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
	
	qDocument = [[QPDFObjc alloc] initWithData:data];
	//.processMemoryFile("NSData", (char*)[data bytes], [data length]);  // initialise QPDF from memory
	
//	[self source];
	
	return YES;

}

- (void)saveDocument:(nullable id)sender
{
	// NSLog(@"Jesus says you are saved, oh right, it's just a hard drive file called %@",[qDocument filename]);
	for (NSWindowController* wc in [self windowControllers])
		[wc setDocumentEdited:NO];
	
	NSError *theError;
	NSURL * fn = [NSURL fileURLWithPath:[qDocument filename]];

	[self writeToURL:fn ofType:@"PDF" error:&theError];
	
}

- (void)saveDocumentAs:(nullable id)sender
{
	NSLog(@"Jesus says you are saved as bro, ");
	NSLog(@"Aww man you want me to open up a dialog box?");
	
	NSString * fn = [self displayName];

	
	NSWindow* w = [[[self windowControllers] firstObject] window];

	NSSavePanel* p = [NSSavePanel savePanel];
	[p retain];
	[p setNameFieldStringValue:fn];
	[p beginSheetModalForWindow:w completionHandler:^(NSInteger result){
		if (result == NSModalResponseOK)
		{
			NSURL*  theFile = [p URL];
			NSError *theError;
			[self writeToURL:theFile ofType:@"PDF" error:&theError];
			// Write the contents in the new format.
			[[[self windowControllers] firstObject] setDocumentEdited:NO];

		}
		[p autorelease];
	}];
}


+ (BOOL)autosavesInPlace {
    return NO;
}

- (NSString*)pdfString
{
	return [[[NSString alloc] initWithData:[qDocument data] encoding:NSMacOSRomanStringEncoding] autorelease];
}

- (PDFDocument*)pdfdocument
{
	return [qDocument document];
}

-(void)makeWindowControllers
{
	NSLog(@"QPDFDocument %@ makeWindowControllers",self);
	QPDFWindowController* winCon = [[[QPDFWindowController alloc] initWithDocument:self] autorelease];
	[self addWindowController:winCon ];
//	[self setWindow:[winCon window]];
}

- (QPDFObjc*)doc
{
	return qDocument;
}

- (NSString*)displayName
{
	NSString * fn = [qDocument filename];
	if ([fn isEqualToString:@"empty PDF"])
		return @"Untitled";
	
//	NSLog(@"FN: %@",fn);
	
	return [fn lastPathComponent];
}

/*
- (BOOL)respondsToSelector:(SEL)aSelector
{
	NSString* selstr =NSStringFromSelector(aSelector);
	if (![selstr isEqualToString:@"validModesForFontPanel:"])
	{
		NSLog(@"DOC EVENT -> %@",NSStringFromSelector(aSelector));
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
	return [QPDFDocumentController sharedDocumentController];
}
*/
@end
