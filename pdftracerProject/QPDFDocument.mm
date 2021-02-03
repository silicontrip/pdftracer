//
//  QPDFDocument.m
//  pdftracer
//
//  Created by Mark Heath on 28/1/21.
//  Copyright © 2021 silicontrip. All rights reserved.
//

#import "QPDFDocument.hh"

@implementation QPDFDocument

-(instancetype)init
{
	NSLog(@"QPDFDocument init");
	self=[super init];
	if (self) {
		pDoc = nil;
		[self setFileURL:nil];
		qDocument.emptyPDF();

	//	[self source];

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
	NSLog(@"QPDFDocument initForURL: %@",contentsURL);
	[self setFileURL:urlOrNil];
	self = [super init];
	if (self) {
		pDoc = nil;
		//	NSString *fn = [url description];
		contentData = [[NSData alloc] initWithContentsOfURL:contentsURL]; // read data from file
		
		/* we know that it is correct upto here
		 NSString* pdfd = [[NSString alloc] initWithData:content encoding:NSMacOSRomanStringEncoding];
		 NSLog(@"%@",pdfd);
		 */
		
		qDocument.processMemoryFile("memory", (char*)[contentData bytes], [contentData length]);  // initialise QPDF from memory
		
		/*
		 NSData * depro = [self dataOfType:@"" error:nil];
		 NSString* pdfd = [[NSString alloc] initWithData:depro encoding:NSMacOSRomanStringEncoding];
		 NSLog(@"%@",pdfd);
		 */
		
		//	[QPDFDocument pdfretain:qDocument];
		
		[self source];
	}
	return self;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError
{
	NSLog(@"QPDFDocument readFromURL: %@",url);
	[self setFileURL:url];
	NSString *fn = [url description];

	NSData *content = [[NSData dataWithContentsOfURL:url] autorelease]; // read data from file
	qDocument.processMemoryFile([fn UTF8String], (char*)[content bytes], [content length]);  // initialise QPDF from memory
	
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
	QPDFWriter qpdfWriter(qDocument);
	qpdfWriter.setOutputMemory();
	qpdfWriter.write();
	
	Buffer* qBuf = qpdfWriter.getBuffer();
	unsigned char const* qBytes = qBuf->getBuffer();
	NSData* qPDFData = [NSData dataWithBytes:qBytes length:qBuf->getSize()];
	return [qPDFData writeToURL:url atomically:YES];
}
 
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error if you return nil.
    // Alternatively, you could remove this method and override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
	
	QPDFWriter qpdfWriter(qDocument);
	qpdfWriter.setOutputMemory();
	qpdfWriter.write();
	
	Buffer* qBuf = qpdfWriter.getBuffer();
	unsigned char const* qBytes = qBuf->getBuffer();
	return [[NSData alloc] initWithBytes:qBytes length:qBuf->getSize()];
	
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
	NSLog(@"QPDFDocument readFromData");
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error if you return NO.
    // Alternatively, you could remove this method and override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you do, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
	
	qDocument.processMemoryFile("NSData", (char*)[data bytes], [data length]);  // initialise QPDF from memory
	
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
	QPDFWriter qpdfWriter(qDocument);

	qpdfWriter.setOutputMemory();
	qpdfWriter.write();

	// return @"document get buffer to string disabled";
	
	Buffer* qBuf = qpdfWriter.getBuffer();
	unsigned char const* qBytes = qBuf->getBuffer();
	NSData* qPDFData = [NSData dataWithBytes:qBytes length:qBuf->getSize()];
	
	return [[NSString alloc] initWithData:qPDFData encoding:NSMacOSRomanStringEncoding];
	
}

- (PDFDocument*)pdfdocument
{
	QPDF qLocal = qDocument;
	NSLog(@"QPDFDocument create PDFView");
	QPDFWriter qpdfWriter(qDocument);
	qpdfWriter.setOutputMemory();
	qpdfWriter.write();
	
	
	Buffer* qBuf = qpdfWriter.getBuffer();
	unsigned char const* qBytes = qBuf->getBuffer();
	NSData* qPDFData = [NSData dataWithBytes:qBytes length:qBuf->getSize()];
	
//	NSDictionary* stringOptions = [NSDictionary dictionaryWithObjectsAndKeys:<#(nonnull id), ...#>, nil]
	NSLog(@"QPDFDocument make PDFDocument:");

	NSString* pdfd = [[NSString alloc] initWithData:qPDFData encoding:NSMacOSRomanStringEncoding];
	
	NSLog(@"%@",pdfd);
	
	NSLog(@"PDFView pdfdata: %@",qPDFData);
	
	// release old pdf doc
	
	NSLog(@"PDFView release old data: %@",pDoc);
	
	if (pDoc)
		[pDoc release];
	
	pDoc = [[PDFDocument alloc] initWithData:qPDFData];
	
	return pDoc;
	
}

+ (Boolean)hasNoIndirect:(QPDFObjectHandle)qpdfVal
{
	QPDFObjectHandle qpdf = qpdfVal;
	if (qpdf.isDictionary()) {
		//	NSLog(@"sel obj: %@ isDict",[node name]);
		std::set<std::string> keys = qpdf.getKeys();
		std::set<std::string>::iterator iterKey;
		for(iterKey = keys.begin(); iterKey != keys.end(); ++iterKey)
		{
			if(![QPDFDocument hasNoIndirect:(qpdf.getKey(*iterKey))])
				return NO;
		}
	} else if (qpdf.isArray()) {
		// NSLog(@"sel obj isArray");
		
		for (int index=0; index<qpdf.getArrayNItems();++index)
		{
			if (![QPDFDocument hasNoIndirect:(qpdf.getArrayItem(index))])
				return NO;
		}
	} else if (qpdf.isIndirect()) {
		return NO;
	}
	
	return YES;
}

-(void)makeWindowControllers
{
	NSLog(@"QPDFDocument makeWindowControllers");
	QPDFWindowController* winCon = [[QPDFWindowController alloc] initWithDocument:self];
	[self addWindowController:winCon ];
}
-(void)source;
{
	
//	 NSLog(@"special source, lettuce, cheese, on a: %@",[self pdfString]);
	
	pdfDS = [[OutlineQPDF alloc] initWithPDF:qDocument];
	objDS = [[OutlinePDFObj alloc] initWithPDF:qDocument];
	pageDS = [[OutlinePDFPage alloc] initWithPDF:qDocument];
	
//	winCon = [[QPDFWindowController alloc] initWithDocument:self];

}

- (OutlineQPDF*)pdfDataSource { return pdfDS; }
- (OutlinePDFObj*)pdfObjDataSource { return objDS; }
- (OutlinePDFPage*)pdfPageDataSource { return pageDS; }

@end
