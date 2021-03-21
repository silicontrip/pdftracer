#import <Cocoa/Cocoa.h>
#import "QPDFDocument.h"
#import "QPDFNode.h"
#import "QPDFOutlineView.h"

@class QPDFDocument;
@class OutlineQPDF;
@class OutlineQPDFObj;
@class OutlineQPDFPage;
@class QPDFWindow;
@class QPDFOutlineView;

@interface QPDFWindowController : NSWindowController <NSTextViewDelegate, NSUserInterfaceValidations>
{
	OutlineQPDF* pdfDS;
	OutlineQPDFPage* pageDS;
	OutlineQPDFObj* objDS;
}
@property (assign) NSInteger selectedRow;
@property (assign) NSInteger selectedColumn;

@property (weak,nonatomic) QPDFOutlineView* selectedView;
@property (weak,nonatomic) QPDFNode* selectedNode;

- (instancetype)initWithWindow:(QPDFWindow*)nsw;
- (void)initDataSource;

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem;

// - (void)invalidateAll;

- (void)updatePDF;
// - (void)updateOutlines:(QPDFNode*)node;
- (void)updateOutline:(QPDFOutlineView*)outline forNode:(QPDFNode*)node;

- (void)textDidChange:(NSNotification *)notification;
- (void)textDidEndEditing:(NSNotification*)notification;

// - (void)changeText:(NSInteger)row column:(NSInteger)column forSource:(QPDFOutlineView*)qov with:(NSString*)es;
- (void)changeText:(QPDFOutlineView*)qov with:(NSString*)es;


- (void)selectRow:(NSInteger)sr forSource:qov;
- (NSString*)editText;
//- (BOOL)isEditable;
- (BOOL)editEnabled;


//- (void)setText:(NSString*)s;
- (void)setEditText:(NSString*)s;

//- (void)changeRow:(NSInteger)row forSource:(NSOutlineView*)ov;
- (void)selectChangeNotification:(NSOutlineView*)no;
- (void)selectObject:(id)sender;
- (void)changeFont:(id)sender;
- (void)addRemove:(id)sender;
- (void)addType:(id)sender;


@end
