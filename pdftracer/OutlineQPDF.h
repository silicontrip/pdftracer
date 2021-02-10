
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>

#import "QPDFNode.h"

#import "QPDFOutlineView.h"


@interface OutlineQPDF : NSObject <NSOutlineViewDataSource>
{
	@private
	//CGPDFDocumentRef  myDocument;
	QPDF qpDocument;
	QPDFNode *catalog;
	
	//NSMutableDictionary<NSValue*,QPDFNode*>* pdfObjectCache;
	// NSValue* pdfNull;
}

- (instancetype)initWithPDF:(QPDFObjc*)pdf;
+ (NSOutlineView*)view;

// protocol overrides
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;

@end
