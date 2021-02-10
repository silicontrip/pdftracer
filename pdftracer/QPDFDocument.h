//
//  QPDFDocument.h
//  pdftracer
//
//  Created by Mark Heath on 28/1/21.
//  Copyright © 2021 silicontrip. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
//#import "QPDFDocumentController.h"


@class QPDFWindowController;

NS_ASSUME_NONNULL_BEGIN

@interface QPDFDocument : NSDocument
{
	@private
	PDFDocument* pDoc;
	NSData *contentData;
}

- (instancetype)init;
- (instancetype)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError;
- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError;
- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError;
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError;
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError;
- (PDFDocument*)pdfdocument;
// - (QPDF)qpdf;
- (NSString*)filePath;
+ (BOOL)autosavesInPlace;

/*
- (OutlineQPDF*)pdfDataSource;
- (OutlinePDFObj*)pdfObjDataSource;
- (OutlinePDFPage*)pdfPageDataSource;
*/
@end

NS_ASSUME_NONNULL_END
