#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>

// #import "QPDFNode.h"
#import "QPDFOutlineView.h"

#import "ObjcQPDF.h"
#import "ObjcQPDFObjectHandle.h"

@interface OutlineQPDFObj : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>
{
	ObjcQPDF* qpDocument;
	NSArray* objTable;
}

- (instancetype)initWithPDF:(ObjcQPDF*)pdf;
+ (QPDFOutlineView*)newView;
- (void)refresh;

@end
