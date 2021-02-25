#import "ObjcPDFObject.h"
#import <Quartz/Quartz.h>

@protocol ObjcPDFObject;

@protocol ObjcPDFDocument <NSObject>

- (instancetype)init;
- (instancetype)initWithURL:(NSURL*)fileURL;
- (instancetype)initWithData:(NSData*)data;
- (NSURL*)fileURL;
- (NSString*)filename;
- (NSString*)version;
- (NSArray*)pages;
- (NSArray*)objects;
- (void)replaceID:(NSString*)objGen with:(id<ObjcPDFObject>)obj;
- (void)removeID:(NSString*)objGen;
- (id<ObjcPDFObject>)copyRootCatalog;
- (PDFDocument*)document;
- (NSData*)data;

@optional
// - (instancetype)initWithPDF:(QPDF*)qpdf;

@end
