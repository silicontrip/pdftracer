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
	// NSLog(@"QPDFD init");
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
	//NSLog(@"QPDFDoc initWithContentsOfURL: %@",url);  // open document from menu is failing.

	return [self initForURL:url withContentsOfURL:url ofType:@"PDF" error:outError];
}

- (nullable instancetype)initForURL:(nullable NSURL *)urlOrNil withContentsOfURL:(NSURL *)contentsURL ofType:(NSString *)typeName error:(NSError **)outError
{
	// NSLog(@"QPDFDoc initForURL: %@ %@",urlOrNil,contentsURL);  // open document is failing

	self = [super init];
	if (self) {
		[self setFileURL:urlOrNil];
		[self setDisplayName:[urlOrNil description]];

		pDoc = nil;
		qDocument = [[ObjcQPDF alloc] initWithURL:contentsURL];
	}
	return self;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError
{
	// NSLog(@"QPDFD readFromURL");

	[self setFileURL:url];
	qDocument = [[ObjcQPDF alloc] initWithURL:url];
	[self setDisplayName:[url description]];
	return YES;
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError
{
	return [[qDocument data] writeToURL:url atomically:YES];
}
 
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error if you return nil.
    // Alternatively, you could remove this method and override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

	// this is only for objc++ code, which we are not.
//	if ([typeName isEqualToString:@"PDF"])
//		return [qDocument pdf];
	
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
	[self updateChangeCount:NSChangeCleared];
	[[[self windowControllers] firstObject] setDocumentEdited:NO];

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
		//	[self renameDocument:theFile];
			[self writeToURL:theFile ofType:@"PDF" error:&theError];
			// Write the contents in the new format.
			[[[self windowControllers] firstObject] setDocumentEdited:NO];
		}
		[p release];
		//p=nil;
	}];
	// if(p)
	//	[p autorelease];
	[self updateChangeCount:NSChangeCleared];
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


// I'm wondering if this document is being released too soon..
- (PDFDocument*)pdfDocumentPage:(NSUInteger)page
{
	ObjcQPDF* blank = [[[ObjcQPDF alloc] init] autorelease];
	//ObjcQPDF* doc = qDocument;
	ObjcQPDFObjectHandle* pageObj = [qDocument pageAtIndex:page];

	if (pageObj)
		[blank addPageUsingHelper:pageObj atStart:YES];
	return [blank document];
}

- (ObjcQPDF*)copyDocumentPage:(NSUInteger)page
{
	ObjcQPDF* blank = [[ObjcQPDF alloc] init];
	//ObjcQPDF* doc = qDocument;
	ObjcQPDFObjectHandle* pageObj = [qDocument pageAtIndex:page];

	if (pageObj)
		[blank addPageUsingHelper:pageObj atStart:YES];
	return blank;
}


- (ObjcQPDFObjectHandle*)pageObject:(NSUInteger)page
{
	return [qDocument pageAtIndex:page];
}

//- (NSPrintOperation*)print:(id)sender

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary<NSPrintInfoAttributeKey, id> *)printSettings
										   error:(NSError * _Nullable *)outError;
{
	PDFPrintScalingMode scale = kPDFPrintPageScaleDownToFit;

	NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
	[printInfo setTopMargin:0.0];
	[printInfo setBottomMargin:0.0];
	[printInfo setLeftMargin:0.0];
	[printInfo setRightMargin:0.0];
	[printInfo setHorizontalPagination:NSPrintingPaginationModeFit];
	[printInfo setVerticalPagination:NSPrintingPaginationModeFit];
	
// Grab the returned print operation.
	return [[qDocument document] printOperationForPrintInfo:printInfo scalingMode:scale autoRotate:YES];
}

