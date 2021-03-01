#import <Cocoa/Cocoa.h>
#import "QPDFDocument.h"
#import "QPDFNode.h"
#import "QPDFOutlineView.h"

@class QPDFDocument;
@class OutlineQPDF;  // arg inconsistent names!
@class OutlineQPDFObj;
@class OutlineQPDFPage;
@class QPDFWindow;
@class QPDFOutlineView;

@interface QPDFWindowController : NSWindowController <NSTextViewDelegate, NSUserInterfaceValidations>
{
	OutlineQPDF* pdfDS;
	OutlineQPDFPage* pageDS;
	OutlineQPDFObj* objDS;
	
	NSInteger selectedRow;
	QPDFOutlineView* selectedView;
}

- (instancetype)initWithWindow:(QPDFWindow*)nsw;
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem;

- (void)invalidateAll;

- (void)updatePDF;
- (void)updateOutlines:(QPDFNode*)node;
- (void)updateOutline:(QPDFOutlineView*)outline forNode:(QPDFNode*)node;

- (void)textDidChange:(NSNotification *)notification;
- (void)textDidEndEditing:(NSNotification*)notification;
- (void)changeNotification0:(NSNotification*)nn;
- (void)changeNotification1:(NSNotification*)nn;
- (void)changeNotification2:(NSNotification*)nn;
- (void)changeNotification:(NSNotification*)nn index:(int)outl;
- (void)addRemove:(id)sender;

- (void)changeRow:(NSInteger)row forSource:(NSOutlineView*)ov;
- (void)selectChangeNotification:(NSOutlineView*)no;
- (void)selectObject:(id)sender;
- (void)changeFont:(id)sender;
- (void)initDataSource;

@end
