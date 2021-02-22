#import <Cocoa/Cocoa.h>
#import "QPDFDocument.h"
#import "QPDFNode.h"

@class QPDFDocument;
@class OutlineQPDF;  // arg inconsistent names!
@class OutlineQPDFObj;
@class OutlineQPDFPage;
@class QPDFWindow;

@interface QPDFWindowController : NSWindowController <NSTextViewDelegate, NSUserInterfaceValidations>
{	
	NSInteger selectedRow;
	NSOutlineView* selectedView;
}

- (instancetype)initWithWindow:(QPDFWindow*)nsw;
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem;

-(void)invalidateAll;

- (void)updatePDF;
- (void)updateOutlines:(QPDFNode*)node;
- (void)textDidChange:(NSNotification *)notification;
- (void)textDidEndEditing:(NSNotification*)notification;
- (void)changeNotification:(NSNotification*)nn;
- (void)changeRow:(NSInteger)row forSource:(NSOutlineView*)ov;
- (void)selectChangeNotification:(NSOutlineView*)no;
- (void)selectObject:(id)sender;
- (void)changeFont:(id)sender;

@end
