//
//  QPDFMenu.m
//  pdftracer
//
//  Created by Mark Heath on 9/2/21.
//  Copyright © 2021 silicontrip. All rights reserved.
//

#import "QPDFMenu.h"

// might have to be its own object
struct QPDFMenuItem {
	NSString* menuTitle;
	NSString* keyEquiv;
	NSString* selector;
	NSValue* subMenu;
};

/*
** A1 .59460355750136053335 .84089641525371454303
** A2 .42044820762685727151 .59460355750136053335
** A3 .29730177875068026667 .42044820762685727151
** A4 .21022410381342863575 .29730177875068026667
** A5 .14865088937534013333 .21022410381342863575
**
** B0 1 1.41
** B1 .70710678118654752440 1
** B2 .5 .707
** B3 .35355339059327376220 .5
** B4 .250 .353
** B5 .17677669529663688110 .25
** B6 .125 .176
**
** C0 .91700404320467123174 1.29683955465100966592
** C1 .64841977732550483296 .91700404320467123174
** C2 .45850202160233561587 .64841977732550483296
** C3 .32420988866275241648 .45850202160233561587 919.02,1299.69
** C4 .22925101080116780793 .32420988866275241648 649.85,919.02
** C5 .16210494433137620824 .22925101080116780793
**
** DL .22 .11 623.62,311.81
** DLX .235 .12 666.14,340.16

** Letter 8.5 x 11
** legal 8.5 x 14
** tabloid 11 x 17
** junior legal 5 x 8
**
** No10 9.5 x 4.1
** A2 lady grey 5.7 x 4.4
** A9 diplomat 8.7 x 5.7
 
 */

@implementation QPDFMenu

@synthesize windowsMenu;

+(NSMenuItem*)itemWithSubmenu:(nullable NSMenu*)menu
{
	return 	 [QPDFMenu itemWithTitle:@"" keyEquiv:nil selector:nil submenu:menu modifier:0 tag:0];
}
+ (NSMenuItem*)itemWithTitle:(NSString*)title submenu:(nullable NSMenu*)menu
{
	return [QPDFMenu itemWithTitle:title keyEquiv:nil selector:nil submenu:menu modifier:0 tag:0];
}
+ (NSMenuItem*)itemWithTitle:(NSString*)title selector:(NSString*)selstr
{
	return [QPDFMenu itemWithTitle:title keyEquiv:nil selector:selstr submenu:nil modifier:0 tag:0];
}

+ (NSMenuItem*)itemWithTitle:(NSString*)title selector:(NSString*)selstr tag:(NSInteger)tag
{
	return [QPDFMenu itemWithTitle:title keyEquiv:nil selector:selstr submenu:nil modifier:0 tag:tag];
}


+ (NSMenuItem*)itemWithTitle:(NSString*)title keyEquiv:(NSString*)thisKey  modifier:(NSEventModifierFlags)keyMod selector:(NSString*)selstr
{
	return [QPDFMenu itemWithTitle:title keyEquiv:thisKey selector:selstr submenu:nil modifier:keyMod tag:0];
}

+ (NSMenuItem*)itemWithTitle:(NSString*)title keyEquiv:(NSString*)thisKey  modifier:(NSEventModifierFlags)keyMod selector:(NSString*)selstr tag:(NSInteger)tag
{
	return [QPDFMenu itemWithTitle:title keyEquiv:thisKey selector:selstr submenu:nil modifier:keyMod tag:tag];
}

+ (NSMenuItem*)itemWithTitle:(NSString*)title keyEquiv:(NSString*)thisKey selector:(NSString*)selstr submenu:(nullable NSMenu*)menu modifier:(NSEventModifierFlags)keyMod tag:(NSInteger)tag
{
	NSMenuItem* mi = [[[NSMenuItem alloc] init ] autorelease];
	mi.title = title;
	mi.submenu = menu;
	mi.enabled = YES;
	mi.keyEquivalentModifierMask = keyMod;
	mi.tag=tag;
	
	if (thisKey)
		mi.keyEquivalent=thisKey;
	if (selstr)
		mi.action=NSSelectorFromString(selstr);
	return mi;
}

