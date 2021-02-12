#import <Foundation/Foundation.h>
#import "QPDFObjectHandleObjc.h"
#import <Quartz/Quartz.h>

// C only stuff here

@interface QPDFObjc : NSObject
{
// QPDF qDocument; // not here
	PDFDocument *pDoc;
}

-(instancetype)init; // empty pdf
-(instancetype)initWithURL:(NSURL*)fileURL;
-(instancetype)initWithData:(NSData*)pdfData;

-(NSURL*)fileURL;
-(NSString*)filename;
-(NSString*)version;
-(NSArray<QPDFObjectHandleObjc*>*)pages;
-(NSArray<QPDFObjectHandleObjc*>*)objects;
//-(QPDFObjectHandleObjc*)rootCatalog;
-(QPDFObjectHandleObjc*)copyRootCatalog; // naming convention for alloc 
-(NSData*)data;
-(PDFDocument*)document;

@end
