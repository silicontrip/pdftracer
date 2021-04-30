#import <AppKit/AppKit.h>
#import <Quartz/Quartz.h>


@interface QPDFPageView : NSView
{
}

@property (nonatomic,strong) PDFDocument* pdfDocument;

-(void)drawRect:(NSRect)dirtyRect;
-(void)mouseDown:(NSEvent*)ev;

@end
