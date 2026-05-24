//
//  QPDFDocument.m
//  pdftracer
//
//  Created by Mark Heath on 28/1/21.
//  Copyright © 2021 silicontrip. All rights reserved.
//

#import "QPDFDocument.h"
#import <CoreText/CoreText.h>

#import "OutlineQPDF.h"
#import "OutlineQPDFPage.h"
#import "OutlineQPDFObj.h"
#import "QPDFWindowController.h"
#import "ObjcQPDF.h"
#import "QPDFFontEmbedder.h"

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

- (ObjcQPDFObjectHandle*)createCalRGBColorSpace
{
	// [/CalRGB << /WhitePoint [0.9505 1.0 1.089] >>]
	ObjcQPDFObjectHandle* array = [ObjcQPDFObjectHandle newArray];
	[array addObject:[ObjcQPDFObjectHandle nameWith:@"/CalRGB"]];
	
	ObjcQPDFObjectHandle* dict = [ObjcQPDFObjectHandle newDictionary];
	ObjcQPDFObjectHandle* whitePoint = [ObjcQPDFObjectHandle newArray];
	[whitePoint addObject:[ObjcQPDFObjectHandle newReal:0.9505]];
	[whitePoint addObject:[ObjcQPDFObjectHandle newReal:1.0]];
	[whitePoint addObject:[ObjcQPDFObjectHandle newReal:1.089]];
	[dict replaceObject:whitePoint forKey:@"/WhitePoint"];
	
	[array addObject:dict];
	return [array autorelease];
}

- (ObjcQPDFObjectHandle*)createCalGrayColorSpace
{
	// [/CalGray << /WhitePoint [0.9505 1.0 1.089] >>]
	ObjcQPDFObjectHandle* array = [ObjcQPDFObjectHandle newArray];
	[array addObject:[ObjcQPDFObjectHandle nameWith:@"/CalGray"]];
	
	ObjcQPDFObjectHandle* dict = [ObjcQPDFObjectHandle newDictionary];
	ObjcQPDFObjectHandle* whitePoint = [ObjcQPDFObjectHandle newArray];
	[whitePoint addObject:[ObjcQPDFObjectHandle newReal:0.9505]];
	[whitePoint addObject:[ObjcQPDFObjectHandle newReal:1.0]];
	[whitePoint addObject:[ObjcQPDFObjectHandle newReal:1.089]];
	[dict replaceObject:whitePoint forKey:@"/WhitePoint"];
	
	[array addObject:dict];
	return [array autorelease];
}

- (void)addColorSpace:(NSInteger)colorSpaceType toPage:(NSInteger)pageNumber
{
	ObjcQPDFObjectHandle* pageObj = [qDocument pageAtIndex:pageNumber];
	if (pageObj != nil)
	{
		// Get or create Resources dictionary
		ObjcQPDFObjectHandle* pageResource = [pageObj objectForKey:@"/Resources"];
		if (pageResource == nil)
			pageResource = [ObjcQPDFObjectHandle dictionaryObject];
		
		// Get or create ColorSpace dictionary
		ObjcQPDFObjectHandle* csResource = [pageResource objectForKey:@"/ColorSpace"];
		if (csResource == nil)
			csResource = [ObjcQPDFObjectHandle dictionaryObject];
		
		// Create ColorSpace object based on type
		ObjcQPDFObjectHandle* csObj = nil;
		switch (colorSpaceType) {
			case 0: // DeviceRGB
				csObj = [ObjcQPDFObjectHandle nameWith:@"/DeviceRGB"];
				break;
			case 1: // DeviceCMYK
				csObj = [ObjcQPDFObjectHandle nameWith:@"/DeviceCMYK"];
				break;
			case 2: // DeviceGray
				csObj = [ObjcQPDFObjectHandle nameWith:@"/DeviceGray"];
				break;
			case 3: // CalRGB
				csObj = [self createCalRGBColorSpace];
				break;
			case 4: // CalGray
				csObj = [self createCalGrayColorSpace];
				break;
		}
		
		if (csObj) {
			[QPDFDocument addObject:csObj to:csResource];
			[pageResource replaceObject:csResource forKey:@"/ColorSpace"];
			[pageObj replaceObject:pageResource forKey:@"/Resources"];
		}
	}
}

