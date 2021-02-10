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

-(NSString*)filename
{
	return [NSString stringWithUTF8String:qDocument.getFilename().c_str()];
}
-(NSString*)PDFVersion
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
-(QPDFObjectHandleObjc*)rootCatalog
{
	return [[QPDFObjectHandleObjc alloc] initWithObject:qDocument.getRoot()];
}
-(PDFDocument*)document
{
	QPDFWriter qpdfWriter(qDocument);
	qpdfWriter.setOutputMemory();
	qpdfWriter.write();

	Buffer* qBuf = qpdfWriter.getBuffer();
	unsigned char const* qBytes = qBuf->getBuffer();
	NSData* qPDFData = [NSData dataWithBytes:qBytes length:qBuf->getSize()];
	
	if (pDoc)
		[pDoc release];
	
	pDoc = [[PDFDocument alloc] initWithData:qPDFData];
	
	return pDoc;
}

@end
