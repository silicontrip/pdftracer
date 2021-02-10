
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>

#import <qpdf/QPDF.hh>
#import <qpdf/QPDFWriter.hh>

#import "QPDFNode.hh"

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

// - (instancetype)initWithURL:(NSURL*)url;
- (instancetype)initWithPDF:(QPDF)pdf;
+ (NSOutlineView*)view;
// protocol overrides
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;



- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;

@end
