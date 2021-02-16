#import <Cocoa/Cocoa.h>
#import "QPDFDocument.h"
#import "QPDFNode.h"

@class QPDFDocument;
@class OutlineQPDF;  // arg inconsistent names!
@class OutlinePDFObj;
@class OutlinePDFPage;
@class QPDFWindow;

@interface QPDFWindowController : NSWindowController <NSTextViewDelegate>
{	
	NSInteger selectedRow;
	NSOutlineView* selectedView;
}

- (instancetype)initWithWindow:(QPDFWindow*)nsw;

//+ (Boolean)hasNoIndirect:(QPDFObjectHandle)qpdfVal;

- (void)updatePDF;
- (void)textDidChange:(NSNotification *)notification;
- (void)textDidEndEditing:(NSNotification*)notification;
- (void)changeNotification:(NSNotification*)nn;
- (void)changeRow:(NSInteger)row forSource:(NSOutlineView*)ov;
- (void)selectChangeNotification:(NSOutlineView*)no;
- (void)selectObject:(id)sender;
- (void)replaceQPDFNode:(QPDFNode*)node withString:(NSString*)editor;
- (void)forwardInvocation:(NSInvocation*)inv;
- (void)changeFont:(id)sender;

@end
