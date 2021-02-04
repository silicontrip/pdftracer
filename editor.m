#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "ArgumentsObj.h"
#import "OutlineQPDF.hh"
#import "QPDFEditor.hh"
#import "QPDFDocumentController.h"

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
- (NSMenu*)newMenu:(NSArray*)menutitle;
- (NSMenuItem*)newMenuBar:(NSString*)menutitle with:(NSArray*)menus;
- (NSMenu*)newAppMenu;
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


/*
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	NSLog(@"validate calling");
	return YES;
}
*/

// NSMenu* newMenu(NSArray * menutitle)
-(NSMenu*)newMenu:(NSArray*)menutitle
{
	NSMenu *menu = [NSMenu new];
	for (NSUInteger i=0; i<[menutitle count]; ++i)
	{
		NSMenuItem *mi = [[NSMenuItem new] autorelease];
		[mi setTitle:[NSString stringWithString:[menutitle objectAtIndex:i]]];
		[mi setTarget:docControl];
		// [mi setAction:@selector(menuHit:)];
		[mi setEnabled:YES];
		[menu addItem:mi];
	}
	[menu setAutoenablesItems:YES];
	return menu;
	
}

//NSMenuItem* newMenuBar(NSString *menutitle, NSArray* menus)
- (NSMenuItem*)newMenuBar:(NSString*)menutitle with:(NSArray*)menus
{
	NSMenu* bar;
	NSMenuItem *appMenuItem;
	
	appMenuItem = [NSMenuItem new];
	bar = [self newMenu:menus];
	[bar setAutoenablesItems:YES];
	[bar setTitle:menutitle];
	[appMenuItem setSubmenu:bar];

	return appMenuItem;
}

//NSMenu* newAppMenu()
- (NSMenu*)newAppMenu
{
	
	NSArray* menutitle = @[@"app",@"File",@"Edit",@"Format",@"View",@"Tools",@"Window",@"Help"];
	
	NSArray* menuItems = @[
						   @[@"About",@"Quit PDFTracer"],
						   @[@"New",@"Open...",@"Open Recent",@"Save",@"Save As..."],
						   @[@"Undo",@"Redo",@"Cut",@"Copy",@"Paste"],
						   @[@"Font"],
						   @[@"PDF Zoom"],
						   @[@"Insert",@"Text Box",@"Pointer",@"Font Finder"],
						   @[@"Minimize"],
						   @[@"PDF Documentation"]
						   ];
	
	NSMenu *menubar = [NSMenu new];
	for (NSUInteger i=0; i<[menutitle count]; ++i)
	{
		NSString* title = [menutitle objectAtIndex:i];
		NSArray* items = [menuItems objectAtIndex:i];
		
		[menubar addItem:[self newMenuBar:title with:items]];
	}

	return menubar;
}

int main (int argc, char * const argv[])
{

	NSAutoreleasePool *splash=[NSAutoreleasePool new];
	
	[NSApplication sharedApplication];
	QPDFDocumentController* docControl = [QPDFDocumentController sharedDocumentController];
	
	pdfApp *mm = [[pdfApp alloc] initWithController:docControl];
	
	[NSApp setDelegate:mm];
	
	NSMenu* appMenu = [mm newAppMenu];
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
		NSError *errorError;
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
