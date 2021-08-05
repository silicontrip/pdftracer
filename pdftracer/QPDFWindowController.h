#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import "QPDFDocument.h"
#import "QPDFMenu.h"
//#import "QPDFNode.h"
#import "QPDFOutlineView.h"
#import "QPDFSyntaxHighlighter.h"

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
	
	NSLayoutManager* layout;
	NSTextStorage *textStore;
	
	QPDFSyntaxHighlighter *syntaxer;
	NSNotificationCenter* documentCenter;  // really want to call this Centre
	NSLock* updateDocumentLock;
	unsigned long lastUpdate;
}
@property (assign) NSInteger selectedRow;
@property (assign) NSInteger selectedColumn;
@property (nonatomic) QPDFOutlineView* selectedView;
//@property (weak,nonatomic) ObjcQPDFObjectHandle* selectedNode;
@property (nonatomic) ObjcQPDFObjectHandle* selectedHandle;
@property (assign) NSInteger selectedPage;  // unselected sentinel is -1

- (instancetype)initWithWindow:(QPDFWindow*)nsw notificationCenter:(NSNotificationCenter*)centre;
- (void)initDataSource;

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem;

// - (void)invalidateAll;

// - (void)updatePDF;
// - (void)updateOutlines:(QPDFNode*)node;
// - (void)updateOutline:(QPDFOutlineView*)outline forNode:(QPDFNode*)node;
- (void)updateOutline:(QPDFOutlineView*)outline forHandle:(ObjcQPDFObjectHandle*)node;

- (void)textDidChange:(NSNotification *)notification;
- (void)textDidEndEditing:(NSNotification*)notification;

// - (void)changeText:(NSInteger)row column:(NSInteger)column forSource:(QPDFOutlineView*)qov with:(NSString*)es;
- (void)changeText:(QPDFOutlineView*)qov with:(NSString*)es;


- (void)selectRow:(NSInteger)sr forSource:qov;
//- (NSString*)textForSelectedObject;
//- (BOOL)isEditable;
// - (BOOL)canEditSelectedObject;
- (BOOL)canAddToSelectedObject;

- (void)setAddEnabled:(BOOL)ena;
- (void)setRemoveEnabled:(BOOL)ena;
// - (void)setEditText:(NSString*)s;


- (void)documentChange:(NSNotification*)n;
- (void)rowChangedContent:(NSNotification*)n;
- (void)textSetContent:(NSNotification*)n;

//- (void)changeRow:(NSInteger)row forSource:(NSOutlineView*)ov;
//- (void)textStorageDidProcessEditing:(NSNotification *)notification;
- (void)selectChangeNotification:(NSOutlineView*)no;
- (void)selectObject:(id)sender;
- (void)changeFont:(id)sender;
- (void)addRemove:(id)sender;
- (void)addType:(id)sender;

- (void)zoomAct:(id)sender;
- (void)zoomFit:(id)sender;
- (void)zoomIn:(id)sender;
- (void)zoomOut:(id)sender;
- (void)zoomSel:(id)sender;

@end
