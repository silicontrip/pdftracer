#import <Cocoa/Cocoa.h>
#import "QPDFDocument.hh"

#import "OutlineQPDF.hh"
#import "OutlinePDFObj.hh"
#import "OutlinePDFPage.hh"

@class QPDFDocument;

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
-(void)selectObject:(id)sender;
- (void)replaceQPDFNode:(QPDFNode*)node withString:(NSString*)editor;

@end
