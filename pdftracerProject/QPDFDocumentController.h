#import <AppKit/AppKit.h>
#import "QPDFDocument.hh"
#import <Foundation/Foundation.h>

@interface QPDFDocumentController : NSDocumentController <NSMenuDelegate>
{
	// NSMutableArray* qDocumentList;
	
}

//+ (void) load;
- (NSArray<NSString*>*) documentClassNames;
- (NSString*) defaultType;
- (Class)documentClassForType:(NSString *)typeName;

//- (QPDFDocument*)documentForURL:(NSURL*)uel;
//- (void)openDocument:(id)sender;
- (void)newDocument:(id)sender;
// - (QPDFDocument*) openUntitledDocumentAndDisplay:(BOOL)dd error:(NSError **)outError;
- (QPDFDocument*)makeUntitledDocumentOfType:(NSString*)type error:(NSError**)outError;
- (QPDFDocument*)makeDocumentWithContentsOfURL:(NSURL*)url ofType:(NSString *)type error:(NSError**)outError;
- (QPDFDocument*)openUntitledDocumentAndDisplay:(BOOL)dd error:(NSError **)outError;



//- (IBAction)newDocumentPDF:(id)sender;
//- (void)openDocumentPDF:(id)sender;
//- (void)menuHit:(id)sender;
//- (void)openPDF:(NSString*)filename;
@end
