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
	ObjcQPDF* qDocument;
	// QPDFWindowController* winCon;  // yet another instance variable handled by super
}

- (instancetype)init;
- (instancetype)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError;
- (nullable instancetype)initForURL:(nullable NSURL *)urlOrNil withContentsOfURL:(NSURL *)contentsURL ofType:(NSString *)typeName error:(NSError **)outError;

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError;
- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError;
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError;
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError;
- (void)saveDocument:(nullable id)sender;
- (void)saveDocumentAs:(nullable id)sender;
+ (BOOL)autosavesInPlace;

- (NSString*)pdfString;
- (PDFDocument*)pdfdocument;
- (PDFDocument*)pdfDocumentPage:(NSUInteger)page;
- (ObjcQPDF*)doc;
- (NSString*)displayName;
- (void)makeWindowControllers;

// All Document modifying methods should be here
- (nullable ObjcQPDFObjectHandle*)replaceIndirect:(ObjcQPDFObjectHandle*)search;
+ (void)addObject:(ObjcQPDFObjectHandle*)obj to:(ObjcQPDFObjectHandle*)container;
- (BOOL)addItemOfType:(object_type_e)type toObject:(ObjcQPDFObjectHandle*)obj;
- (void)addStandardFont:(NSString*)fontName toPage:(NSInteger)pageNumber;
- (void)newPageAtEnd;
- (void)newPageBeforePage:(ObjcQPDFObjectHandle*)existingPage;
- (void)newPageBeforePageNumber:(NSUInteger)pageNumber;


// - (void)deleteNode:(QPDFNode*)nd;
- (void)deleteHandle:(ObjcQPDFObjectHandle*)nd;

// - (void)replaceQPDFNode:(QPDFNode*)node withString:(NSString*)editor;
- (void)replaceHandle:(ObjcQPDFObjectHandle*)node withString:(NSString*)editor;

- (void)setSize:(NSString*)size forPage:(NSUInteger)page;


@end

NS_ASSUME_NONNULL_END

