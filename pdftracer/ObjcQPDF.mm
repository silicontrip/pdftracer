// put these in the implementation file so other parts of OBJC don't see the C++

#import "ObjcQPDF.hh"

@implementation ObjcQPDF

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		qDocument = new QPDF();
		qDocument->emptyPDF();
		
		// NSLog(@"init QPDF %@ - %lx",self,(unsigned long)qDocument);
	}
	return self;
}

- (instancetype)initWithURL:(NSURL*)fileURL
{
	self = [super init];
//	NSLog(@"ObjcQPDF initWithURL url %@ self %@",fileURL,self);  // open document is failing.

	if (self)
	{
		NSString *fn = [fileURL path];
		qDocument = new QPDF();
		qDocument->processFile([fn UTF8String]);
		pageDirects = nil;

		[self makePageDirects];
	}
//	NSLog(@"ObjcQPDF initWithURL qDocument %lx",(unsigned long)qDocument);  // open document is failing.

	return self;
}

- (instancetype)initWithData:(NSData* _Nonnull)data
{
	self = [super init];
	if (self)
	{
		qDocument = new QPDF();
		qDocument->processMemoryFile("NSData", (char*)[data bytes], [data length]);  // initialise QPDF from memory
		pageDirects = nil;

		// NSLog(@"initWithData QPDF %@ - %lx",self,(unsigned long)qDocument);
		[self makePageDirects];

	}
	return self;
}

// obj-c++ only method
- (instancetype)initWithQPDF:(QPDF*)qpdf
{
	self = [super init];
	if (self)
	{
		qDocument = qpdf;
		pageDirects = nil;
		// NSLog(@"(objc++) initWith QPDF %@ - %lx",self,(unsigned long)qDocument);
		[self makePageDirects];

	}
	return self;
}

- (void)makePageDirects
{
	if (pageDirects)
		[pageDirects release];
	std::vector<QPDFObjectHandle> pageList = qDocument->getAllPages();
	unsigned long sz = pageList.size();
	
	NSMutableDictionary<NSString*,NSNumber*>* pageIndex = [[[NSMutableDictionary alloc] init] autorelease];
	
	for (unsigned long index=0;index<sz;++index)
	{
		QPDFObjectHandle qObject = pageList[index];
		NSString* objKey = [NSString stringWithFormat:@"%d %d R",qObject.getObjectID(),qObject.getGeneration()];
		NSNumber* objVal = [NSNumber numberWithUnsignedLong:index];
		[pageIndex setObject:objVal forKey:objKey];
	}
	pageDirects = [pageIndex copy];  // is this retained?
	// copy method convention says it is
}


 // only for the other objc++ class
- (QPDF*)qpdf
{
	// NSLog(@"init QPDF %@ - %lx",self,(unsigned long)qDocument);

	return qDocument;
}

- (NSURL* _Nonnull)fileURL
{
	return [NSURL fileURLWithPath:[NSString stringWithUTF8String:qDocument->getFilename().c_str()]];
}

- (NSString* _Nonnull)filename
{
	return [NSString stringWithUTF8String:qDocument->getFilename().c_str()];
}

- (NSString* _Nonnull)version
{
	return [NSString stringWithUTF8String:qDocument->getPDFVersion().c_str()];
}

- (NSArray<ObjcQPDFObjectHandle*>* _Nonnull)pages
{
	return [ObjcQPDFObjectHandle arrayWithVector:qDocument->getAllPages()];
}

// - (NSUInteger)pageCount; // ??

- (NSUInteger)countPages
{
	return qDocument->getAllPages().size();
}

- (NSArray<ObjcQPDFObjectHandle*>* _Nonnull)objects
{
	return [ObjcQPDFObjectHandle arrayWithVector:qDocument->getAllObjects()];
}

- (NSUInteger)countObjects
{
	return qDocument->getObjectCount();
}

- (ObjcQPDFObjectHandle* _Nullable)pageAtIndex:(NSUInteger)index
{
	std::vector<QPDFObjectHandle> qohv = qDocument->getAllPages();
	if (index <qohv.size()) {
		QPDFObjectHandle qoh = qohv[index];
		return [[[ObjcQPDFObjectHandle alloc] initWithObject:qoh] autorelease];
	}
	return nil;
}

- (BOOL)isIndirectPage:(NSString* _Nonnull)objectGeneration
{
	if ([pageDirects objectForKey:objectGeneration] != nil)
		return YES;
	return NO;
}
- (NSNumber* _Nonnull)pageIndexForIndirect:(NSString* _Nonnull)objectGeneration
{
	return [pageDirects objectForKey:objectGeneration];
}

