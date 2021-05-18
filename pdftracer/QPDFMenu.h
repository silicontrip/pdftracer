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

//- (instancetype)initMenu;  // naming this init causes infinite recursion (or enough to exhaust the resource stack)
- (instancetype)init;  // getting brave since the menu re-factor
+ (NSArray<NSString*>*)pageSizes;


@end

NS_ASSUME_NONNULL_END
