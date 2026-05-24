//
//  QPDFFontEmbedder.h
//  pdftracer
//
//  Font embedding utility for TrueType/OpenType fonts
//

#import <Foundation/Foundation.h>

@class ObjcQPDF;
@class ObjcQPDFObjectHandle;
@class NSFont;

@interface QPDFFontEmbedder : NSObject

/**
 * Embed a TrueType or OpenType font from a file into a PDF page.
 * 
 * @param fontPath Path to .ttf or .otf font file
 * @param qpdf QPDF document object
 * @param pageObj Page object to add font to
 * @param error Error pointer for failure details
 * @return Font resource name (e.g., "/F1") on success, nil on failure
 */
+ (NSString*)embedFontFromFile:(NSString*)fontPath
                        inQPDF:(ObjcQPDF*)qpdf
                        toPage:(ObjcQPDFObjectHandle*)pageObj
                         error:(NSError**)error;

/**
 * Embed a system font (NSFont) directly into a PDF page.
 * 
 * @param font NSFont object to embed
 * @param qpdf QPDF document object
 * @param pageObj Page object to add font to
 * @param error Error pointer for failure details
 * @return Font resource name (e.g., "/F1") on success, nil on failure
 */
+ (NSString*)embedSystemFont:(NSFont*)font
                      inQPDF:(ObjcQPDF*)qpdf
                      toPage:(ObjcQPDFObjectHandle*)pageObj
                       error:(NSError**)error;

@end
