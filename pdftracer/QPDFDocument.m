//
//  QPDFDocument.m
//  pdftracer
//
//  Created by Mark Heath on 28/1/21.
//  Copyright © 2021 silicontrip. All rights reserved.
//

#import "QPDFDocument.h"

#import "OutlineQPDF.h"
#import "OutlineQPDFPage.h"
#import "OutlineQPDFObj.h"
#import "QPDFWindowController.h"
#import "ObjcQPDF.h"

@implementation QPDFDocument

-(instancetype)init
{
	self=[super init];
	if (self) {
		pDoc = nil;
		[self setFileURL:nil];
		qDocument = [[ObjcQPDF alloc] init];
	}
	return self;
}

// - (instancetype)initWithType:(NSString *)typeName error:(NSError * _Nullable *)outError

- (instancetype)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError
{
	return [self initForURL:url withContentsOfURL:url ofType:@"PDF" error:outError];
}

- (nullable instancetype)initForURL:(nullable NSURL *)urlOrNil withContentsOfURL:(NSURL *)contentsURL ofType:(NSString *)typeName error:(NSError **)outError
{
	self = [super init];
	if (self) {
		[self setFileURL:urlOrNil];

		pDoc = nil;
		qDocument = [[ObjcQPDF alloc] initWithURL:urlOrNil];
	}
	return self;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError
{
	[self setFileURL:url];
	qDocument = [[ObjcQPDF alloc] initWithURL:url];
	
	return YES;
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError
{
	return [[qDocument data] writeToURL:url atomically:YES];
}
 
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error if you return nil.
    // Alternatively, you could remove this method and override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
	if ([typeName isEqualToString:@"QDF"])
		return [qDocument qdf];
	
	return [qDocument data];
	
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error if you return NO.
    // Alternatively, you could remove this method and override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you do, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
	
	qDocument = [[ObjcQPDF alloc] initWithData:data];
	
	return YES;

}

- (void)saveDocument:(nullable id)sender
{
	for (NSWindowController* wc in [self windowControllers])
		[wc setDocumentEdited:NO];
	
	NSError *theError;
	NSURL * fn = [NSURL fileURLWithPath:[qDocument filename]];

	[self writeToURL:fn ofType:@"PDF" error:&theError];
	
}

- (void)saveDocumentAs:(nullable id)sender
{
	NSString * fn = [self displayName];
	
	NSWindow* w = [[[self windowControllers] firstObject] window];

	NSSavePanel* p = [NSSavePanel savePanel];
	[p retain];
	[p setNameFieldStringValue:fn];
	[p beginSheetModalForWindow:w completionHandler:^(NSInteger result){
		if (result == NSModalResponseOK)
		{
			NSURL*  theFile = [p URL];
			NSError *theError;
			[self writeToURL:theFile ofType:@"PDF" error:&theError];
			// Write the contents in the new format.
			[[[self windowControllers] firstObject] setDocumentEdited:NO];
		}
		[p autorelease];
	}];
}

+ (BOOL)autosavesInPlace {
    return NO;
}

- (NSString*)pdfString
{
	return [[[NSString alloc] initWithData:[qDocument data] encoding:NSMacOSRomanStringEncoding] autorelease];
}

- (PDFDocument*)pdfdocument
{
	return [qDocument document];
}

-(void)makeWindowControllers
{
	NSRect rr = NSMakeRect(10, 10, 640, 480);  // want better defaults
	NSUInteger windowStyle =  NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable;
	QPDFWindow* w = [[QPDFWindow alloc] initWithContentRect:rr styleMask:windowStyle backing:NSBackingStoreBuffered];
	QPDFWindowController* nwc = [[QPDFWindowController alloc] initWithWindow:w];

	[self addWindowController:nwc];
	
	[w setDataSource];
}

- (ObjcQPDF*)doc
{
	return qDocument;
}

- (NSString*)displayName
{
	NSString * fn = [qDocument filename];
	if ([fn isEqualToString:@"empty PDF"])
		return @"Untitled";
	
	return [fn lastPathComponent];
}

// this is purely document changing code
- (void)replaceQPDFNode:(QPDFNode*)node withString:(NSString*)editor
{
	ObjcQPDFObjectHandle* qpdf = [node object];
	
	if ([editor length]>0)
	{
		if([qpdf isStream])
		{
			[qpdf replaceStreamData:editor];
		} else {
			
			NSError* err = NULL;
			NSRegularExpression *indirectRegex = [NSRegularExpression regularExpressionWithPattern:@"\\d+ \\d+ R"
																						   options:0
																							 error:&err];
			
			NSUInteger indirects = [indirectRegex numberOfMatchesInString:editor
																  options:0
																	range:NSMakeRange(0, [editor length])];
			
			NSLog(@" number of indirects: %lu",indirects);
			
			ObjcQPDFObjectHandle* rePDFObj;
			if (indirects == 0) {
				rePDFObj = [[[ObjcQPDFObjectHandle alloc] initWithString:editor] autorelease];
			} else {
				// safe init
				rePDFObj = [[[ObjcQPDFObjectHandle alloc] initWithString:@"()"] autorelease];
				
			}
			// work out if rePDFObj is valid
			
			if ([qpdf isIndirect]) {
				
				NSString* ogi = [qpdf objectGenerationID];
				NSLog(@"Indirect OBJECT at: %@",ogi);
				NSLog(@"With obj: %@ -- %@",rePDFObj,[rePDFObj unparse]);

				[qDocument replaceID:ogi with:rePDFObj];
				
				[(QPDFWindowController*)[[self windowControllers] firstObject] invalidateAll];
				
				NSArray<ObjcQPDFObjectHandle*>* objTable= [qDocument objects];
				for (ObjcQPDFObjectHandle* obj in objTable)
					NSLog(@"Object: %@: %@",[obj name],[obj unparseResolved]);
			} else {
				ObjcQPDFObjectHandle* parent = [node parent];

				if ([parent isArray])
				{
					[parent replaceObjectAtIndex:[[node name] integerValue] withObject:rePDFObj];
				} else if ([parent isDictionary]) {
					[parent replaceObject:rePDFObj forKey:[node name]];
				} else  {
					// oh no the dreaded child of neither a dictionary or array and isn't an indirect object either
					NSLog(@"where are we?");
				}
			}
		}
	}
}

- (void)deleteNode:(QPDFNode*)nd
{
	QPDFNode* pa = [nd parentNode];
	if (pa != nil)
	{
		ObjcQPDFObjectHandle* parentNode = [pa object];
		// delet from parent
		if ([parentNode isArray])
		{
			// delete from array
		} else if ([parentNode isDictionary]) {
			// delete from Dictionary
		} else {
			// yet another unknown parent type
			NSLog(@"I didn't expect to get here: %@",[parentNode typeName]);
		}
	} else {
		// top level item.
		ObjcQPDFObjectHandle* tn = [nd object];
		if ([tn isIndirect]) {
			NSString* gen = [tn objectGenerationID];
			
		}

	}
}

/*
- (BOOL)respondsToSelector:(SEL)aSelector
{
	NSString* selstr =NSStringFromSelector(aSelector);
	if (![selstr isEqualToString:@"validModesForFontPanel:"])
	{
		NSLog(@"DOC EVENT -> %@",NSStringFromSelector(aSelector));
		if( [NSWindowController instancesRespondToSelector:aSelector] ) {
			// invoke the inherited method
			return YES;
		}
	}
	return NO;
}
*/

@end