- (void)addStandardFont:(NSString*)fontName toPage:(NSInteger)pageNumber
{
	ObjcQPDFObjectHandle* pageObj = [qDocument pageAtIndex:pageNumber];
	if (pageObj != nil)
	{
		ObjcQPDFObjectHandle* pageResource = [pageObj objectForKey:@"/Resources"];
		if (pageResource == nil)
			pageResource = [ObjcQPDFObjectHandle dictionaryObject];
		
		ObjcQPDFObjectHandle* fontResource = [pageResource objectForKey:@"/Font"];
		if (fontResource == nil)
			fontResource = [ObjcQPDFObjectHandle dictionaryObject];
		
		ObjcQPDFObjectHandle* fontDict = [ObjcQPDFObjectHandle dictionaryObject];
		
		[fontDict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/Type1"] forKey:@"/Subtype"];
		[fontDict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/Font"] forKey:@"/Type"];
		[fontDict replaceObject:[ObjcQPDFObjectHandle nameWith:[NSString stringWithFormat:@"/%@",fontName]] forKey:@"/BaseFont"];

		[QPDFDocument addObject:fontDict to:fontResource];
		[pageResource replaceObject:fontResource forKey:@"/Font"];
		[pageObj replaceObject:pageResource forKey:@"/Resources"];
		
	}
}

- (void)insertImage:(NSString*)path onPage:(NSInteger)pageNumber
{
	ObjcQPDFObjectHandle* pageObj = [qDocument pageAtIndex:pageNumber];
	if (pageObj != nil)
	{
		NSData* fileData = [NSData dataWithContentsOfFile:path];
		if (!fileData) return;
		
		NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:fileData];
		if (!rep) return;
		
		NSData *streamData = nil;
		NSString *filter = nil;
		
		BOOL isJPEG = NO;
		if (fileData.length > 2) {
			const uint8_t *bytes = (const uint8_t*)fileData.bytes;
			if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
				isJPEG = YES;
			}
		}
		
		NSInteger width = [rep pixelsWide];
		NSInteger height = [rep pixelsHigh];

		ObjcQPDFObjectHandle* imageStream = [ObjcQPDFObjectHandle newStreamForQPDF:qDocument];
		ObjcQPDFObjectHandle* dict = [imageStream streamDictionary];

		if (isJPEG) {
			// JPEG Pass-through: Set data directly, set filter manually.
			[imageStream replaceStreamData:fileData filter:nil];
			[dict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/DCTDecode"] forKey:@"/Filter"];
		} else {
			// Convert to JPEG
			NSDictionary *props = @{NSImageCompressionFactor: @(0.9)};
			NSData *jpegData = [rep representationUsingType:NSBitmapImageFileTypeJPEG properties:props];
			
			if (jpegData) {
				[imageStream replaceStreamData:jpegData filter:nil];
				[dict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/DCTDecode"] forKey:@"/Filter"];
			} else {
				// Fallback to raw if JPEG conversion fails (unlikely)
				// Use standard QPDF compression for fallback
				NSData *rawData = [NSData dataWithBytes:rep.bitmapData length:width * height * 3];
				[imageStream replaceStreamData:rawData filter:nil]; 
				// We don't set a filter here, relying on QPDFWriter's compress mode as a last resort
			}
		}
		
		[dict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/XObject"] forKey:@"/Type"];
		[dict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/Image"] forKey:@"/Subtype"];
		// Filter is set by replaceStreamData (for Flate) or manually (for DCT)
		[dict replaceObject:[ObjcQPDFObjectHandle newInteger:width] forKey:@"/Width"];
		[dict replaceObject:[ObjcQPDFObjectHandle newInteger:height] forKey:@"/Height"];
		[dict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/DeviceRGB"] forKey:@"/ColorSpace"];
		[dict replaceObject:[ObjcQPDFObjectHandle newInteger:8] forKey:@"/BitsPerComponent"];
		
		ObjcQPDFObjectHandle* pageResource = [pageObj objectForKey:@"/Resources"];
		if (pageResource == nil) {
			pageResource = [ObjcQPDFObjectHandle dictionaryObject];
			[pageObj replaceObject:pageResource forKey:@"/Resources"];
		}
		
		ObjcQPDFObjectHandle* xObjResource = [pageResource objectForKey:@"/XObject"];
		if (xObjResource == nil) {
			xObjResource = [ObjcQPDFObjectHandle dictionaryObject];
			[pageResource replaceObject:xObjResource forKey:@"/XObject"];
		}
		
		[QPDFDocument addObject:imageStream to:xObjResource];
	}
}

- (void)setSize:(NSString*)rectSize forPage:(NSUInteger)page
{

	ObjcQPDFObjectHandle* pdfmbox = [[ObjcQPDFObjectHandle newArrayWithRectangle:NSRectFromString(rectSize)] autorelease];

	// NSLog(@"pdf mbox -> %@",pdfmbox);

	ObjcQPDFObjectHandle* pageObj = [qDocument pageAtIndex:page];
	[pageObj replaceObject:pdfmbox forKey:@"/MediaBox"];
}

- (void)setPagesSize:(NSString*)rectSize 
{
	
	ObjcQPDFObjectHandle* pdfmbox = [[ObjcQPDFObjectHandle newArrayWithRectangle:NSRectFromString(rectSize)] autorelease];
	
	// NSLog(@"pdf mbox -> %@",pdfmbox);
	
	ObjcQPDFObjectHandle* root = [[qDocument copyRootCatalog] autorelease];
	ObjcQPDFObjectHandle* pages = [root objectForKey:@"/Pages"];
	if (pages)
		[pages replaceObject:pdfmbox forKey:@"/MediaBox"];
	
}

-(void)makeWindowControllers
{
	// NSLog(@"QPDFDoc makeWindowControllers");
	
	NSRect rr = NSMakeRect(10, 10, 1440, 480);  // want better defaults
	NSUInteger windowStyle =  NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable;
	NSNotificationCenter* centre = [[NSNotificationCenter new] autorelease];
	QPDFWindow* w = [[QPDFWindow alloc] initWithContentRect:rr styleMask:windowStyle backing:NSBackingStoreBuffered notificationCenter:centre];
	QPDFWindowController* nwc = [[[QPDFWindowController alloc] initWithWindow:w notificationCenter:centre] autorelease];

	// [w makeKeyAndOrderFront:self];
	[self addWindowController:nwc];
	[nwc initDataSource];

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

- (nullable ObjcQPDFObjectHandle*)replaceIndirect:(ObjcQPDFObjectHandle*)search
{
	
	if ([search isArray])
	{
		for (int w = 0 ; w < [search count]; w++)
		{
			ObjcQPDFObjectHandle* thisObj = [search objectAtIndex:w];
			NSLog(@"%d . %@",w,[thisObj typeName]);
		}
		return nil;

	} else if ([search isDictionary]) {
		int w = 0;
		for (NSString* kk in [search keys])
		{
			ObjcQPDFObjectHandle* thisObj = [search objectForKey:kk];
			NSLog(@"%d . %@",++w,[thisObj typeName]);
		}
		return nil;
	}
	return nil;

}

// this is purely document changing code

- (void)replaceHandle:(ObjcQPDFObjectHandle*)qpdf withString:(NSString*)editor
{
	// NSLog(@"when does replaceQPDFNode get called?");  // looks like when the textview changes during live editing.
	// ObjcQPDFObjectHandle* qpdf = [node object];
	
	if ([editor length]>0)
	{
		if([qpdf isStream])
		{
			[qpdf replaceStreamData:editor];
		}
		else
		{
			NSLog(@"when does replaceQPDFNode get called, other than texteditview changes?");
			NSError* err = NULL;
			NSRegularExpression *indirectRegex = [NSRegularExpression regularExpressionWithPattern:@"\\d+ \\d+ R"
																						   options:0
																							 error:&err];
			NSRange editRange = NSMakeRange(0, [editor length]);
			NSUInteger indirects = [indirectRegex numberOfMatchesInString:editor
																  options:0
																	range:editRange];
			
			// NSLog(@"number of indirects: %lu",indirects);
			
			ObjcQPDFObjectHandle* rePDFObj;
			if (indirects == 0) {
				rePDFObj = [[[ObjcQPDFObjectHandle alloc] initWithString:editor] autorelease];
			} else {
				// safe init
				// turn all indirects into strings
				/*  SO - 9661690
				 NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"&[^;]*;" options:NSRegularExpressionCaseInsensitive error:&error];
				 NSString *modifiedString = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@""];
				*/
				NSString* safeUnparse = [indirectRegex stringByReplacingMatchesInString:editor options:0 range:editRange withTemplate:@"($0)"];

				
				rePDFObj = [[[ObjcQPDFObjectHandle alloc] initWithString:safeUnparse] autorelease];
				// walk the object and turn back into indirects
				//NSLog(@"type %@",[rePDFObj typeName]);
				[self replaceIndirect:rePDFObj];
				/*
				 QPDFObjectHandle font = doSomethingToGetFont();
				 auto resources = QPDFObjectHandle::parse("<< /Font << >> >>");
				 resources.getKey("/Font").replaceKey("/F1", font);
				 */
				
			}
			// work out if rePDFObj is valid
			
			if ([qpdf isIndirect]) {
				
				NSString* ogi = [qpdf objectGenerationID];
				NSLog(@"Indirect OBJECT at: %@",ogi);
				NSLog(@"With obj: %@ -- %@",rePDFObj,[rePDFObj unparse]);

				[qDocument replaceID:ogi with:rePDFObj];
				
	//			[(QPDFWindowController*)[[self windowControllers] firstObject] invalidateAll];
				
				NSArray<ObjcQPDFObjectHandle*>* objTable= [qDocument objects];
				for (ObjcQPDFObjectHandle* obj in objTable)
					NSLog(@"Object: %@: %@",[obj name],[obj unparse]);
			} else {
				ObjcQPDFObjectHandle* parent = [qpdf parent];

				if ([parent isArray])
				{
					[parent replaceObjectAtIndex:[[qpdf elementName] integerValue] withObject:rePDFObj];
				} else if ([parent isDictionary]) {
					[parent replaceObject:rePDFObj forKey:[qpdf elementName]];
				} else  {
					// oh no the dreaded child of neither a dictionary or array and isn't an indirect object either
					NSLog(@"case on: %@",parent);
					NSLog(@"where are we?");
				}
			}
		}
	}
}

// could possibly be static
+ (void)addObject:(ObjcQPDFObjectHandle*)obj to:(ObjcQPDFObjectHandle*)container
{
	if ([container isArray])
	{
		[container addObject:obj];
	} else if ([container isDictionary]) {
		NSString* uniqueName = @"/Untitled";
		int version=1;
		ObjcQPDFObjectHandle* found = [container objectForKey:uniqueName];
		while (found != nil) {
			uniqueName = [NSString stringWithFormat:@"/Untitled-%d",version++];
			found = [container objectForKey:uniqueName];
		}
		
		[container replaceObject:obj forKey:uniqueName];
	} else {
		NSLog(@"Adding to unknown type");
	}
	
}

/*
 typedef NS_ENUM(NSInteger, QPDFObjectTypeEnum) {
 QPDFObjectTypeUninitialized = 0,
 QPDFObjectTypeReserved = 1,
 QPDFObjectTypeNull = 2,
 QPDFObjectTypeBoolean = 3,
 QPDFObjectTypeInteger = 4,
 QPDFObjectTypeReal = 5,
 QPDFObjectTypeString = 6,
 QPDFObjectTypeName = 7,
 QPDFObjectTypeArray = 8,
 QPDFObjectTypeDictionary = 9,
 QPDFObjectTypeStream = 10,
 QPDFObjectTypeOperator = 11,
 QPDFObjectTypeInlineImage = 12
 };
 */

- (BOOL)addItemOfType:(QPDFObjectTypeEnum)type toObject:(ObjcQPDFObjectHandle*)obj
{
	ObjcQPDFObjectHandle* newobj = nil;
	// if adding to dictionary auto highlight edit /Name
	// if adding to array auto highlight edit value
	switch (type) {
		case QPDFObjectTypeNull:
			newobj = [ObjcQPDFObjectHandle newNull];
			break;;
		case QPDFObjectTypeBoolean:
			newobj=[ObjcQPDFObjectHandle newBool:NO];
			break;;
		case QPDFObjectTypeInteger:
			newobj=[ObjcQPDFObjectHandle newInteger:0];
			break;;
		case QPDFObjectTypeReal:
			newobj=[ObjcQPDFObjectHandle newInteger:0.0];
			break;;
		case QPDFObjectTypeString:
			newobj=[ObjcQPDFObjectHandle newString:@""];
			break;;
		case QPDFObjectTypeName:
			newobj=[ObjcQPDFObjectHandle newName:@"/Name"];
			break;;
		case QPDFObjectTypeArray:
			newobj=[ObjcQPDFObjectHandle newArray];
			break;;
		case QPDFObjectTypeDictionary:
			newobj=[ObjcQPDFObjectHandle newDictionary];
			break;;
		case QPDFObjectTypeStream:
			//NSLog(@"creating stream");
			newobj=[ObjcQPDFObjectHandle newStreamForQPDF:qDocument withString:@""];
			break;
		default:
			NSAssert(NO, @"Creating unknown type"); // NSLog(@"You're creating a wha-?"); // assert

	}
	if (newobj)
	{
		[QPDFDocument addObject:newobj to:obj];  // Add Row
		[newobj autorelease];
		return YES;
	}
	return NO;
}

+ (ObjcQPDFObjectHandle*)page
{
	ObjcQPDFObjectHandle* newpage = [[ObjcQPDFObjectHandle newDictionary] autorelease];
	//ObjcQPDFObjectHandle* mbox = [[ObjcQPDFObjectHandle newArray] autorelease];
	ObjcQPDFObjectHandle* type = [ObjcQPDFObjectHandle nameWith:@"/Page"];
	ObjcQPDFObjectHandle* resources = [[ObjcQPDFObjectHandle newDictionary] autorelease];
	ObjcQPDFObjectHandle* proc = [[ObjcQPDFObjectHandle newArray] autorelease];
	
	[proc addObject:[ObjcQPDFObjectHandle nameWith:@"/PDF"]]; // hmm wonder why the / isn't automatically added
	[resources replaceObject:proc forKey:@"/ProcSet"];
	
	//	[mbox addObject:[ObjcQPDFObjectHandle intWith:0]];
	//	[mbox addObject:[ObjcQPDFObjectHandle intWith:0]];
	//	[mbox addObject:[ObjcQPDFObjectHandle intWith:0]];
	//	[mbox addObject:[ObjcQPDFObjectHandle intWith:0]];
	
	[newpage replaceObject:type forKey:@"/Type"];
	// [newpage replaceObject:mbox forKey:@"/MediaBox"];
	[newpage replaceObject:resources forKey:@"/Resources"];
	
	return newpage;
}

- (void)newPageAtEnd
{
	[qDocument addPage:[QPDFDocument page] atStart:NO];
}

- (void)newPageBeforePageNumber:(NSUInteger)pageNumber
{
	[self newPageBeforePage:[qDocument pageAtIndex:pageNumber]]; // is this really the most efficient way?
}

- (void)newPageBeforePage:(ObjcQPDFObjectHandle*)existingPage
{
	[qDocument addPage:[QPDFDocument page] before:YES page:existingPage];
}

- (void)deleteHandle:(ObjcQPDFObjectHandle*)nd
{
	ObjcQPDFObjectHandle* parent = [nd parent];
	
	//NSLog(@"deletenode:\n %@\nfrom %@",nd,paNode);
	
	if (parent != nil)
	{
		// ObjcQPDFObjectHandle* parent = [paNode object];
		
	//	NSLog(@"delete from type:: %@",[parent typeName]);

	//	NSLog(@"isArray: %d",[parent isArray]);
	//	NSLog(@"isDictionary: %d",[parent isDictionary]);

		// delet from parent
		if ([parent isArray])
		{
			NSLog(@"delete from Array");
			
			NSLog(@"node name: %@",[nd elementName]);

			int element = [[nd elementName] intValue];
			[parent removeObjectAtIndex:element];
			[self updateChangeCount:NSChangeDone];
			[[[self windowControllers] firstObject] setDocumentEdited:YES];

			// delete from array
		} else if ([parent isDictionary]) {
			NSLog(@"delete from Dictionary");

			NSLog(@"node name: %@",[nd elementName]);
			[parent removeObjectForKey:[nd elementName]];

			[self updateChangeCount:NSChangeDone];
			// delete from Dictionary
		} else {
			// yet another unknown parent type
			NSLog(@"delete from wha-?");

			NSLog(@"I didn't expect to get here: %@",[parent typeName]);
		}
	} else {
		// top level item.
		//ObjcQPDFObjectHandle* tn = [nd object];
		if ([nd isIndirect]) {
			NSString* gen = [nd objectGenerationID];
			[qDocument removeID:gen];
			[self updateChangeCount:NSChangeDone];
		}
		//TODO: handle deleting top level object
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
