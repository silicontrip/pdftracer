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

-(NSString*)filename;
-(NSString*)PDFVersion;
-(NSArray<QPDFObjectHandleObjc*>*)pages;
-(NSArray<QPDFObjectHandleObjc*>*)objects;
-(QPDFObjectHandleObjc*)rootCatalog;
-(PDFDocument*)document;

@end
