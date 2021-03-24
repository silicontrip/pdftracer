#import <Foundation/Foundation.h>
#import "ObjcQPDFObjectHandle.h"
#import <Quartz/Quartz.h>

#import "ObjcPDFDocument.h"

// C only stuff here

@interface ObjcQPDF : NSObject<ObjcPDFDocument>
{
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
-(NSUInteger)countObjects;
-(NSUInteger)countPages;

-(ObjcQPDFObjectHandle*)objectAtIndex:(NSUInteger)index;
-(ObjcQPDFObjectHandle*)pageAtIndex:(NSUInteger)index;


-(id<ObjcPDFObject>)copyRootCatalog; // naming convention for alloc

-(void)replaceID:(NSString*)objGen with:(id<ObjcPDFObject>)obj;
-(void)removeID:(NSString*)objGen;

-(NSData*)data;
-(PDFDocument*)document;
-(NSData*)qdf;

-(void)addPage:(ObjcQPDFObjectHandle*)newpage atStart:(BOOL)first;
-(void)addPage:(ObjcQPDFObjectHandle*)newpage before:(BOOL)first page:(ObjcQPDFObjectHandle*)refpage;

@end
