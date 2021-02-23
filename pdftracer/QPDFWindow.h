#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#import "QPDFNode.h"
#import "QPDFOutlineView.h"
#import "QPDFWindowController.h"

@class QPDFOutlineView;


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

	NSTextView* tView;
	PDFView *dView;

	QPDFOutlineView* outlines[3];
	NSSegmentedControl* segments[3];
	
	NSFont * tfont;
	
	//NSSplitView* soView;
	NSSplitView* sView[2];
}

-(instancetype)initWithContentRect:(NSRect)rect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backing;

-(void)setDocument:(PDFDocument*)pdf;

-(NSTextView*)textView;
-(NSString*)text;
-(void)setText:(NSString*)text;

-(void)removeEnabled:(BOOL)ena forIndex:(int)index;
-(void)addEnabled:(BOOL)ena forIndex:(int)index;

-(void)editorEnabled:(BOOL)ena;

-(void)updateAllOutlines:(QPDFNode*)node;
-(void)updateOutline:(NSOutlineView*)ov withNode:(QPDFNode*)nn;
-(void)invalidateAll;

-(QPDFOutlineView*)outlineAtIndex:(NSInteger)index;
-(NSSplitView*)splitAtIndex:(int)index;

@end
