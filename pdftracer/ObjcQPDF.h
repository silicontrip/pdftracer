#import <Foundation/Foundation.h>
#import "ObjcQPDFObjectHandle.h"
#import <Quartz/Quartz.h>

// C only stuff here

@interface ObjcQPDF : NSObject
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
-(NSArray<ObjcQPDFObjectHandle*>*)pages;
-(NSArray<ObjcQPDFObjectHandle*>*)objects;
//-(QPDFObjectHandleObjc*)rootCatalog;
-(ObjcQPDFObjectHandle*)copyRootCatalog; // naming convention for alloc

-(void)replaceID:(NSString*)objGen with:(ObjcQPDFObjectHandle*)obj;
-(void)removeID:(NSString*)objGen;

-(NSData*)data;
-(PDFDocument*)document;
-(NSData*)qdf;

@end
