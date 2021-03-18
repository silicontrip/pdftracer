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
		
		NSLog(@"init QPDF %@ - %lx",self,(unsigned long)qDocument);
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
		NSLog(@"initWithURL QPDF %@ - %lx",self,(unsigned long)qDocument);

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
		
		NSLog(@"initWithData QPDF %@ - %lx",self,(unsigned long)qDocument);

	}
	return self;
}

// obj-c++ only method
-(instancetype)initWithQPDF:(QPDF*)qpdf
{
	self = [super init];
	if (self)
	{
		qDocument = qpdf;
		
		NSLog(@"(objc++) initWith QPDF %@ - %lx",self,(unsigned long)qDocument);

	}
	return self;
}

 // only for the other objc++ class
-(QPDF*)qpdf
{
	NSLog(@"init QPDF %@ - %lx",self,(unsigned long)qDocument);

	return qDocument;
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
	if (obj != nil && objGen != nil)
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
//	NSLog(@">>> ObjcQPDF data");
	
	QPDFWriter qwriter(*qDocument);
	qwriter.setOutputMemory();
	qwriter.write();
	
	Buffer* qBuf = qwriter.getBuffer();
	unsigned char const* qBytes = qBuf->getBuffer();
	
	NSData* pdfData = [[[NSData alloc] initWithBytes:qBytes length:qBuf->getSize()] autorelease];
	delete(qBuf);
	// #507 https://github.com/qpdf/qpdf/discussions/507
//	delete(qDocument);
//	qDocument = new QPDF();
//	qDocument->processMemoryFile("NSData", (char*)[pdfData bytes], [pdfData length]);
//	NSLog(@"<<< ObjcQPDF data");

	return pdfData;
}

-(NSData*)data_507
{
	NSLog(@"getData");
	qDocument->setImmediateCopyFrom(TRUE);
	QPDF* tempQ = new QPDF(*qDocument);
	
	NSLog(@"init Qwriter");

	QPDFWriter w(*tempQ);
	NSLog(@"output memory");

	w.setOutputMemory();
	NSLog(@"write");

	w.write();
	
	NSLog(@"getBuffer");

	
	Buffer* qBuf = qpdfWriter->getBuffer();
	unsigned char const* qBytes = qBuf->getBuffer();
	
	NSLog(@"init NSData");

	NSData* pdfData = [[[NSData alloc] initWithBytes:qBytes length:qBuf->getSize()] autorelease];
	qDocument->setImmediateCopyFrom(FALSE);
	
	delete(qBuf);
	delete (tempQ);
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