- (instancetype)init
{
	self = [super self];
	
	NSEventModifierFlags cmd = NSEventModifierFlagCommand;
	NSEventModifierFlags opt = NSEventModifierFlagOption;
	NSEventModifierFlags ctrl = NSEventModifierFlagControl;
	NSString *bkspace = [NSString stringWithFormat:@"%c",8];

	if (self)
	{
		
		
		NSMenu* appMenu = [[NSMenu new] autorelease];
		[appMenu setAutoenablesItems:YES];
		[appMenu addItem:[QPDFMenu itemWithTitle:@"About pdfTracer" selector:@"orderFrontStandardAboutPanel:"]];
		[appMenu addItem:[NSMenuItem separatorItem]];
		[appMenu addItem:[QPDFMenu itemWithTitle:@"Preferences..." keyEquiv:@"," modifier:cmd selector:nil]];
		[appMenu addItem:[NSMenuItem separatorItem]];
		[appMenu addItem:[QPDFMenu itemWithTitle:@"Hide pdfTracer" keyEquiv:@"h" modifier:cmd selector:@"hide:"]];
		[appMenu addItem:[QPDFMenu itemWithTitle:@"Hide Others" keyEquiv:@"h" modifier:cmd|opt selector:@"hideOtherApplications:" ]];
		[appMenu addItem:[QPDFMenu itemWithTitle:@"Show All" selector:@"unhideAllApplications:"]];
		[appMenu addItem:[NSMenuItem separatorItem]];
		[appMenu addItem:[QPDFMenu itemWithTitle:@"Quit" keyEquiv:@"q" modifier:cmd selector:@"terminate:" ]];
		[self addItem:[QPDFMenu itemWithSubmenu:appMenu]];
		
		
		NSMenu* fileMenu = [[NSMenu new] autorelease];
		[fileMenu setAutoenablesItems:YES];
		[fileMenu setTitle:@"File"];
		[fileMenu addItem:[QPDFMenu itemWithTitle:@"New" keyEquiv:@"n" modifier:cmd selector:@"newDocument:"]];
		[fileMenu addItem:[QPDFMenu itemWithTitle:@"Open" keyEquiv:@"o" modifier:cmd selector:@"openDocument:"]];
		[fileMenu addItem:[NSMenuItem separatorItem]];
		[fileMenu addItem:[QPDFMenu itemWithTitle:@"Close" keyEquiv:@"w" modifier:cmd selector:@"performClose"]];
		[fileMenu addItem:[QPDFMenu itemWithTitle:@"Save..." keyEquiv:@"s" modifier:cmd selector:@"saveDocument:"]];
		[fileMenu addItem:[QPDFMenu itemWithTitle:@"Save As..." keyEquiv:@"S" modifier:cmd selector:@"saveDocumentAs:"]];
		[fileMenu addItem:[QPDFMenu itemWithTitle:@"Revert to Saved" keyEquiv:@"r" modifier:cmd selector:@"revertDocumentToSaved:"]];
		[fileMenu addItem:[NSMenuItem separatorItem]];
		[fileMenu addItem:[QPDFMenu itemWithTitle:@"Page Setup..." keyEquiv:@"P" modifier:cmd selector:@"runPageLayout:"]];
		[fileMenu addItem:[QPDFMenu itemWithTitle:@"Print..." keyEquiv:@"p" modifier:cmd selector:@"printDocument:"]];
		[self addItem:[QPDFMenu itemWithSubmenu:fileMenu]];

		
		NSMenu* findMenu = [[NSMenu new] autorelease];
		[findMenu setAutoenablesItems:YES];
		[findMenu addItem:[QPDFMenu itemWithTitle:@"Find..." keyEquiv:@"f" modifier:cmd selector:@"performFindPanelAction:"]];
		[findMenu addItem:[QPDFMenu itemWithTitle:@"Find and Replace..." keyEquiv:@"f" modifier:cmd|opt selector:@"performFindPanelAction:"]];
		[findMenu addItem:[QPDFMenu itemWithTitle:@"Find Next" keyEquiv:@"g" modifier:cmd selector:@"performFindPanelAction:"]];
		[findMenu addItem:[QPDFMenu itemWithTitle:@"Find Previous" keyEquiv:@"G" modifier:cmd selector:@"performFindPanelAction:"]];
		[findMenu addItem:[QPDFMenu itemWithTitle:@"Use Selection for Find" keyEquiv:@"e" modifier:cmd selector:@"performFindPanelAction:"]];
		[findMenu addItem:[QPDFMenu itemWithTitle:@"Jump to Selection" keyEquiv:@"j" modifier:cmd selector:@"centerSelectioninVisibleArea:"]];

		
		NSMenu* transMenu = [[NSMenu new] autorelease];
		[transMenu setAutoenablesItems:YES];
		[transMenu addItem:[QPDFMenu itemWithTitle:@"Make Upper Case" selector:@"uppercaseWord:"]];
		[transMenu addItem:[QPDFMenu itemWithTitle:@"Make Lower Case" selector:@"lowercaseWord:"]];
		[transMenu addItem:[QPDFMenu itemWithTitle:@"Capitalise" selector:@"capitalizeWord:"]]; // you say tom-ay-toe and I say tom-ar-toe

		
		NSMenu* formatMenu = [[NSMenu new] autorelease];
		[formatMenu setAutoenablesItems:YES];
		[formatMenu addItem:[QPDFMenu itemWithTitle:@"Show Fonts" keyEquiv:@"T" modifier:cmd|ctrl  selector:@"orderFrontFontPanel:"]];
		[formatMenu addItem:[QPDFMenu itemWithTitle:@"Bigger" keyEquiv:@"+" modifier:cmd|opt selector:@"modifyFont:"]];
		[formatMenu addItem:[QPDFMenu itemWithTitle:@"Smaller" keyEquiv:@"-" modifier:cmd|opt selector:@"modifyFont:"]];
		[formatMenu addItem:[NSMenuItem separatorItem]];
		[formatMenu addItem:[QPDFMenu itemWithTitle:@"Transformation" submenu:transMenu]];


		NSMenu* editMenu = [[NSMenu new] autorelease];
		[editMenu setAutoenablesItems:YES];
		[editMenu setTitle:@"Edit"];
		[editMenu addItem:[QPDFMenu itemWithTitle:@"Undo" keyEquiv:@"z" modifier:cmd selector:@"undo:"]];
		[editMenu addItem:[QPDFMenu itemWithTitle:@"Redo" keyEquiv:@"Z" modifier:cmd selector:@"redo:"]];
		[editMenu addItem:[NSMenuItem separatorItem]];
		[editMenu addItem:[QPDFMenu itemWithTitle:@"Cut" keyEquiv:@"x" modifier:cmd selector:@"cut:"]];
		[editMenu addItem:[QPDFMenu itemWithTitle:@"Copy" keyEquiv:@"c" modifier:cmd selector:@"copy:"]];
		[editMenu addItem:[QPDFMenu itemWithTitle:@"Paste" keyEquiv:@"v" modifier:cmd selector:@"paste:"]]; // or maybe pasteAsPlainText:
		[editMenu addItem:[QPDFMenu itemWithTitle:@"Delete"  keyEquiv:bkspace modifier:cmd selector:@"delete:"]];
		[editMenu addItem:[QPDFMenu itemWithTitle:@"Select All" keyEquiv:@"a" modifier:cmd selector:@"selectAll:"]];
		[editMenu addItem:[NSMenuItem separatorItem]];
		[editMenu addItem:[QPDFMenu itemWithTitle:@"Find" submenu:findMenu]];
		[editMenu addItem:[QPDFMenu itemWithTitle:@"Format" submenu:formatMenu]];
		[self addItem:[QPDFMenu itemWithSubmenu:editMenu]];

		
		NSMenu* viewMenu = [[NSMenu new] autorelease];
		[viewMenu setAutoenablesItems:YES];
		[viewMenu setTitle:@"View"];
		[viewMenu addItem:[QPDFMenu itemWithTitle:@"Actual Size" keyEquiv:@"0" modifier:cmd selector:@"zoomAct:"]];
		[viewMenu addItem:[QPDFMenu itemWithTitle:@"Zoom to Fit" keyEquiv:@"9" modifier:cmd selector:@"zoomAct:"]];
		[viewMenu addItem:[QPDFMenu itemWithTitle:@"Zoom In" keyEquiv:@"+" modifier:cmd selector:@"zoomIn:"]];
		[viewMenu addItem:[QPDFMenu itemWithTitle:@"Zoom Out" keyEquiv:@"-" modifier:cmd selector:@"zoomOut:"]];
		[self addItem:[QPDFMenu itemWithSubmenu:viewMenu]];

		NSMenu* sizeMenu = [[NSMenu new] autorelease];
		[sizeMenu setAutoenablesItems:NO];
		[sizeMenu addItem:[QPDFMenu itemWithTitle:@"A3" selector:@"setMediabox:" tag:0]];
		[sizeMenu addItem:[QPDFMenu itemWithTitle:@"A4" selector:@"setMediabox:" tag:1]];
		[sizeMenu addItem:[QPDFMenu itemWithTitle:@"A5" selector:@"setMediabox:" tag:2]];
		[sizeMenu addItem:[QPDFMenu itemWithTitle:@"B3" selector:@"setMediabox:" tag:3]];
		[sizeMenu addItem:[QPDFMenu itemWithTitle:@"B4" selector:@"setMediabox:" tag:4]];
		[sizeMenu addItem:[QPDFMenu itemWithTitle:@"C3" selector:@"setMediabox:" tag:5]];
		[sizeMenu addItem:[QPDFMenu itemWithTitle:@"C4" selector:@"setMediabox:" tag:6]];
		[sizeMenu addItem:[QPDFMenu itemWithTitle:@"DL" selector:@"setMediabox:" tag:7]];
		[sizeMenu addItem:[QPDFMenu itemWithTitle:@"DLX" selector:@"setMediabox:" tag:8]];
		[sizeMenu addItem:[NSMenuItem separatorItem]];
		[sizeMenu addItem:[QPDFMenu itemWithTitle:@"Letter" selector:@"setMediabox:" tag:9]];
		[sizeMenu addItem:[QPDFMenu itemWithTitle:@"Legal" selector:@"setMediabox:" tag:10]];
		[sizeMenu addItem:[QPDFMenu itemWithTitle:@"Tabloid" selector:@"setMediabox:" tag:11]];
		[sizeMenu addItem:[QPDFMenu itemWithTitle:@"Number 10" selector:@"setMediabox:" tag:12]];
		[sizeMenu addItem:[QPDFMenu itemWithTitle:@"A2 Lady Grey" selector:@"setMediabox:" tag:13]];
		[sizeMenu addItem:[QPDFMenu itemWithTitle:@"A9 Diplomat" selector:@"setMediabox:" tag:14]];
		
		NSMenu* toolMenu = [[NSMenu new] autorelease];
		[toolMenu setAutoenablesItems:YES];
		[toolMenu setTitle:@"Page"];
		[toolMenu addItem:[QPDFMenu itemWithTitle:@"PageSize" submenu:sizeMenu]];
		[toolMenu addItem:[QPDFMenu itemWithTitle:@"Insert" submenu:nil]];
	
		[toolMenu addItem:[QPDFMenu itemWithTitle:@"Tool Box" keyEquiv:@"" modifier:cmd selector:@""]];
		[toolMenu addItem:[QPDFMenu itemWithTitle:@"Pointer" keyEquiv:@"" modifier:cmd selector:@""]];
		[toolMenu addItem:[QPDFMenu itemWithTitle:@"Font Finder" keyEquiv:@"" modifier:cmd selector:@""]];
		[self addItem:[QPDFMenu itemWithSubmenu:toolMenu]];

		
		NSMenu* windowMenu = [[NSMenu new] autorelease];
		[windowMenu setAutoenablesItems:YES];
		[windowMenu setTitle:@"Window"];
		[self setWindowsMenu:windowMenu];
		[windowMenu addItem:[QPDFMenu itemWithTitle:@"Minimize" keyEquiv:@"m" modifier:cmd selector:@"performMiniturize:"]];
		[windowMenu addItem:[QPDFMenu itemWithTitle:@"Zoom" selector:@"performZoom:"]];
		[windowMenu addItem:[NSMenuItem separatorItem]];
		[windowMenu addItem:[QPDFMenu itemWithTitle:@"Bring All to Front" selector:@"arrangeInFront:"]];
		[self addItem:[QPDFMenu itemWithSubmenu:windowMenu]];

		NSMenu* helpMenu = [[NSMenu new] autorelease];
		[helpMenu setAutoenablesItems:YES];
		[helpMenu setTitle:@"Help"];
		[helpMenu addItem:[QPDFMenu itemWithTitle:@"PDF Documentation" keyEquiv:@")" modifier:cmd selector:@""]];
		[self addItem:[QPDFMenu itemWithSubmenu:helpMenu]];

	}
	return self;
}

+ (NSArray<NSString*>*)pageSizes
{
	return @[@"842.75,1191.82",
			 @"595.91,842.75",
			 @"421.27,595.91",
			 @"708.67,1002.2",
			 @"501.1,708.67",
			 @"919.02,1299.69",
			 @"649.85,919.02",
			 @"623.62,311.81",
			 @"666.14,340.16",
			 @"612,792",
			 @"612,1008",
			 @"792,1224",
			 @"360,576",
			 @"684,295.2",
			 @"410.4,316.8",
			 @"626.4,410.4"
			 ];
}

@end
