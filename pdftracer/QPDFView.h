#import <AppKit/AppKit.h>
#import <Quartz/Quartz.h>

// #import "QPDFWindowController.h"

@interface QPDFView : PDFView
{

}

- (BOOL)acceptsFirstResponder;
// - (BOOL)becomeFirstResponder;
- (void)mouseDown:(NSEvent*)event;
// - (void)keyDown:(NSEvent*)event;

@end

