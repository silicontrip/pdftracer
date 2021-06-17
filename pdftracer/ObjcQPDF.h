#import <Foundation/Foundation.h>
#import "ObjcQPDFObjectHandle.h"
#import <Quartz/Quartz.h>

#import "ObjcPDFDocument.h"

// C only stuff here

@interface ObjcQPDF : NSObject<ObjcPDFDocument>
{
	PDFDocument *pDoc;
	NSDictionary<NSString*,NSNumber*>* pageDirects; //TODO: also need to handle adding/removing pages
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

//-(ObjcQPDFObjectHandle*)objectAtIndex:(NSUInteger)index;
-(ObjcQPDFObjectHandle*)objectAtIndex:(NSString*)objGen;

-(ObjcQPDFObjectHandle*)pageAtIndex:(NSUInteger)index;

-(BOOL)isIndirectPage:(NSString*)objectGeneration;
-(NSNumber*)pageIndexForIndirect:(NSString*)objectGeneration;
-(ObjcQPDFObjectHandle*)pageForIndirect:(NSString*)objectGeneration;

-(id<ObjcPDFObject>)copyRootCatalog; // naming convention for alloc
-(ObjcQPDFObjectHandle*)copyTrailer;

-(void)replaceID:(NSString*)objGen with:(id<ObjcPDFObject>)obj;
-(void)removeID:(NSString*)objGen;

-(NSData*)data;
-(PDFDocument*)document;
-(NSData*)qdf;

-(void)addPage:(ObjcQPDFObjectHandle*)newpage atStart:(BOOL)first;
-(void)addPage:(ObjcQPDFObjectHandle*)newpage before:(BOOL)first page:(ObjcQPDFObjectHandle*)refpage;
-(void)addPageUsingHelper:(ObjcQPDFObjectHandle*)page atStart:(BOOL)first;

@end
