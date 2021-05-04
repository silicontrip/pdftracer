//
//  QPDFMenu.m
//  pdftracer
//
//  Created by Mark Heath on 9/2/21.
//  Copyright © 2021 silicontrip. All rights reserved.
//

#import "QPDFMenu.h"

@implementation QPDFMenu

@synthesize windowsMenu;

- (instancetype)initMenu
{
	
	self = [super init];
	
	if (self)
	{
		NSNull* tnil  = [NSNull null];

		NSArray* menutitle = @[@"app",@"File",@"Edit",@"Insert",@"View",@"Tools",@"Window",@"Help"];
		
		NSArray* menuItems = @[
							   @[@"About",@"Quit PDFTracer"],
							   @[@"New",@"Open...",@"-",@"Close",@"Save",@"Save As...",@"Revert to Saved",@"Export Text"],
							   @[@"Undo",@"Redo",@"-",@"Cut",@"Copy",@"Paste",@"Delete",@"Select All",@"-",@"Format",@"Find"],
							   @[@"Font...",@"Image..."],
							   @[@"Actual Size",@"Zoom to Fit",@"Zoom In",@"Zoom Out",@"Zoom to Selection"],
							   @[@"Insert",@"Text Box",@"Pointer",@"Font Finder"],
							   @[@"Minimize",@"Zoom",@"-",@"Bring All to Front",@"-"],
							   @[@"PDF Documentation"]
							   ];
		
		
		NSString *bkspace = [NSString stringWithFormat:@"%c",8];
		
		NSArray* keyEquivalents = @[
									@[tnil,@"q"],
									@[@"n", @"o",tnil,@"w",@"s",@"S",@"r",tnil],
									@[@"z",@"Z",tnil,@"x",@"c",@"v",bkspace,@"a",tnil,@"T",@"f"],
									@[tnil,tnil],
									@[@"0",@"9",@"+",@"-",@"*"],
									@[tnil,tnil,tnil,tnil],
									@[@"m",tnil,tnil,tnil,tnil],
									@[@")"]
									];
		
		NSArray* targets = @[
							 @[@"orderFrontStandardAboutPanel:", @"terminate:"],
							 @[@"newDocument:", @"openDocument:",tnil, @"performClose:" , @"saveDocument:", @"saveDocumentAs:",@"revertDocumentToSaved:",@"exportText:"],
							 @[@"undo:", @"redo:", tnil, @"cut:",@"copy:",@"paste:",@"delete:",@"selectAll:",tnil,@"orderFrontFontPanel:",@"performFindPanelAction:"],
							 @[tnil,tnil],
							 // @[@"orderFrontFontPanel:"],
							 @[@"zoomAct:",@"zoomFit:",@"zoomIn:",@"zoomOut:",@"zoomSel:"],
							 @[tnil,tnil,tnil,tnil],
							 @[@"performMiniturize:",@"performZoom:",tnil,tnil,tnil],
							 @[tnil]
							 ];
		
		NSUInteger mCount = [menutitle count];
	//	NSLog(@"%lu = %lu = %lu = %lu",mCount,[menuItems count],[keyEquivalents count],[targets count]);
		NSAssert(mCount == [menuItems count], @"menuItems mismatch");
		NSAssert(mCount == [keyEquivalents count], @"keyEquivalents mismatch");
		NSAssert(mCount == [targets count], @"target mismatch");
		
		//NSMenu *menubar = [NSMenu new];
		for (NSUInteger i=0; i<[menutitle count]; ++i)
		{
			
			NSString* title = [menutitle objectAtIndex:i];
			NSArray* items = [menuItems objectAtIndex:i];
			NSArray* keyquiv = [keyEquivalents objectAtIndex:i];
			NSArray* select = [targets objectAtIndex:i];
			
			// NSLog(@"%lu = %lu = %lu",[items count],[keyquiv count],[select count]);
			
			// NSLog(@"item: %lu",i);
			NSAssert([items count] == [keyquiv count],@"items != keyequiv");
			NSAssert([select count] == [keyquiv count],@"targets != keyequiv");

			// conditional menus.
			if ([title isEqualToString:@"FONT"])
			{
				NSFontManager *fontManager = [NSFontManager sharedFontManager];
				NSMenu *fontMenu = [fontManager fontMenu:YES];
				
				NSMenuItem *appMenuItem;
				appMenuItem = [NSMenuItem new];

				[appMenuItem setSubmenu:fontMenu];
				[self addItem:appMenuItem];
				
			} else {
				NSMenuItem* currentMenuItem = [[QPDFMenu newMenuBar:title with:items keys:keyquiv selectors:select] autorelease];
				if ([title isEqualToString:@"Window"])
					self.windowsMenu = [currentMenuItem submenu];
				
				[self addItem:currentMenuItem];
			}
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
		NSMenuItem *mi;
		NSString * menuTitle = [menutitle objectAtIndex:i];
		if ([menuTitle isEqualToString:@"-"])
		{
			mi = [NSMenuItem separatorItem];
		/*
		} else if ([menuTitle isEqualToString:@"FONT"]) {
			mi = [[NSMenuItem new] autorelease];
			[mi setTitle:@"Font"];
			NSFontManager *fontManager = [NSFontManager sharedFontManager];
			NSMenu *fontMenu = [fontManager fontMenu:YES];
			[mi setSubmenu:fontMenu];
		*/
		} else {
			mi = [[NSMenuItem new] autorelease];
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
