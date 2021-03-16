#import <AppKit/AppKit.h>
#import "QPDFWindowController.h"

@interface QPDFOutlineView : NSOutlineView
{

}

@property (weak,nonatomic) NSSegmentedControl* relatedSegment;

- (BOOL)acceptsFirstResponder;
- (BOOL)becomeFirstResponder;

@end
