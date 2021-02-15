#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#import "OutlineQPDF.h"
#import "OutlinePDFObj.h"
#import "OutlinePDFPage.h" 

@class OutlineQPDF;
@class OutlinePDFObj;
@class OutlinePDFPage;

@interface QPDFWindow : NSWindow
{

	PDFView *dView;
	PDFDocument *pDoc;

	OutlineQPDF* pdfDS;
	OutlinePDFPage* pageDS;
	OutlinePDFObj* objDS;
	
	// QPDF qDocument;
	// Buffer* rawDoc;
	NSTextView* tView;
	NSOutlineView* oView;
	NSOutlineView* ooView;
	NSOutlineView* opView;

	NSFont * tfont;
	
	NSSplitView* soView;
	NSSplitView* sView;
}

-(instancetype)initWithContentRect:(NSRect)rect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backing;
-(void)setDataSource;

-(void)setDocument:(PDFDocument*)pd;
-(NSString*)editorText;
-(void)setEditor:(NSString*)text;
-(void)enableEditor:(BOOL)ena;
-(void)updateAllOutlines:(QPDFNode*)node;
-(void)updateOutline:(NSOutlineView*)ov withNode:(QPDFNode*)nn;

@end
