//
//  QPDFMenu.h
//  pdftracer
//
//  Created by Mark Heath on 9/2/21.
//  Copyright © 2021 silicontrip. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface QPDFMenu : NSMenu
{
	//   // yet another super instance var
}

@property (strong) NSMenu* windowsMenu;

- (instancetype)initMenu;  // calling this init causes infinite recursion (or enough to exhaust the resource stack)
- (NSMenu*)windowsMenu;
+ (NSMenu*)newMenu:(NSArray*)menutitle keys:(NSArray*)keyequiv selectors:(NSArray*)select;
+ (NSMenuItem*)newMenuBar:(NSString*)menutitle with:(NSArray*)menus keys:(NSArray*)keys selectors:(NSArray*)select;

@end

NS_ASSUME_NONNULL_END
