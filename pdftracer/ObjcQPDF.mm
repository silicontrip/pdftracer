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
		return [self objectHandle:qoh];
		// return [[[ObjcQPDFObjectHandle alloc] initWithObject:qoh] autorelease];
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
		// need to have a 1:1 mapping between QPDFObjectHandle and ObjC class
		return [self objectHandle:oai];
		// return [[[ObjcQPDFObjectHandle alloc] initWithObject:oai] autorelease];

	}
	return nil;
}

- (ObjcQPDFObjectHandle* _Nonnull)makeIndirectObject:(ObjcQPDFObjectHandle* _Nonnull)obj
{
	QPDFObjectHandle qoh = [obj qpdfobject];
	QPDFObjectHandle newInd = qDocument->makeIndirectObject(qoh);
	return [self objectHandle:newInd];
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

- (ObjcQPDFObjectHandle* _Nonnull)objectHandle:(QPDFObjectHandle)obj
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:obj];
	/* Doesn't work as expected
	NSValue* vobj = [NSValue valueWithPointer:&obj];
	if (!objcCache)
	{
		objcCache = [[NSMutableDictionary alloc] init];
	}
	if ([objcCache objectForKey:vobj])
	{
		return [objcCache objectForKey:vobj];
	}
	ObjcQPDFObjectHandle* oobj = [[ObjcQPDFObjectHandle alloc] initWithObject:obj];
	[objcCache setObject:oobj forKey:vobj];
	return oobj;
	 */
}

- (ObjcQPDFObjectHandle* _Nonnull)copyRootCatalog
{
	QPDFObjectHandle root = qDocument->getRoot();
	//ObjcQPDFObjectHandle * rootObjc = [[ObjcQPDFObjectHandle alloc] initWithObject:root];
	return [self objectHandle:root];
}

- (ObjcQPDFObjectHandle* _Nonnull)copyTrailer
{
	QPDFObjectHandle root = qDocument->getTrailer();
	// ObjcQPDFObjectHandle * rootObjc = [[ObjcQPDFObjectHandle alloc] initWithObject:root];
	//return rootObjc;
	return [self objectHandle:root];

}

- (PDFDocument* _Nonnull)document
{
	NSData* qPDFData = [self data];
	return [[[PDFDocument alloc] initWithData:qPDFData] autorelease];
}

- (NSData* _Nonnull)data
{

	QPDFWriter qwriter(*qDocument);
	qwriter.setStreamDataMode(qpdf_s_compress);
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
	QPDFWriter writer(*qDocument);
	writer.setQDFMode(true);

	writer.setOutputMemory();
	writer.write();

	Buffer* qBuf = writer.getBuffer();
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
	
	// Fix: Explicitly ensure MediaBox/CropBox are preserved/flattened
	// QPDF's addPage might not flatten inherited attributes automatically in all cases/versions.
	// We retrieve the new page (which is now in *qDocument).
	std::vector<QPDFPageObjectHelper> newPages = pdh.getAllPages();
	if (!newPages.empty()) {
		QPDFPageObjectHelper newPage = first ? newPages.front() : newPages.back();
		
		// Copy MediaBox if missing on new page but present (or inherited) on source
		if (!newPage.getObjectHandle().hasKey("/MediaBox")) {
			QPDFObjectHandle mbox = poh.getAttribute("/MediaBox", true);
			if (mbox.isInitialized() && !mbox.isNull()) {
				newPage.getObjectHandle().replaceKey("/MediaBox", mbox);
			}
		}
		
		// Copy CropBox if missing
		if (!newPage.getObjectHandle().hasKey("/CropBox")) {
			QPDFObjectHandle cbox = poh.getAttribute("/CropBox", true);
			if (cbox.isInitialized() && !cbox.isNull()) {
				newPage.getObjectHandle().replaceKey("/CropBox", cbox);
			}
		}
		
		// Copy Rotate if missing
		if (!newPage.getObjectHandle().hasKey("/Rotate")) {
			QPDFObjectHandle rotate = poh.getAttribute("/Rotate", true);
			if (rotate.isInitialized() && !rotate.isNull()) {
				newPage.getObjectHandle().replaceKey("/Rotate", rotate);
			}
		}

		// Copy UserUnit if missing (handles scaling)
		if (!newPage.getObjectHandle().hasKey("/UserUnit")) {
			QPDFObjectHandle userUnit = poh.getAttribute("/UserUnit", true);
			if (userUnit.isInitialized() && !userUnit.isNull()) {
				newPage.getObjectHandle().replaceKey("/UserUnit", userUnit);
			}
		}
		
		// Copy other boxes (TrimBox, ArtBox, BleedBox)
		for (const char* boxName : {"/TrimBox", "/ArtBox", "/BleedBox"}) {
			if (!newPage.getObjectHandle().hasKey(boxName)) {
				QPDFObjectHandle box = poh.getAttribute(boxName, true);
				if (box.isInitialized() && !box.isNull()) {
					newPage.getObjectHandle().replaceKey(boxName, box);
				}
			}
		}
	}

	[self makePageDirects];
}

@end
