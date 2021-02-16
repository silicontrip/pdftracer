//
//  QPDFMenu.m
//  pdftracer
//
//  Created by Mark Heath on 9/2/21.
//  Copyright © 2021 silicontrip. All rights reserved.
//

#import "QPDFMenu.h"

@implementation QPDFMenu

- (instancetype)initWithMenu
{
	
	self = [super init];
	if (self)
	{
		NSArray* menutitle = @[@"app",@"File",@"Edit",@"Format",@"View",@"Tools",@"Window",@"Help"];
		
		NSArray* menuItems = @[
							   @[@"About",@"Quit PDFTracer"],
							   @[@"New",@"Open...",@"-",@"Close",@"Save",@"Save As...",@"Revert to Saved",@"Export Text"],
							   @[@"Undo",@"Redo",@"-",@"Cut",@"Copy",@"Paste"],
							   @[@"Font"],
							   @[@"Actual Size",@"Zoom to Fit",@"Zoom In",@"Zoom Out",@"Zoom to Selection"],
							   @[@"Insert",@"Text Box",@"Pointer",@"Font Finder"],
							   @[@"Minimize"],
							   @[@"PDF Documentation"]
							   ];
		
		NSNull* tnil  = [NSNull null];
		
		NSArray* keyEquivalents = @[
									@[tnil,@"q"],
									@[@"n", @"o",tnil,@"w",@"s",@"S",@"r",tnil],
									@[@"z",@"Z",tnil,@"x",@"c",@"v"],
									@[tnil],
									@[@"0",@"9",@"+",@"-",@"*"],
									@[tnil,tnil,tnil,tnil],
									@[@"m"],
									@[@")"]
									];
		
		NSArray* targets = @[
							 @[@"orderFrontStandardAboutPanel:", @"terminate:"],
							 @[@"newDocument:", @"openDocument:",tnil, @"performClose:" , @"saveDocument:", @"saveDocumentAs:",@"revertDocumentToSaved:",@"exportText:"],
							 @[@"undo:", @"redo:", tnil, @"cut:",@"copy:",@"paste:"],
							 @[@"orderFrontFontPanel:"],
							 @[tnil,tnil,tnil,tnil,tnil],
							 @[tnil,tnil,tnil,tnil],
							 @[@"performMiniturize:"],
							 @[tnil]
							 ];
		
		
		
		
		//NSMenu *menubar = [NSMenu new];
		for (NSUInteger i=0; i<[menutitle count]; ++i)
		{
			NSString* title = [menutitle objectAtIndex:i];
			NSArray* items = [menuItems objectAtIndex:i];
			NSArray* keyquiv = [keyEquivalents objectAtIndex:i];
			NSArray* select = [targets objectAtIndex:i];
			
			[self addItem:[[QPDFMenu newMenuBar:title with:items keys:keyquiv selectors:select] autorelease]];
		}
	}
	return self;
}

// NSMenu* newMenu(NSArray * menutitle)
+ (QPDFMenu*)newMenu:(NSArray*)menutitle keys:(NSArray*)keyequiv selectors:(NSArray*)select
{
	// making this QPDFMenu causes infinite loop
	QPDFMenu *myMenu = [QPDFMenu new];
	
	for (NSUInteger i=0; i<[menutitle count]; ++i)
	{
		NSMenuItem *mi = [[NSMenuItem new] autorelease];
		NSString * menuTitle = [menutitle objectAtIndex:i];
		if ([menuTitle isEqualToString:@"-"])
		{
			mi = [NSMenuItem separatorItem];
		} else {
			[mi setTitle:[NSString stringWithString:menuTitle]];
			[mi setTarget:nil];
			NSString* thisKey = [keyequiv objectAtIndex:i];
			if (![thisKey isKindOfClass:[NSNull class]])
				[mi setKeyEquivalent:thisKey];
			NSString* selstr = [select objectAtIndex:i];
			if (![selstr isKindOfClass:[NSNull class]])
				[mi setAction:NSSelectorFromString(selstr)];
		}
		[mi setEnabled:YES];
		[myMenu addItem:mi];
	}
	[myMenu setAutoenablesItems:YES];
	return myMenu;
	
}

//NSMenuItem* newMenuBar(NSString *menutitle, NSArray* menus)
+ (NSMenuItem*)newMenuBar:(NSString*)menutitle with:(NSArray*)menus keys:(NSArray*)keys selectors:(NSArray*)select
{
	NSMenu* bar;
	NSMenuItem *appMenuItem;
	
	appMenuItem = [NSMenuItem new];
	bar = [[QPDFMenu newMenu:menus keys:keys selectors:select] autorelease];
	[bar setAutoenablesItems:YES];
	[bar setTitle:menutitle];
	[appMenuItem setSubmenu:bar];
	
	return appMenuItem;
}

@end
