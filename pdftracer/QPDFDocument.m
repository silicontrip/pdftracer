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


@interface QPDFDocument()
{
	QPDFObjc* qDocument;
}

@end

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

//- (void)read


+ (BOOL)autosavesInPlace {
    return NO;
}
/*
+ (void)pdfretain:(QPDF)document
{
	QPDFWriter qpdfWriter(document);
	qpdfWriter.setOutputMemory();
	qpdfWriter.write();
}
*/
- (NSString*)pdfString
{
	return [[NSString alloc] initWithData:[qDocument data] encoding:NSMacOSRomanStringEncoding];
}

- (PDFDocument*)pdfdocument
{
	return [qDocument document];
}

-(void)makeWindowControllers
{
	NSLog(@"QPDFDocument %@ makeWindowControllers",self);
	QPDFWindowController* winCon = [[QPDFWindowController alloc] initWithDocument:self];
	[self addWindowController:winCon ];
}

- (QPDFObjc*)doc
{
	return qDocument;
}

- (NSString*)filePath
{
	NSString * fn = [qDocument filename];
	if ([fn isEqualToString:@"empty PDF"])
		return @"Untitled";
	
//	NSLog(@"FN: %@",fn);
	
	return [fn lastPathComponent];
}

- (void)saveDocumentAs:(id)sender
{
	NSLog(@"save as %@",sender);
	
}

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

/*
- (NSResponder*)nextResponder
{
	return [QPDFDocumentController sharedDocumentController];
}
*/
@end
