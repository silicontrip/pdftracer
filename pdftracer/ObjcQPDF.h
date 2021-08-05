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

- (void)addPage:(ObjcQPDFObjectHandle* _Nonnull)newpage atStart:(BOOL)first;
- (void)addPage:(ObjcQPDFObjectHandle* _Nonnull)newpage before:(BOOL)first page:(ObjcQPDFObjectHandle* _Nonnull)refpage;
- (void)addPageUsingHelper:(ObjcQPDFObjectHandle* _Nonnull)page atStart:(BOOL)first;
- (ObjcQPDFObjectHandle* _Nonnull)copyRootCatalog;
- (ObjcQPDFObjectHandle* _Nonnull)copyTrailer;
- (NSUInteger)countObjects;
- (NSUInteger)countPages;
- (NSData* _Nonnull)data;
- (PDFDocument* _Nonnull)document;
- (NSString* _Nonnull)filename;
- (NSURL* _Nonnull)fileURL;
- (instancetype)init;
- (instancetype)initWithData:(NSData* _Nonnull)data;
//- (instancetype)initWithQPDF:(QPDF*)qpdf;
- (instancetype)initWithURL:(NSURL*)fileURL;
- (BOOL)isIndirectPage:(NSString* _Nonnull)objectGeneration;
- (void)makePageDirects;
- (ObjcQPDFObjectHandle* _Nullable)objectAtIndex:(NSString* _Nullable)objGen;
//-(ObjcQPDFObjectHandle*)objectAtIndex:(NSUInteger)index;
- (NSArray<ObjcQPDFObjectHandle*>* _Nonnull)objects;
- (ObjcQPDFObjectHandle* _Nullable)pageAtIndex:(NSUInteger)index;
- (ObjcQPDFObjectHandle* _Nullable)pageForIndirect:(NSString* _Nonnull)objectGeneration;
- (NSNumber* _Nonnull)pageIndexForIndirect:(NSString* _Nonnull)objectGeneration;
- (NSArray<ObjcQPDFObjectHandle*>* _Nonnull)pages;
- (NSData* _Nonnull)qdf;
// - (QPDF*)qpdf;
- (void)removeID:(NSString* _Nonnull)objGen;
- (void)replaceID:(NSString* _Nonnull)objGen with:(ObjcQPDFObjectHandle* _Nonnull)obj;
- (NSString* _Nonnull)version;

@end
