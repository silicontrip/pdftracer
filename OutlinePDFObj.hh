#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>

#import <qpdf/QPDF.hh>
#import <qpdf/QPDFWriter.hh>

#import "QPDFNode.hh"

@interface OutlinePDFObj : NSObject <NSOutlineViewDataSource>
{
	std::vector<QPDFObjectHandle> objTable;
	QPDF qpDocument;
	
}

- (instancetype)initWithPDF:(QPDF)pdf;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
// - (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
+ (NSOutlineView*)view;


@end
