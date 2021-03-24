#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#import "QPDFNode.h"
#import "QPDFOutlineView.h"
#import "QPDFWindowController.h"

@class QPDFOutlineView;

#import "QPDFSegmentedCell.h"
#import "OutlineQPDF.h"
#import "OutlineQPDFObj.h"
#import "OutlineQPDFPage.h"

/*
@class OutlineQPDF;
@class OutlineQPDFObj;
@class OutlineQPDFPage;
*/

@interface QPDFWindow : NSWindow
{

//	NSTextView* textView;
//	PDFView *documentView;

	QPDFOutlineView* outlines[3];
	NSSegmentedControl* segments[3];
	
//	NSFont * textFont;
	
	//NSSplitView* soView;
	NSSplitView* sView[2];
}

@property (nonatomic,strong) NSTextView* textView;
@property (nonatomic,strong) PDFView* documentView;
@property (nonatomic,strong) NSFont* textFont;

-(instancetype)initWithContentRect:(NSRect)rect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backing;

-(void)setDocument:(PDFDocument*)pdf;

-(NSTextView*)textView;
-(NSString*)text;
-(void)setText:(NSString*)text;
-(void)setFont:(NSFont*)font;

-(void)removeEnabled:(BOOL)ena forIndex:(int)index;
-(void)addEnabled:(BOOL)ena forIndex:(int)index;

-(void)editorEnabled:(BOOL)ena;

//-(void)updateAllOutlines:(QPDFNode*)node;
-(void)updateOutline:(NSOutlineView*)ov forNode:(QPDFNode*)nn;
//-(void)invalidateAll;

-(QPDFOutlineView*)outlineAtIndex:(NSInteger)index;
-(NSSegmentedControl*)segmentAtIndex:(NSInteger)index;
-(NSSplitView*)splitAtIndex:(int)index;
+(NSSegmentedControl*)addRemoveSegmentWithMenu:(BOOL)menu;

@end