- (void)addExtGState:(NSInteger)extGStateType toPage:(NSInteger)pageNumber
{
	ObjcQPDFObjectHandle* pageObj = [qDocument pageAtIndex:pageNumber];
	if (pageObj != nil)
	{
		// Get or create Resources dictionary
		ObjcQPDFObjectHandle* pageResource = [pageObj objectForKey:@"/Resources"];
		if (pageResource == nil)
			pageResource = [ObjcQPDFObjectHandle dictionaryObject];
		
		// Get or create ExtGState dictionary
		ObjcQPDFObjectHandle* gsResource = [pageResource objectForKey:@"/ExtGState"];
		if (gsResource == nil)
			gsResource = [ObjcQPDFObjectHandle dictionaryObject];
		
		// Create ExtGState dictionary
		ObjcQPDFObjectHandle* gsDict = [ObjcQPDFObjectHandle newDictionary];
		[gsDict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/ExtGState"] forKey:@"/Type"];
		
		switch (extGStateType) {
			case 0: // Multiply
				[gsDict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/Multiply"] forKey:@"/BM"];
				break;
			case 1: // Screen
				[gsDict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/Screen"] forKey:@"/BM"];
				break;
			case 2: // Overlay
				[gsDict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/Overlay"] forKey:@"/BM"];
				break;
			case 3: // Darken
				[gsDict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/Darken"] forKey:@"/BM"];
				break;
			case 4: // Lighten
				[gsDict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/Lighten"] forKey:@"/BM"];
				break;
			case 5: // 50% Opacity
				[gsDict replaceObject:[ObjcQPDFObjectHandle newReal:0.5] forKey:@"/ca"];
				[gsDict replaceObject:[ObjcQPDFObjectHandle newReal:0.5] forKey:@"/CA"];
				break;
			case 6: // 75% Opacity
				[gsDict replaceObject:[ObjcQPDFObjectHandle newReal:0.75] forKey:@"/ca"];
				[gsDict replaceObject:[ObjcQPDFObjectHandle newReal:0.75] forKey:@"/CA"];
				break;
			case 7: // 25% Opacity
				[gsDict replaceObject:[ObjcQPDFObjectHandle newReal:0.25] forKey:@"/ca"];
				[gsDict replaceObject:[ObjcQPDFObjectHandle newReal:0.25] forKey:@"/CA"];
				break;
			case 8: // Multiply + 50% Opacity
				[gsDict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/Multiply"] forKey:@"/BM"];
				[gsDict replaceObject:[ObjcQPDFObjectHandle newReal:0.5] forKey:@"/ca"];
				[gsDict replaceObject:[ObjcQPDFObjectHandle newReal:0.5] forKey:@"/CA"];
				break;
		}
		
		[QPDFDocument addObject:gsDict to:gsResource];
		[pageResource replaceObject:gsResource forKey:@"/ExtGState"];
		[pageObj replaceObject:pageResource forKey:@"/Resources"];
		[gsDict autorelease];
	}
}

- (BOOL)addFontFromFile:(NSString*)fontPath toPage:(NSInteger)pageNumber error:(NSError**)error
{
	ObjcQPDFObjectHandle* pageObj = [qDocument pageAtIndex:pageNumber];
	if (pageObj == nil) {
		if (error) {
			*error = [NSError errorWithDomain:@"QPDFErrorDomain" code:1 
									 userInfo:@{NSLocalizedDescriptionKey: @"Invalid page number"}];
		}
		return NO;
	}
	
	NSString *fontName = [QPDFFontEmbedder embedFontFromFile:fontPath 
													  inQPDF:qDocument 
													  toPage:pageObj 
													   error:error];
	return (fontName != nil);
}

- (BOOL)addSystemFont:(NSFont*)font toPage:(NSInteger)pageNumber error:(NSError**)error
{
	ObjcQPDFObjectHandle* pageObj = [qDocument pageAtIndex:pageNumber];
	if (pageObj == nil) {
		if (error) {
			*error = [NSError errorWithDomain:@"QPDFErrorDomain" code:1 
									 userInfo:@{NSLocalizedDescriptionKey: @"Invalid page number"}];
		}
		return NO;
	}
	
	NSString *fontName = [QPDFFontEmbedder embedSystemFont:font 
													 inQPDF:qDocument 
													 toPage:pageObj 
													  error:error];
	return (fontName != nil);
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
		
		NSInteger width = [rep pixelsWide];
		NSInteger height = [rep pixelsHigh];
		NSInteger bitsPerComponent = [rep bitsPerSample];
		NSInteger samplesPerPixel = [rep samplesPerPixel];
		
		// Check if it's a JPEG file (pass through as-is)
		BOOL isJPEG = NO;
		if (fileData.length > 2) {
			const uint8_t *bytes = (const uint8_t*)fileData.bytes;
			if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
				isJPEG = YES;
			}
		}

		ObjcQPDFObjectHandle* imageStream = [ObjcQPDFObjectHandle newStreamForQPDF:qDocument];
		ObjcQPDFObjectHandle* dict = [imageStream streamDictionary];

		if (isJPEG) {
			// JPEG Pass-through: Set data directly, set filter manually
			NSLog(@">>> Inserting JPEG image (pass-through): %ldx%ld", (long)width, (long)height);
			[imageStream replaceStreamData:fileData filter:nil];
			[dict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/DCTDecode"] forKey:@"/Filter"];
		} else {
			// PNG/TIFF: Extract raw bitmap data - QPDF will auto-compress with Flate
			NSLog(@">>> Inserting lossless image: %ldx%ld, %ld bpc, %ld spp", 
				  (long)width, (long)height, (long)bitsPerComponent, (long)samplesPerPixel);
			
			// Check if the bitmap is planar (not supported by PDF directly)
			BOOL isPlanar = [rep isPlanar];
			NSLog(@">>> Bitmap format - Planar: %d, BytesPerRow: %ld, BitsPerPixel: %ld", 
				  isPlanar, (long)[rep bytesPerRow], (long)[rep bitsPerPixel]);
			
			if (isPlanar) {
				NSLog(@">>> ERROR: Planar images not supported");
				[imageStream autorelease];
				return;
			}
			
			// Get raw bitmap data
			unsigned char *bitmapData = [rep bitmapData];
			if (!bitmapData) {
				NSLog(@">>> ERROR: Could not get bitmap data");
				[imageStream autorelease];
				return;
			}
			
			// Determine the actual color space and samples per pixel
			NSInteger actualSamplesPerPixel = samplesPerPixel;
			NSString *colorSpace = @"/DeviceRGB";
			BOOL hasAlpha = [rep hasAlpha];
			
			NSLog(@">>> Has alpha: %d", hasAlpha);
			
			// PDF expects RGB (3 samples) or Gray (1 sample) without alpha
			// If we have alpha, we need to strip it or handle it separately
			NSData *rawData = nil;
			
			if (samplesPerPixel == 1) {
				// Grayscale - use as-is
				colorSpace = @"/DeviceGray";
				NSInteger bytesPerRow = [rep bytesPerRow];
				NSInteger dataSize = bytesPerRow * height;
				rawData = [NSData dataWithBytes:bitmapData length:dataSize];
				actualSamplesPerPixel = 1;
			} else if (samplesPerPixel == 3) {
				// RGB without alpha - use as-is
				colorSpace = @"/DeviceRGB";
				NSInteger bytesPerRow = [rep bytesPerRow];
				NSInteger dataSize = bytesPerRow * height;
				rawData = [NSData dataWithBytes:bitmapData length:dataSize];
				actualSamplesPerPixel = 3;
			} else if (samplesPerPixel == 4 && hasAlpha) {
				// RGBA - need to strip alpha channel
				NSLog(@">>> Stripping alpha channel from RGBA image");
				colorSpace = @"/DeviceRGB";
				actualSamplesPerPixel = 3;
				
				NSMutableData *rgbData = [NSMutableData dataWithCapacity:width * height * 3];
				NSInteger bytesPerRow = [rep bytesPerRow];
				
				for (NSInteger y = 0; y < height; y++) {
					unsigned char *rowPtr = bitmapData + (y * bytesPerRow);
					for (NSInteger x = 0; x < width; x++) {
						unsigned char *pixel = rowPtr + (x * 4);
						// Copy RGB, skip A
						[rgbData appendBytes:pixel length:3];
					}
				}
				rawData = rgbData;
			} else {
				// Unsupported format - try to convert
				NSLog(@">>> WARNING: Unusual pixel format (%ld spp), attempting conversion", (long)samplesPerPixel);
				colorSpace = @"/DeviceRGB";
				actualSamplesPerPixel = 3;
				
				// Use NSBitmapImageRep to convert to standard RGB
				NSBitmapImageRep *rgbRep = [[NSBitmapImageRep alloc] 
					initWithBitmapDataPlanes:NULL
					pixelsWide:width
					pixelsHigh:height
					bitsPerSample:8
					samplesPerPixel:3
					hasAlpha:NO
					isPlanar:NO
					colorSpaceName:NSDeviceRGBColorSpace
					bytesPerRow:width * 3
					bitsPerPixel:24];
				
				// Draw the original image into the new representation
				[NSGraphicsContext saveGraphicsState];
				NSGraphicsContext *ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep:rgbRep];
				[NSGraphicsContext setCurrentContext:ctx];
				[rep drawInRect:NSMakeRect(0, 0, width, height)];
				[NSGraphicsContext restoreGraphicsState];
				
				rawData = [NSData dataWithBytes:[rgbRep bitmapData] length:width * height * 3];
				[rgbRep release];
			}
			
			NSLog(@">>> Final data size: %lu bytes for %ldx%ld image (%@ colorspace)", 
				  (unsigned long)[rawData length], (long)width, (long)height, colorSpace);
			
			// Pass raw uncompressed data with NO filter
			// QPDF will automatically compress it with FlateDecode when writing the PDF
			[imageStream replaceStreamData:rawData filter:nil];
			
			// Update samples per pixel for the actual data we're storing
			samplesPerPixel = actualSamplesPerPixel;
			
			// Set the color space
			[dict replaceObject:[ObjcQPDFObjectHandle nameWith:colorSpace] forKey:@"/ColorSpace"];
		}
		
		// Set image dictionary properties
		[dict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/XObject"] forKey:@"/Type"];
		[dict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/Image"] forKey:@"/Subtype"];
		[dict replaceObject:[ObjcQPDFObjectHandle newInteger:width] forKey:@"/Width"];
		[dict replaceObject:[ObjcQPDFObjectHandle newInteger:height] forKey:@"/Height"];
		[dict replaceObject:[ObjcQPDFObjectHandle newInteger:bitsPerComponent] forKey:@"/BitsPerComponent"];
		
		// ColorSpace is already set in the conditional logic above for non-JPEG images
		// For JPEG, set it here
		if (isJPEG) {
			[dict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/DeviceRGB"] forKey:@"/ColorSpace"];
		}
		
		// Add to page resources
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
		
		NSLog(@">>> Image inserted successfully");
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
	
	// Note: /ProcSet is deprecated as of PDF 1.4 and has been removed
	
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
