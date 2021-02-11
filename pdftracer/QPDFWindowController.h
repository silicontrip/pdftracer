#import <Cocoa/Cocoa.h>
#import "QPDFDocument.h"
#import "QPDFNode.h"


@class QPDFDocument;
@class OutlineQPDF;  // arg inconsistent names!
@class OutlinePDFObj;
@class OutlinePDFPage;


@interface QPDFWindowController : NSWindowController <NSTextViewDelegate>
{
//	QPDFDocument* qDocument;
// NSWindow *window;
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
	
	NSInteger selectedRow;
	NSOutlineView* selectedView;
}

- (instancetype)initWithDocument:(QPDFDocument*)qp;

//+ (Boolean)hasNoIndirect:(QPDFObjectHandle)qpdfVal;

-(void)updatePDF;
-(void)textDidChange:(NSNotification *)notification;
-(void)textDidEndEditing:(NSNotification*)notification;
-(void)changeNotification:(NSNotification*)nn;
-(void)changeRow:(NSInteger)row forSource:(NSOutlineView*)ov;
- (void)selectChangeNotification:(NSOutlineView*)no;
-(void)selectObject:(id)sender;
- (void)replaceQPDFNode:(QPDFNode*)node withString:(NSString*)editor;
-(void)forwardInvocation:(NSInvocation*)inv;

-(void)changeFont:(id)sender;


@end
