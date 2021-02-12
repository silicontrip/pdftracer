// put these in the implementation file so other parts of OBJC don't see the C++

#import "QPDFObjc.hh"



@implementation QPDFObjc

-(instancetype)init
{
	self = [super init];
	if (self) {
		qDocument.emptyPDF();
		pDoc = nil;
	}
	return self;

}

-(instancetype)initWithURL:(NSURL*)fileURL
{
	self = [super init];
	if (self) {
		NSString *fn = [fileURL path];
		pDoc = nil;
		qDocument.processFile([fn UTF8String]);
	}
	return self;
}

-(instancetype)initWithData:(NSData*)data
{
	self = [super init];
	if (self) {
		pDoc=nil;
		qDocument.processMemoryFile("NSData", (char*)[data bytes], [data length]);  // initialise QPDF from memory
	}
	return self;
}

-(NSURL*)fileURL
{
	return [NSURL fileURLWithPath:[NSString stringWithUTF8String:qDocument.getFilename().c_str()]];
}
-(NSString*)filename
{
	return [NSString stringWithUTF8String:qDocument.getFilename().c_str()];
}
-(NSString*)version
{
	return [NSString stringWithUTF8String:qDocument.getPDFVersion().c_str()];

}
-(NSArray<QPDFObjectHandleObjc*>*)pages
{
	return [QPDFObjectHandleObjc arrayWithVector:qDocument.getAllPages()];
}
-(NSArray<QPDFObjectHandleObjc*>*)objects
{
	return [QPDFObjectHandleObjc arrayWithVector:qDocument.getAllObjects()];
}
-(QPDFObjectHandleObjc*)copyRootCatalog
{
	QPDFObjectHandle root = qDocument.getRoot();
	QPDFObjectHandleObjc * rootObjc = [[QPDFObjectHandleObjc alloc] initWithObject:root];
	return rootObjc;
}
-(PDFDocument*)document
{
	NSData* qPDFData = [self data];
	if (pDoc)
		[pDoc release];
	
	pDoc = [[[PDFDocument alloc] initWithData:qPDFData] autorelease];
	
	return pDoc;
}

-(NSData*)data
{
	QPDFWriter qpdfWriter(qDocument);
	qpdfWriter.setOutputMemory();
	qpdfWriter.write();
	
	Buffer* qBuf = qpdfWriter.getBuffer();
	unsigned char const* qBytes = qBuf->getBuffer();
	return [[[NSData alloc] initWithBytes:qBytes length:qBuf->getSize()] autorelease];
}

@end
