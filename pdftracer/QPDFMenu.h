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
	
}

- (instancetype)initWithMenu;
+ (NSMenu*)newMenu:(NSArray*)menutitle keys:(NSArray*)keyequiv selectors:(NSArray*)select;
+ (NSMenuItem*)newMenuBar:(NSString*)menutitle with:(NSArray*)menus keys:(NSArray*)keys selectors:(NSArray*)select;

@end

NS_ASSUME_NONNULL_END
