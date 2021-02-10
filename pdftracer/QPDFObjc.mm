#import "QPDFObjc.hh"
// put these in the implementation file so other parts of OBJC don't see the C++
#include <iostream>

#include <qpdf/QPDF.hh>
#include <qpdf/QPDFWriter.hh>

@interface QPDFObjc ()
{
	@private
	QPDF qDocument;   // but we hide it from all the other
}

@end

@implementation QPDFObjc

-(instancetype)init
{
	self = [super init];
	if (self) {
		qDocument.emptyPDF();
	}
	return self;

}

-(instancetype)initWithURL:(NSURL*)fileURL
{
	self = [super init];
	if (self) {
                NSString *fn = [fileURL path];
                qDocument.processFile([fn UTF8String]);
	}
	return self;
}

-(NSString*)filename
{
	return [NSString stringWithUTF8String:qDocument.getFilename().c_str()];
}
-(NSString*)pdfVersion
{
	return [NSString stringWithUTF8String:qDocument.getPDFVersion().c_str()];

}
-(NSArray<QPDFObjectHandleObjc*>*)pages;
-(NSArray<*>*)objects;
-(QPDFObjectHandleObjc*)rootCatalog;
-(PDFDocument*)document
{
	;
}

@end
