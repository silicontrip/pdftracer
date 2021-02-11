#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

#import "QPDFDocument.h"

@class QPDFDocument;

@interface QPDFDocumentController : NSDocumentController <NSMenuDelegate>
{
	// NSMutableArray* qDocumentList;
	
}

// + (void)load;
- (nonnull NSArray<NSString*>*)documentClassNames;
- (nonnull NSString*)defaultType;
- (nonnull Class)documentClassForType:(nullable NSString *)typeName;
//- (nullable __kindof NSDocument*)documentForURL:(NSURL* _Nullable)uel;
// - (nullable __kindof NSDocument*)documentForWindow:(NSWindow *)window;
- (nullable __kindof NSDocument*)makeDocumentWithContentsOfURL:(NSURL*_Nullable)url ofType:(NSString *_Nullable)type error:(NSError*_Nonnull*_Nullable)outError;
- (void)openDocument:(id _Nullable)sender;
- (void)newDocument:(id _Nullable)sender;
- (QPDFDocument* _Nonnull)openUntitledDocumentAndDisplay:(BOOL)dd error:(NSError * _Nullable * _Nullable)outError;
- (QPDFDocument* _Nonnull)makeUntitledDocumentOfType:(NSString* _Nullable)pdf error:(NSError * _Nullable * _Nullable)outError;
- (void)openPDF:(NSString* _Nonnull)filename;
;

@end;

