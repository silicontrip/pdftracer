#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

// #import "QPDFNode.h"
#import "QPDFOutlineView.h"
#import "QPDFWindowController.h"
#import "QPDFView.h"
#import "QPDFTextView.h"

@class QPDFOutlineView;

#import "QPDFSegmentedCell.h"
#import "OutlineQPDF.h"
#import "OutlineQPDFObj.h"
#import "OutlineQPDFPage.h"

#import "NoodleLineNumber/NoodleLineNumberView.h"

/*
@class OutlineQPDF;
@class OutlineQPDFObj;
@class OutlineQPDFPage;
*/

@interface QPDFWindow : NSWindow
{

	NSTextStorage * textStorage;
	QPDFOutlineView* outlines[3];
	NSSegmentedControl* segments[3];
	
//	NSFont * textFont;   // property not ivar
	
	//NSSplitView* soView;
	NSSplitView* sView[2];
}

@property (nonatomic,strong) NSTextContainer* textContainer;
@property (nonatomic,strong) NSLayoutManager* layout;
@property (nonatomic,strong) QPDFTextView* textView;
@property (nonatomic,strong) NSScrollView* scrollTextView;
@property (nonatomic,strong) QPDFView* documentView;
@property (nonatomic,strong) NSFont* textFont;

- (void)addEnabled:(BOOL)ena forIndex:(int)index;
+ (NSSegmentedControl*)addRemoveSegmentWithMenu:(BOOL)menu;
- (void)dealloc;
- (void)editorEnabled:(BOOL)ena;
+ (NSScrollView*)hvScrollView:(NSView*)doc;
- (instancetype)initWithContentRect:(NSRect)rect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backing notificationCenter:(NSNotificationCenter*)centre;
- (void)mouseDown:(NSEvent *)event;
- (QPDFOutlineView*)outlineAtIndex:(NSInteger)index;
// - (void)outlineNodeChanged:(NSNotification *)notification;
- (void)removeEnabled:(BOOL)ena forIndex:(int)index;
// - (BOOL)respondsToSelector:(SEL)aSelector;
- (NSSegmentedControl*)segmentAtIndex:(NSInteger)index;
- (void)setDocument:(PDFDocument*)pdf;
// - (void)setFont:(NSFont*)font;
// - (void)setText:(NSString*)text;
- (NSSplitView*)splitAtIndex:(int)index;
+ (NSStackView*)stackScroll:(NSView*)scroll andSegment:(NSView*)seg;
// - (NSString*)text;
+ (QPDFTextView*)textEditorView;
// WithContainer:(NSTextContainer*)tCon
// +(NSTextView*)textEditorViewWithContainer:(NSTextContainer*)tCon;
- (QPDFTextView*)textView;
- (void)updateOutline:(NSOutlineView*)ov forHandle:(ObjcQPDFObjectHandle*)nn;
// -(void)updateOutline:(NSOutlineView*)ov forNode:(QPDFNode*)nn;
@end
