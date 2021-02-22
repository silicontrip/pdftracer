#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#import "OutlineQPDF.h"
#import "OutlineQPDFObj.h"
#import "OutlineQPDFPage.h" 

@class OutlineQPDF;
@class OutlineQPDFObj;
@class OutlineQPDFPage;

@interface QPDFWindow : NSWindow
{

	PDFView *dView;
	PDFDocument *pDoc;

	OutlineQPDF* pdfDS;
	OutlineQPDFPage* pageDS;
	OutlineQPDFObj* objDS;
	
	// QPDF qDocument;
	// Buffer* rawDoc;
	NSTextView* tView;
	NSOutlineView* oView;
	NSOutlineView* ooView;
	NSOutlineView* opView;

	NSSegmentedControl* oSegment;
	NSSegmentedControl* ooSegment;
	NSSegmentedControl* opSegment;
	
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
-(void)invalidateAll;

@end
