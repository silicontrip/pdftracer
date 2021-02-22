//
//  QPDFDocument.h
//  pdftracer
//
//  Created by Mark Heath on 28/1/21.
//  Copyright © 2021 silicontrip. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "ObjcQPDF.h"
#import "QPDFWindow.h"

@class QPDFWindowController;

NS_ASSUME_NONNULL_BEGIN

@interface QPDFDocument : NSDocument
{
	@private
	PDFDocument* pDoc;
	// NSData *contentData;
	ObjcQPDF* qDocument;
	// QPDFWindowController* winCon;  // yet another instance variable handled by super
}

- (instancetype)init;
- (instancetype)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError;
- (void)saveDocument:(nullable id)sender;
- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError;
- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError;
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError;
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError;
- (PDFDocument*)pdfdocument;
- (ObjcQPDF*)doc;
- (NSString*)displayName;
+ (BOOL)autosavesInPlace;
// All Document modifying methods should be here
- (void)deleteNode:(QPDFNode*)nd;
- (void)replaceQPDFNode:(QPDFNode*)node withString:(NSString*)editor;


@end

NS_ASSUME_NONNULL_END
