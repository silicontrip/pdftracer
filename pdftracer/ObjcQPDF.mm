// put these in the implementation file so other parts of OBJC don't see the C++

#import "ObjcQPDF.hh"

@implementation ObjcQPDF

-(instancetype)init
{
	self = [super init];
	if (self)
	{
		qDocument = new QPDF();
		qDocument->emptyPDF();
	}
	return self;
}

-(instancetype)initWithURL:(NSURL*)fileURL
{
	self = [super init];
	if (self)
	{
		NSString *fn = [fileURL path];
		qDocument = new QPDF();
		qDocument->processFile([fn UTF8String]);
	}
	return self;
}

-(instancetype)initWithData:(NSData*)data
{
	self = [super init];
	if (self)
	{
		qDocument = new QPDF();
		qDocument->processMemoryFile("NSData", (char*)[data bytes], [data length]);  // initialise QPDF from memory
	}
	return self;
}

-(instancetype)initWithQPDF:(QPDF*)qpdf
{
	self = [super init];
	if (self)
	{
		qDocument = qpdf;
	}
	return self;
}

-(NSURL*)fileURL
{
	return [NSURL fileURLWithPath:[NSString stringWithUTF8String:qDocument->getFilename().c_str()]];
}

-(NSString*)filename
{
	return [NSString stringWithUTF8String:qDocument->getFilename().c_str()];
}

-(NSString*)version
{
	return [NSString stringWithUTF8String:qDocument->getPDFVersion().c_str()];
}

-(NSArray<ObjcQPDFObjectHandle*>*)pages
{
	return [ObjcQPDFObjectHandle arrayWithVector:qDocument->getAllPages()];
}

-(NSArray<ObjcQPDFObjectHandle*>*)objects
{
	return [ObjcQPDFObjectHandle arrayWithVector:qDocument->getAllObjects()];
}

-(void)replaceID:(NSString*)objGen with:(ObjcQPDFObjectHandle*)obj
{
	NSArray<NSString*>* objElem= [objGen componentsSeparatedByString:@" "];
	int objid = [[objElem objectAtIndex:0] intValue];
	int genid = [[objElem objectAtIndex:1] intValue];

	NSLog(@"QPDF replacing indirect: %d %d R with %@",objid,genid,obj);
		
	QPDFObjectHandle qoh = [obj qpdfobject];
	
	qDocument->replaceObject(objid,genid,qoh);
	
	NSString* doctex = [[[NSString alloc] initWithData:[self data] encoding:NSMacOSRomanStringEncoding] autorelease];
	NSLog(@"replaceID: %@",doctex);
}

-(void)removeID:(NSString*)objGen
{
	NSArray<NSString*>* objElem= [objGen componentsSeparatedByString:@" "];
	int objid = [[objElem objectAtIndex:0] intValue];
	int genid = [[objElem objectAtIndex:1] intValue];
	
	NSLog(@"QPDF replacing indirect: %d %d R with %@",objid,genid,objGen);
		
	qDocument->replaceObject(objid,genid,QPDFObjectHandle::newNull());
}


-(ObjcQPDFObjectHandle*)copyRootCatalog
{
	QPDFObjectHandle root = qDocument->getTrailer();
	ObjcQPDFObjectHandle * rootObjc = [[ObjcQPDFObjectHandle alloc] initWithObject:root];
	return rootObjc;
}
-(PDFDocument*)document
{
	NSData* qPDFData = [self data];
	return [[[PDFDocument alloc] initWithData:qPDFData] autorelease];
	
}

-(NSData*)data
{
	QPDFWriter qpdfWriter(*qDocument);
	qpdfWriter.setOutputMemory();
	qpdfWriter.write();
	
	Buffer* qBuf = qpdfWriter.getBuffer();
	unsigned char const* qBytes = qBuf->getBuffer();
	
	NSData* pdfData = [[[NSData alloc] initWithBytes:qBytes length:qBuf->getSize()] autorelease];
	delete(qBuf);
	return pdfData;
}

-(NSData*)qdf
{
	QPDFWriter qpdfWriter(*qDocument);
	qpdfWriter.setQDFMode(true);

	qpdfWriter.setOutputMemory();
	qpdfWriter.write();

	Buffer* qBuf = qpdfWriter.getBuffer();
	unsigned char const* qBytes = qBuf->getBuffer();
	
	NSData* pdfData = [[[NSData alloc] initWithBytes:qBytes length:qBuf->getSize()] autorelease];
	delete(qBuf);
	return pdfData;
}

@end
