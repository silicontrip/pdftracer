#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>

#import "QPDFObjc.h"
#import "QPDFNode.h"
#import "QPDFOutlineView.h"

@interface OutlinePDFPage : NSObject <NSOutlineViewDataSource>
{
	NSArray<QPDFObjectHandleObjc*>* pageArray;
	QPDFObjc* qpDocument;
}

+ (NSOutlineView*)newView;
- (instancetype)initWithPDF:(QPDFObjc*)pdf;


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
// - (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;

@end
