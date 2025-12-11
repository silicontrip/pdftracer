#import <AppKit/AppKit.h>
#import "QPDFWindowController.h"

@interface QPDFOutlineView : NSOutlineView
{

}

@property (nonatomic,retain) NSSegmentedControl* relatedSegment;

- (BOOL)acceptsFirstResponder;
// - (BOOL)becomeFirstResponder;
- (void)dataReload:(NSNotification*)n;

@end
