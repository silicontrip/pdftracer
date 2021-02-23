#import "QPDFHelp.h"

@implementation QPDFHelp


- (instancetype)init
{
	self = [super init];
	if (self)
	{
		pdf_command_set = @[
							@"b   : closepath, fill, stroke : CGContextClosePath,CGContextStrokePath,CGContextFillPath",
							@"B   : fill, stroke : CGContextStrokePath,CGContextFillPath",
							@"b*  : closepath, eofill, stroke : CGContextEOFillPath",
							@"BDC : begin marked content sequence with plist",
							@"BI  : begin inline image",
							@"BMC : begin marked content sequence",
							@"BT  : begin text",
							@"BX  : begin compatibility",
							@"c   : curveto : CGContextAddCurveToPoint",
							@"cm  : concat : CGContextConcatCTM",
							@"CS  : setcolorspace (stroking) : CGContextSetStrokeColorSpace",
							@"cs  : setcolorspace (non-stroking) : CGContextSetFillColorSpace",
							@"d   : setdash : CGContextSetLineDash",
							@"d0  : setcharwidth :",
							@"d1  : setcachedevice :",
							@"Do  : invoke XObject : (CGContextDrawImage)",
							@"DP  : define marked content point :",
							@"EI  : end inline image",
							@"EMC : end marked content point",
							@"ET  : end text",
							@"EX  : end compatibility section",
							@"f   : fill : CGContextFillPath",
							@"F   : fill : deprecated",
							@"f*  : eorill : CGContextEOFillPath",
							@"G   : setgray : CGContextSetGrayStrokeColor",
							@"g   : setgray (non-stroke) : CGContextSetGrayFillColor",
							@"gs  : set graphic state parameters /resource",
							@"h   : closepath : CGContextClosePath",
							@"i   : setflat : CGContextSetFlatness",
							@"ID  : begin inline image data :",
							@"j   : setlinejoin : CGContextSetLineJoin ",
							@"J   : setlinecap : CGContextSetLineCap",
							@"K   : setcmykcolor (stroking) :",
							@"k   : setcmykcolor (non-stroking) : ",
							@"l   : lineto : CGContextAddLineToPoint",
							@"m   : moveto : CGContextMoveToPoint",
							@"M   : setmiterlimit : CGContextSetMiterLimit",
							@"MP  : define marked-content point",
							@"n   : end path : (CGContextBeginPath)",
							@"q   : gsave : CGContextSaveGState",
							@"Q   : grestore : CGContextRestoreGState",
							@"re  : add rectangle : CGContextAddRect / CGContextAddRects",
							@"RG  : setrgbcolor (stroke) : CGContextSetRGBStrokeColor",
							@"rg  : setrgbcolor (non-stroking) : CGContextSetRGBFillColor",
							@"ri  : colour rendering intent : CGContextSetRenderingIntent",
							@"s   : closepath, stroke : CGContextClosePath,CGContextStrokePath",
							@"S   : stroke : CGContextStrokePath",
							@"SC  : setcolor (stroke) : CGContextSetStrokeColor",
							@"sc  : setcolor (non-stroke) : CGContextSetFillColor",
							@"SCN : setcolor (stroke, ICC) : CGColorSpaceCreateICCBased",
							@"scn : setcolor (non-stroke, ICC) :",
							@"sh  : shfill :",
							@"T*  : move to start of next text line :",
							@"Tc  : set character spacing : CGContextSetCharacterSpacing",
							@"Td  : move text position : CGContextSetTextPosition",
							@"TD  : move text and set leading :",
							@"Tf  : selectfont : CGContextSelectFont",
							@"Tj  : show : CGContextShowText",
							@"TJ  : show with glyph positioning : CGContextShowGlyphsAtPositions",
							@"TL  : set text leading :",
							@"Tm  : set text matrix : CGContextSetTextMatrix",
							@"Tr  : set text rendering intent :",
							@"Ts  : set text rise :",
							@"Tw  : set word spacing :",
							@"Tz  : set horizontal text scaling :",
							@"v   : curveto (initial point duped) :",
							@"w   : setlinewidth : CGContextSetLineWidth",
							@"W   : clip : CGContextClip",
							@"W*  : eoclip : CGContextEOClip",
							@"y   : curveto (final point duped) :",
							@"'   : moveto next text line, show :",
							@"\"   : set word and character spacing, move to next line, show :"
							];
	}
	return self;
}

- (void)searchForItemsWithSearchString:(NSString *)searchString resultLimit:(NSInteger)resultLimit matchedItemHandler:(void (^)(NSArray *items))handleMatchedItems
{
	NSInteger matchCount = 0;
   // handleMatchedItems(@[searchString]);
	NSMutableArray* results = [NSMutableArray arrayWithCapacity:8];
	
	for (NSString* quickHelp in pdf_command_set)
	{
		if ([quickHelp rangeOfString:searchString].location != NSNotFound) {
			matchCount ++;
			[results addObject:quickHelp];
		}
		if (matchCount == resultLimit)
		{
			handleMatchedItems(results);
			return;
		}
	}
	handleMatchedItems(results);
}

- (NSArray *)localizedTitlesForItem:(id)item
{
	return @[(NSString*)item];
   // return @[[NSString stringWithFormat:@"Search for '%@' on my website", [item description]]];
}

- (void)performActionForItem:(id)item
{
	// templates
    // Open your custom url assuming item is actually searchString
}

@end
