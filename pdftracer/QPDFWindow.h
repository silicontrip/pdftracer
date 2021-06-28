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

-(instancetype)initWithContentRect:(NSRect)rect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backing notificationCenter:(NSNotificationCenter*)centre;

-(void)setDocument:(PDFDocument*)pdf;

-(QPDFTextView*)textView;
//-(NSString*)text;
//-(void)setText:(NSString*)text;
//-(void)setFont:(NSFont*)font;

-(void)removeEnabled:(BOOL)ena forIndex:(int)index;
-(void)addEnabled:(BOOL)ena forIndex:(int)index;

-(void)editorEnabled:(BOOL)ena;

// -(void)updateOutline:(NSOutlineView*)ov forNode:(QPDFNode*)nn;
-(void)updateOutline:(NSOutlineView*)ov forHandle:(ObjcQPDFObjectHandle*)nn;


-(QPDFOutlineView*)outlineAtIndex:(NSInteger)index;
-(NSSegmentedControl*)segmentAtIndex:(NSInteger)index;
-(NSSplitView*)splitAtIndex:(int)index;
+(NSSegmentedControl*)addRemoveSegmentWithMenu:(BOOL)menu;
// +(NSTextView*)textEditorViewWithContainer:(NSTextContainer*)tCon;

@end
