#import <Foundation/Foundation.h>
#import "ObjcQPDFObjectHandle.h"
#import <Quartz/Quartz.h>

#import "ObjcPDFDocument.h"

// C only stuff here

@interface ObjcQPDF : NSObject<ObjcPDFDocument>
{
	PDFDocument *pDoc;
	NSDictionary<NSString*,NSNumber*>* pageDirects; //TODO: also need to handle adding/removing pages

	NSMutableDictionary<NSValue*,ObjcQPDFObjectHandle*>* objcCache;
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
- (instancetype _Nullable)init;
- (instancetype _Nullable)initWithData:(NSData* _Nonnull)data;
//- (instancetype)initWithQPDF:(QPDF*)qpdf;
- (instancetype _Nullable)initWithURL:(NSURL* _Nonnull)fileURL;
- (BOOL)isIndirectPage:(NSString* _Nonnull)objectGeneration;
- (void)makePageDirects;
- (ObjcQPDFObjectHandle* _Nullable)objectAtIndex:(NSString* _Nullable)objGen;
- (ObjcQPDFObjectHandle* _Nonnull)makeIndirectObject:(ObjcQPDFObjectHandle* _Nonnull)obj;
- (void)replaceID:(NSString* _Nonnull)objGen with:(ObjcQPDFObjectHandle* _Nonnull)obj;
- (NSNumber* _Nonnull)pageIndexForIndirect:(NSString* _Nonnull)objectGeneration;
- (NSString* _Nonnull)version;

@end
