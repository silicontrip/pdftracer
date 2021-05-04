#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "Arguments.h"
#import "OutlineQPDF.h"
// #import "QPDFEditor.hh"
#import "QPDFDocumentController.h"
#import "QPDFMenu.h"
#import "QPDFHelp.h"

// load background PDF
// report mouse pos

// insert constants Letter size, A4 size

// font picker

//make this class the app delegate and split the pdf editing/ textviewdelegate into another class
@interface pdfApp : NSObject <NSApplicationDelegate>
{
	// QPDFDocumentController* docControl;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationWillTerminate:(NSNotification *)aNotification;

@end

@implementation pdfApp

// -(instancetype)initWithController:(QPDFDocumentController*)qDoc
// Document controller is a singleton, it shouldn't need passing or storing in an instance variable
/*
-(instancetype)init
{
	self = [super init];
	if (self)
	{
		// docControl = qDoc;
		// openDocuments = [[NSMutableArray alloc] initWithCapacity:2];
	}
	return self;
}
*/

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	// NSLog(@"applicationDidFinishLaunching");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
	NSLog(@"applicationWillTerminate");
}
/*
- (BOOL)respondsToSelector:(SEL)aSelector
{
	NSString* selstr =NSStringFromSelector(aSelector);
	if (![selstr isEqualToString:@"validModesForFontPanel:"])
	{
		NSLog(@"AppDelegate EVENT -> %@",NSStringFromSelector(aSelector));
		if( [pdfApp instancesRespondToSelector:aSelector] ) {
			// invoke the inherited method
			return YES;
		}
	}
	return [super respondsToSelector:aSelector];
}
*/
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(id)sender
{
	return NO;
}

int main (int argc, char * const argv[])
{

	NSAutoreleasePool *splash=[NSAutoreleasePool new];
	
	NSApplication* qpdfapp = [NSApplication sharedApplication];
	// QPDFDocumentController* docControl = [QPDFDocumentController sharedDocumentController];
	
	// QPDFDocumentController* docControl = [[QPDFDocumentController alloc] init];

	
	QPDFMenu* appMenu = [[QPDFMenu alloc] initMenu];
	[appMenu setDelegate:[QPDFDocumentController sharedDocumentController]];
	
	[qpdfapp setMainMenu:appMenu];
	[qpdfapp setWindowsMenu:appMenu.windowsMenu];
	
	pdfApp *mm = [[[pdfApp alloc] init] autorelease];

	QPDFHelp* hh = [[QPDFHelp alloc] init];
	[qpdfapp registerUserInterfaceItemSearchHandler:hh];
	
	[qpdfapp setDelegate:mm];
	
	[qpdfapp setActivationPolicy:NSApplicationActivationPolicyRegular];

	NSLog(@"windows menu: %@",[qpdfapp windowsMenu]);
	
	Arguments* aa = [Arguments argumentsWithCount:argc values:argv];
	
	if ([aa countPositionalArguments] == 1)
	{
		// read file
		// QPDFEditor *pa = [[QPDFEditor alloc] initWithRect:NSMakeRect(0,0,1440,600)];  // size settings

		NSString *fn = [aa positionalArgumentAt:0];  // filename from arg

		NSURL *fu = [NSURL fileURLWithPath:fn];
	//	NSError *errorError;
		// [docControl makeDocumentWithContentsOfURL:fu ofType:@"PDF" error:&errorError];
		[[QPDFDocumentController sharedDocumentController] openDocumentWithContentsOfURL:fu display:YES completionHandler:^(NSDocument *document, BOOL alreadyOpen, NSError *error){
			NSLog(@"main loop: %@",document);
		}];

	}
	
	[qpdfapp run];

	[splash release];  // gurgle gurgle ;-)

}

@end
