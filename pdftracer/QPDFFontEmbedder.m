//  Font embedding utility for TrueType/OpenType fonts
//

#import "QPDFFontEmbedder.h"
#import "ObjcQPDF.h"
#import "ObjcQPDFObjectHandle.h"
#import <AppKit/AppKit.h>

@implementation QPDFFontEmbedder

+ (NSString*)embedFontFromFile:(NSString*)fontPath
                        inQPDF:(ObjcQPDF*)qpdf
                        toPage:(ObjcQPDFObjectHandle*)pageObj
                         error:(NSError**)error
{
	NSLog(@">>> [QPDFFontEmbedder] Loading font from: %@", fontPath);
	
	// Load font file data
	NSData* fontData = [NSData dataWithContentsOfFile:fontPath];
	if (!fontData) {
		if (error) {
			*error = [NSError errorWithDomain:@"QPDFErrorDomain" code:2
									 userInfo:@{NSLocalizedDescriptionKey: @"Could not read font file"}];
		}
		return nil;
	}
	
	// Load font from file by temporarily registering it
	NSURL *fontURL = [NSURL fileURLWithPath:fontPath];
	
	// Register the font temporarily to get access to it
	CFErrorRef cfError = NULL;
	BOOL registered = CTFontManagerRegisterFontsForURL((CFURLRef)fontURL, kCTFontManagerScopeProcess, &cfError);
	
	if (!registered) {
		NSLog(@">>> [QPDFFontEmbedder] Failed to register font: %@", cfError ? (__bridge NSError *)cfError : @"Unknown error");
		if (cfError) CFRelease(cfError);
		// Try to continue anyway - font might already be registered
	}
	
	// Create font descriptor from the font data
	CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)fontData);
	CGFontRef cgFont = CGFontCreateWithDataProvider(dataProvider);
	CGDataProviderRelease(dataProvider);
	
	if (!cgFont) {
		if (error) {
			*error = [NSError errorWithDomain:@"QPDFErrorDomain" code:3
									 userInfo:@{NSLocalizedDescriptionKey: @"Invalid font file - could not create CGFont"}];
		}
		CTFontManagerUnregisterFontsForURL((CFURLRef)fontURL, kCTFontManagerScopeProcess, NULL);
		return nil;
	}
	
	// Get font name from CGFont
	CFStringRef cgFontName = CGFontCopyPostScriptName(cgFont);
	NSString *fontName = (__bridge_transfer NSString *)cgFontName;
	
	// Create NSFont using the font name
	NSFont *font = [NSFont fontWithName:fontName size:1000.0];
	
	if (!font) {
		NSLog(@">>> [QPDFFontEmbedder] Could not create NSFont with name: %@", fontName);
		if (error) {
			*error = [NSError errorWithDomain:@"QPDFErrorDomain" code:4
									 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Could not create font with name: %@", fontName]}];
		}
		CGFontRelease(cgFont);
		CTFontManagerUnregisterFontsForURL((CFURLRef)fontURL, kCTFontManagerScopeProcess, NULL);
		return nil;
	}
	
	NSLog(@">>> [QPDFFontEmbedder] Successfully loaded font: %@", fontName);
	
	// Extract font metrics (fontName already extracted from CGFont above)
	NSString *displayName = [font displayName];
	CGFloat ascender = [font ascender];
	CGFloat descender = [font descender];
	CGFloat capHeight = [font capHeight];
	NSRect bbox = [font boundingRectForFont];
	NSFontSymbolicTraits traits = [[font fontDescriptor] symbolicTraits];
	
	NSLog(@">>> [QPDFFontEmbedder] Font: %@ (%@)", fontName, displayName);
	NSLog(@">>> [QPDFFontEmbedder] Ascender: %.2f, Descender: %.2f, CapHeight: %.2f", ascender, descender, capHeight);
	
	// Calculate font flags
	int flags = 0;
	if (traits & NSFontItalicTrait) flags |= (1 << 6);  // Italic
	if (traits & NSFontBoldTrait) flags |= (1 << 18);   // ForceBold
	flags |= (1 << 5);  // Nonsymbolic (assume standard encoding)
	
	// Extract character widths for characters 32-255
	NSMutableArray *widths = [NSMutableArray arrayWithCapacity:224];
	for (int i = 32; i <= 255; i++) {
		NSString *charStr = [NSString stringWithFormat:@"%c", (char)i];
		NSDictionary *attrs = @{NSFontAttributeName: font};
		NSSize size = [charStr sizeWithAttributes:attrs];
		
		// Width in PDF units (already at 1000 units since we created font at size 1000)
		int width = (int)size.width;
		[widths addObject:@(width)];
	}
	
	// Get or create Resources dictionary
	ObjcQPDFObjectHandle* pageResource = [pageObj objectForKey:@"/Resources"];
	if (pageResource == nil)
		pageResource = [ObjcQPDFObjectHandle dictionaryObject];
	
	// Get or create Font dictionary
	ObjcQPDFObjectHandle* fontResource = [pageResource objectForKey:@"/Font"];
	if (fontResource == nil)
		fontResource = [ObjcQPDFObjectHandle dictionaryObject];
	
	// Generate unique font name (F1, F2, etc.)
	NSString *fontResourceName = nil;
	int fontIndex = 1;
	do {
		fontResourceName = [NSString stringWithFormat:@"/F%d", fontIndex++];
	} while ([fontResource objectForKey:fontResourceName] != nil);
	
	NSLog(@">>> [QPDFFontEmbedder] Using resource name: %@", fontResourceName);
	
	// Create FontDescriptor
	ObjcQPDFObjectHandle* fontDescriptor = [ObjcQPDFObjectHandle newDictionary];
	[fontDescriptor replaceObject:[ObjcQPDFObjectHandle nameWith:@"/FontDescriptor"] forKey:@"/Type"];
	[fontDescriptor replaceObject:[ObjcQPDFObjectHandle nameWith:[NSString stringWithFormat:@"/%@", fontName]] forKey:@"/FontName"];
	[fontDescriptor replaceObject:[ObjcQPDFObjectHandle newInteger:flags] forKey:@"/Flags"];
	
	// FontBBox
	ObjcQPDFObjectHandle* bboxArray = [ObjcQPDFObjectHandle newArray];
	[bboxArray addObject:[ObjcQPDFObjectHandle newInteger:(int)bbox.origin.x]];
	[bboxArray addObject:[ObjcQPDFObjectHandle newInteger:(int)bbox.origin.y]];
	[bboxArray addObject:[ObjcQPDFObjectHandle newInteger:(int)(bbox.origin.x + bbox.size.width)]];
	[bboxArray addObject:[ObjcQPDFObjectHandle newInteger:(int)(bbox.origin.y + bbox.size.height)]];
	[fontDescriptor replaceObject:bboxArray forKey:@"/FontBBox"];
	[bboxArray autorelease];
	
	[fontDescriptor replaceObject:[ObjcQPDFObjectHandle newInteger:0] forKey:@"/ItalicAngle"];
	[fontDescriptor replaceObject:[ObjcQPDFObjectHandle newInteger:(int)ascender] forKey:@"/Ascent"];
	[fontDescriptor replaceObject:[ObjcQPDFObjectHandle newInteger:(int)descender] forKey:@"/Descent"];
	[fontDescriptor replaceObject:[ObjcQPDFObjectHandle newInteger:(int)capHeight] forKey:@"/CapHeight"];
	[fontDescriptor replaceObject:[ObjcQPDFObjectHandle newInteger:80] forKey:@"/StemV"];  // Approximate
	
	// Create FontFile2 stream with font data
	ObjcQPDFObjectHandle* fontFileStream = [ObjcQPDFObjectHandle newStreamForQPDF:qpdf];
	[fontFileStream replaceStreamData:fontData filter:nil];
	ObjcQPDFObjectHandle* streamDict = [fontFileStream streamDictionary];
	[streamDict replaceObject:[ObjcQPDFObjectHandle newInteger:(int)[fontData length]] forKey:@"/Length1"];
	
	[fontDescriptor replaceObject:fontFileStream forKey:@"/FontFile2"];
	[fontFileStream autorelease];
	
	// Create Font dictionary
	ObjcQPDFObjectHandle* fontDict = [ObjcQPDFObjectHandle newDictionary];
	[fontDict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/Font"] forKey:@"/Type"];
	[fontDict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/TrueType"] forKey:@"/Subtype"];
	[fontDict replaceObject:[ObjcQPDFObjectHandle nameWith:[NSString stringWithFormat:@"/%@", fontName]] forKey:@"/BaseFont"];
	[fontDict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/WinAnsiEncoding"] forKey:@"/Encoding"];
	[fontDict replaceObject:[ObjcQPDFObjectHandle newInteger:32] forKey:@"/FirstChar"];
	[fontDict replaceObject:[ObjcQPDFObjectHandle newInteger:255] forKey:@"/LastChar"];
	
	// Create widths array
	ObjcQPDFObjectHandle* widthsArray = [ObjcQPDFObjectHandle newArray];
	for (NSNumber *width in widths) {
		[widthsArray addObject:[ObjcQPDFObjectHandle newInteger:[width intValue]]];
	}
	[fontDict replaceObject:widthsArray forKey:@"/Widths"];
	[widthsArray autorelease];
	
	[fontDict replaceObject:fontDescriptor forKey:@"/FontDescriptor"];
	[fontDescriptor autorelease];
	
	// Add font to resources
	[fontResource replaceObject:fontDict forKey:fontResourceName];
	[fontDict autorelease];
	
	[pageResource replaceObject:fontResource forKey:@"/Font"];
	[pageObj replaceObject:pageResource forKey:@"/Resources"];
	
	NSLog(@">>> [QPDFFontEmbedder] Font embedded successfully as %@", fontResourceName);
	return fontResourceName;
}

+ (NSString*)embedSystemFont:(NSFont*)font
                      inQPDF:(ObjcQPDF*)qpdf
                      toPage:(ObjcQPDFObjectHandle*)pageObj
                       error:(NSError**)error
{
	NSLog(@">>> [QPDFFontEmbedder] Embedding system font: %@", [font fontName]);
	
	if (!font) {
		if (error) {
			*error = [NSError errorWithDomain:@"QPDFErrorDomain" code:1
									 userInfo:@{NSLocalizedDescriptionKey: @"Font is nil"}];
		}
		return nil;
	}
	
	// Get font data - we need to find the font file
	// For system fonts, we can get the URL from the font descriptor
	NSFontDescriptor *descriptor = [font fontDescriptor];
	NSURL *fontURL = [descriptor objectForKey:(__bridge NSString *)kCTFontURLAttribute];
	
	if (!fontURL) {
		NSLog(@">>> [QPDFFontEmbedder] Could not get font URL, trying alternative method");
		// Try to get font data another way - this is a fallback
		if (error) {
			*error = [NSError errorWithDomain:@"QPDFErrorDomain" code:2
									 userInfo:@{NSLocalizedDescriptionKey: @"Could not locate system font file"}];
		}
		return nil;
	}
	
	// Load font file data
	NSData* fontData = [NSData dataWithContentsOfURL:fontURL];
	if (!fontData) {
		if (error) {
			*error = [NSError errorWithDomain:@"QPDFErrorDomain" code:3
									 userInfo:@{NSLocalizedDescriptionKey: @"Could not read font file"}];
		}
		return nil;
	}
	
	NSLog(@">>> [QPDFFontEmbedder] Loaded font data: %lu bytes from %@", (unsigned long)[fontData length], fontURL);
	
	// Extract font metrics directly from the NSFont object
	NSString *fontName = [font fontName];
	NSString *displayName = [font displayName];
	CGFloat ascender = [font ascender];
	CGFloat descender = [font descender];
	CGFloat capHeight = [font capHeight];
	NSRect bbox = [font boundingRectForFont];
	NSFontSymbolicTraits traits = [descriptor symbolicTraits];
	
	NSLog(@">>> [QPDFFontEmbedder] Font: %@ (%@)", fontName, displayName);
	NSLog(@">>> [QPDFFontEmbedder] Ascender: %.2f, Descender: %.2f, CapHeight: %.2f", ascender, descender, capHeight);
	
	// Calculate font flags
	int flags = 0;
	if (traits & NSFontItalicTrait) flags |= (1 << 6);  // Italic
	if (traits & NSFontBoldTrait) flags |= (1 << 18);   // ForceBold
	flags |= (1 << 5);  // Nonsymbolic (assume standard encoding)
	
	// Extract character widths for characters 32-255
	// Use the font at size 1000 for easy PDF unit conversion
	NSFont *scaledFont = [NSFont fontWithName:fontName size:1000.0];
	if (!scaledFont) scaledFont = font;  // Fallback
	
	NSMutableArray *widths = [NSMutableArray arrayWithCapacity:224];
	for (int i = 32; i <= 255; i++) {
		NSString *charStr = [NSString stringWithFormat:@"%c", (char)i];
		NSDictionary *attrs = @{NSFontAttributeName: scaledFont};
		NSSize size = [charStr sizeWithAttributes:attrs];
		
		// Width in PDF units
		int width = (int)size.width;
		[widths addObject:@(width)];
	}
	
	// Get or create Resources dictionary
	ObjcQPDFObjectHandle* pageResource = [pageObj objectForKey:@"/Resources"];
	if (pageResource == nil)
		pageResource = [ObjcQPDFObjectHandle dictionaryObject];
	
	// Get or create Font dictionary
	ObjcQPDFObjectHandle* fontResource = [pageResource objectForKey:@"/Font"];
	if (fontResource == nil)
		fontResource = [ObjcQPDFObjectHandle dictionaryObject];
	
	// Generate unique font name (F1, F2, etc.)
	NSString *fontResourceName = nil;
	int fontIndex = 1;
	do {
		fontResourceName = [NSString stringWithFormat:@"/F%d", fontIndex++];
	} while ([fontResource objectForKey:fontResourceName] != nil);
	
	NSLog(@">>> [QPDFFontEmbedder] Using resource name: %@", fontResourceName);
	
	// Create FontDescriptor
	ObjcQPDFObjectHandle* fontDescriptor = [ObjcQPDFObjectHandle newDictionary];
	[fontDescriptor replaceObject:[ObjcQPDFObjectHandle nameWith:@"/FontDescriptor"] forKey:@"/Type"];
	[fontDescriptor replaceObject:[ObjcQPDFObjectHandle nameWith:[NSString stringWithFormat:@"/%@", fontName]] forKey:@"/FontName"];
	[fontDescriptor replaceObject:[ObjcQPDFObjectHandle newInteger:flags] forKey:@"/Flags"];
	
	// FontBBox
	ObjcQPDFObjectHandle* bboxArray = [ObjcQPDFObjectHandle newArray];
	[bboxArray addObject:[ObjcQPDFObjectHandle newInteger:(int)bbox.origin.x]];
	[bboxArray addObject:[ObjcQPDFObjectHandle newInteger:(int)bbox.origin.y]];
	[bboxArray addObject:[ObjcQPDFObjectHandle newInteger:(int)(bbox.origin.x + bbox.size.width)]];
	[bboxArray addObject:[ObjcQPDFObjectHandle newInteger:(int)(bbox.origin.y + bbox.size.height)]];
	[fontDescriptor replaceObject:bboxArray forKey:@"/FontBBox"];
	[bboxArray autorelease];
	
	[fontDescriptor replaceObject:[ObjcQPDFObjectHandle newInteger:0] forKey:@"/ItalicAngle"];
	[fontDescriptor replaceObject:[ObjcQPDFObjectHandle newInteger:(int)ascender] forKey:@"/Ascent"];
	[fontDescriptor replaceObject:[ObjcQPDFObjectHandle newInteger:(int)descender] forKey:@"/Descent"];
	[fontDescriptor replaceObject:[ObjcQPDFObjectHandle newInteger:(int)capHeight] forKey:@"/CapHeight"];
	[fontDescriptor replaceObject:[ObjcQPDFObjectHandle newInteger:80] forKey:@"/StemV"];  // Approximate
	
	// Create FontFile2 stream with font data
	ObjcQPDFObjectHandle* fontFileStream = [ObjcQPDFObjectHandle newStreamForQPDF:qpdf];
	[fontFileStream replaceStreamData:fontData filter:nil];
	ObjcQPDFObjectHandle* streamDict = [fontFileStream streamDictionary];
	[streamDict replaceObject:[ObjcQPDFObjectHandle newInteger:(int)[fontData length]] forKey:@"/Length1"];
	
	[fontDescriptor replaceObject:fontFileStream forKey:@"/FontFile2"];
	[fontFileStream autorelease];
	
	// Create Font dictionary
	ObjcQPDFObjectHandle* fontDict = [ObjcQPDFObjectHandle newDictionary];
	[fontDict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/Font"] forKey:@"/Type"];
	[fontDict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/TrueType"] forKey:@"/Subtype"];
	[fontDict replaceObject:[ObjcQPDFObjectHandle nameWith:[NSString stringWithFormat:@"/%@", fontName]] forKey:@"/BaseFont"];
	[fontDict replaceObject:[ObjcQPDFObjectHandle nameWith:@"/WinAnsiEncoding"] forKey:@"/Encoding"];
	[fontDict replaceObject:[ObjcQPDFObjectHandle newInteger:32] forKey:@"/FirstChar"];
	[fontDict replaceObject:[ObjcQPDFObjectHandle newInteger:255] forKey:@"/LastChar"];
	
	// Create widths array
	ObjcQPDFObjectHandle* widthsArray = [ObjcQPDFObjectHandle newArray];
	for (NSNumber *width in widths) {
		[widthsArray addObject:[ObjcQPDFObjectHandle newInteger:[width intValue]]];
	}
	[fontDict replaceObject:widthsArray forKey:@"/Widths"];
	[widthsArray autorelease];
	
	[fontDict replaceObject:fontDescriptor forKey:@"/FontDescriptor"];
	[fontDescriptor autorelease];
	
	// Add font to resources
	[fontResource replaceObject:fontDict forKey:fontResourceName];
	[fontDict autorelease];
	
	[pageResource replaceObject:fontResource forKey:@"/Font"];
	[pageObj replaceObject:pageResource forKey:@"/Resources"];
	
	NSLog(@">>> [QPDFFontEmbedder] System font embedded successfully as %@", fontResourceName);
	return fontResourceName;
}

@end