- (ObjcQPDFObjectHandle* _Nullable)pageForIndirect:(NSString* _Nonnull)objectGeneration
{
	if([pageDirects objectForKey:objectGeneration] != nil)
		return [self pageAtIndex:[[pageDirects objectForKey:objectGeneration] unsignedLongValue]];
	
	return nil;
}


- (ObjcQPDFObjectHandle* _Nullable)objectAtIndex:(NSString* _Nullable)objGen
{
	
	// i know we've been warned not to simply rely on the objectid, without the generation

	
	// fine have it your way
	if (objGen != nil)
	{
		NSArray<NSString*>* objElem= [objGen componentsSeparatedByString:@" "];
		int objid = [[objElem objectAtIndex:0] intValue];
		int genid = [[objElem objectAtIndex:1] intValue];
		
		QPDFObjectHandle oai = qDocument->getObjectByID(objid,genid);
		return [[[ObjcQPDFObjectHandle alloc] initWithObject:oai] autorelease];

	}
	return nil;
}


- (void)replaceID:(NSString* _Nonnull)objGen with:(ObjcQPDFObjectHandle* _Nonnull)obj
{
	if (obj != nil && objGen != nil)
	{
		NSArray<NSString*>* objElem= [objGen componentsSeparatedByString:@" "]; 
		int objid = [[objElem objectAtIndex:0] intValue];
		int genid = [[objElem objectAtIndex:1] intValue];

		// NSLog(@"QPDF replacing indirect: %d %d R with %@",objid,genid,obj);
		
		QPDFObjectHandle qoh = [obj qpdfobject];
		
		qDocument->replaceObject(objid,genid,qoh);
		
		// these two are a package deal
		// NSString* doctex = [[[NSString alloc] initWithData:[self data] encoding:NSMacOSRomanStringEncoding] autorelease];
		// NSLog(@"replaceID: %@",doctex);
	}
}

- (void)removeID:(NSString* _Nonnull)objGen
{
	NSArray<NSString*>* objElem= [objGen componentsSeparatedByString:@" "];
	int objid = [[objElem objectAtIndex:0] intValue];
	int genid = [[objElem objectAtIndex:1] intValue];
	
	// NSLog(@"QPDF replacing indirect: %d %d R with %@",objid,genid,objGen);
		
	qDocument->replaceObject(objid,genid,QPDFObjectHandle::newNull());
}

- (ObjcQPDFObjectHandle* _Nonnull)copyRootCatalog
{
	QPDFObjectHandle root = qDocument->getRoot();
	ObjcQPDFObjectHandle * rootObjc = [[ObjcQPDFObjectHandle alloc] initWithObject:root];
	return rootObjc;
}

- (ObjcQPDFObjectHandle* _Nonnull)copyTrailer
{
	QPDFObjectHandle root = qDocument->getTrailer();
	ObjcQPDFObjectHandle * rootObjc = [[ObjcQPDFObjectHandle alloc] initWithObject:root];
	return rootObjc;
}

- (PDFDocument* _Nonnull)document
{
	NSData* qPDFData = [self data];
	return [[[PDFDocument alloc] initWithData:qPDFData] autorelease];
}

- (NSData* _Nonnull)data
{

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

- (NSData* _Nonnull)qdf
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

// looks simpler than I thought... something must be wrong
// these are the legacy methods.
// should look at using qpdf page document helper

// um, so which one of these is working?

- (void)addPage:(ObjcQPDFObjectHandle* _Nonnull)newpage atStart:(BOOL)first
{
	qDocument->addPage([newpage qpdfobject],first);  // now what?
	[self makePageDirects];
}

- (void)addPage:(ObjcQPDFObjectHandle* _Nonnull)newpage before:(BOOL)first page:(ObjcQPDFObjectHandle* _Nonnull)refpage
{
	qDocument->addPageAt([newpage qpdfobject], first, [refpage qpdfobject]);
	[self makePageDirects];

}

- (void)addPageUsingHelper:(ObjcQPDFObjectHandle* _Nonnull)page atStart:(BOOL)first
{
	QPDFPageObjectHelper poh = QPDFPageObjectHelper([page qpdfobject]);
	QPDFPageDocumentHelper pdh = QPDFPageDocumentHelper(*qDocument);
	
	pdh.addPage(poh,first);
	[self makePageDirects];

}

@end
