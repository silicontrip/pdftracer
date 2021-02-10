#import <Foundation/Foundation.h>
#import "QPDFObjectHandleObjc.hh"
#import <Quartz/Quartz.h>

@interface QPDFObjc : NSObject
{
// QPDF qDocument; // not here
}

-(instancetype)init; // empty pdf
-(instancetype)initWithURL:(NSURL*)fileURL;


-(NSString*)filename;
-(NSString*)pdfVersion;
-(NSArray<QPDFObjectHandleObjc*>*)pages;
-(NSArray<QPDFObjectHandleObjc*>*)objects;
-(QPDFObjectHandleObjc*)rootCatalog;
-(PDFDocument*)document;

@end
