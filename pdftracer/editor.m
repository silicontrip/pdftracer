#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "Arguments.h"
#import "OutlineQPDF.hh"
// #import "QPDFEditor.hh"
#import "QPDFDocumentController.h"
#import "QPDFMenu.h"

// load background PDF
// report mouse pos

// insert constants Letter size, A4 size

// font picker

//make this class the app delegate and split the pdf editing/ textviewdelegate into another class
@interface pdfApp : NSObject <NSApplicationDelegate>
{
	// NSMutableArray<QPDFEditor*>* openDocuments;
	QPDFDocumentController* docControl;
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationWillTerminate:(NSNotification *)aNotification;
// - (BOOL)validateMenuItem:(NSMenuItem *)menuItem;

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
	NSLog(@"applicationDidFinishLaunching");
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
	NSLog(@"applicationWillTerminate");
}



int main (int argc, char * const argv[])
{

	NSAutoreleasePool *splash=[NSAutoreleasePool new];
	
	[NSApplication sharedApplication];
	QPDFDocumentController* docControl = [QPDFDocumentController sharedDocumentController];
	
	pdfApp *mm = [[pdfApp alloc] initWithController:docControl];
	
	[NSApp setDelegate:mm];
	
	NSMenu* appMenu = [[QPDFMenu alloc] init];
	[appMenu setDelegate:docControl];
	// NSLog(@"menu: %@",appMenu);
	[NSApp setMainMenu:appMenu];
	
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
//	[pa release];

	[splash release];
	
	/*
	NSTextStorage * nts = [[NSTextStorage alloc]

	[nts setImportsGraphics:NO];
	 */


}

@end
