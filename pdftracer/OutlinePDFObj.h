#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>

#import "QPDFNode.h"
#import "QPDFOutlineView.h"

#import "QPDFObjc.h"
#import "QPDFObjectHandleObjc.h"

@interface OutlinePDFObj : NSObject <NSOutlineViewDataSource>
{
	NSArray<QPDFObjectHandleObjc*>* objTable;
	QPDFObjc* qpDocument;
	
}

- (instancetype)initWithPDF:(QPDFObjc*)pdf;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
// - (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
+ (NSOutlineView*)newView;


@end
