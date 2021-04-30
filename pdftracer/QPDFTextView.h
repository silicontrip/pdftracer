#import <AppKit/AppKit.h>

@interface QPDFTextView : NSTextView
{

}

- (BOOL)acceptsFirstResponder;
- (BOOL)becomeFirstResponder;
// - (void)mouseDown:(NSEvent*)event;
- (void)keyDown:(NSEvent*)event;

@end

