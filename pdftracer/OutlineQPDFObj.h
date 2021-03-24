#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>

#import "QPDFNode.h"
#import "QPDFOutlineView.h"

#import "ObjcQPDF.h"
#import "ObjcQPDFObjectHandle.h"

@interface OutlineQPDFObj : NSObject <NSOutlineViewDataSource>
{
//	NSArray<ObjcQPDFObjectHandle*>* objTable;
	ObjcQPDF* qpDocument;
	
}

- (instancetype)initWithPDF:(ObjcQPDF*)pdf;
// - (void)invalidate;

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
// - (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
+ (QPDFOutlineView*)newView;

@end
