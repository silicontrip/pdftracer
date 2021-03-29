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
	QPDFDocumentController* docControl;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationWillTerminate:(NSNotification *)aNotification;

@end

@implementation pdfApp

-(instancetype)initWithController:(QPDFDocumentController*)qDoc
{
	self = [super init];
	if (self)
	{
		docControl = qDoc;
		// openDocuments = [[NSMutableArray alloc] initWithCapacity:2];
	}
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	// NSLog(@"applicationDidFinishLaunching");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
	NSLog(@"applicationWillTerminate");
}

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

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(id)sender
{
	return NO;
}

int main (int argc, char * const argv[])
{

	NSAutoreleasePool *splash=[NSAutoreleasePool new];
	
	[NSApplication sharedApplication];
	QPDFDocumentController* docControl = [QPDFDocumentController sharedDocumentController];
	
	// QPDFDocumentController* docControl = [[QPDFDocumentController alloc] init];

	
	NSMenu* appMenu = [[QPDFMenu alloc] initWithMenu];
	[appMenu setDelegate:docControl];
	
	[NSApp setMainMenu:appMenu];
	
	
	pdfApp *mm = [[[pdfApp alloc] initWithController:docControl] autorelease];

	QPDFHelp* hh = [[QPDFHelp alloc] init];
	[NSApp registerUserInterfaceItemSearchHandler:hh];
	
	[NSApp setDelegate:mm];
	
	[NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

	Arguments* aa = [Arguments argumentsWithCount:argc values:argv];
	
	if ([aa countPositionalArguments] == 1)
	{
		// read file
		// QPDFEditor *pa = [[QPDFEditor alloc] initWithRect:NSMakeRect(0,0,1440,600)];  // size settings

		NSString *fn = [aa positionalArgumentAt:0];  // filename from arg

		NSURL *fu = [NSURL fileURLWithPath:fn];
	//	NSError *errorError;
		// [docControl makeDocumentWithContentsOfURL:fu ofType:@"PDF" error:&errorError];
		[docControl openDocumentWithContentsOfURL:fu display:YES completionHandler:^(NSDocument *document, BOOL alreadyOpen, NSError *error){
			NSLog(@"%@",document);
		}];
	//	[docControl openDocument:nil];
	// [docControl openDocument:fu];

	}
	
	[NSApp run];

	[splash release];

}

@end
