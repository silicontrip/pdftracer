
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>

#import "QPDFNode.h"
#import "ObjcQPDF.h"
#import "QPDFOutlineView.h"

@interface OutlineQPDF : NSObject <NSOutlineViewDataSource>
{
	@private
	//CGPDFDocumentRef  myDocument;
	ObjcQPDF* qpDocument;
	QPDFNode *catalog;
	
	//NSMutableDictionary<NSValue*,QPDFNode*>* pdfObjectCache;
	// NSValue* pdfNull;
}

- (instancetype)initWithPDF:(ObjcQPDF*)pdf;
- (void)invalidate;

+ (QPDFOutlineView*)newView;

// protocol overrides
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (NSUInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
// - (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;

@end
