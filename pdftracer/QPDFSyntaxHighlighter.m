#import "QPDFSyntaxHighlighter.h"

/* https://unicode-org.github.io/icu/ */

@implementation QPDFSyntaxHighlighter

// It might be that this entire class is static...

// - (NSArray<NSTextCheckingResult *> *)matchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;

// or maybe not.
- (instancetype)init
{
	self = [super init];
	if (self)
	{
		NSError *error = NULL;

		// NSLog(@"lists: %@",[NSColorList availableColorLists]);
		//keywordColour = [NSColor colorWithCatalogName:@"Web Safe Colors" colorName:@"AA1188"];
		keywordColour = [[NSColor colorWithRed:0.698 green:0.094 blue:0.537 alpha:1] retain];

	//	NSColor* keywordColour = [[NSColor colorWithRed:0.698 green:0.094 blue:0.537 alpha:1] retain];
		NSColor* commentColour = [NSColor colorWithRed:0.255 green:0.714 blue:0.270 alpha:1];
	//	NSColor* hexColour = [NSColor colorWithRed:0.859 green:0.173 blue:0.220 alpha:1]; // red
		NSColor* realColour = [NSColor colorWithRed:0.6 green:0.8 blue:0.4 alpha:1]; // lime
		NSColor* hexColour = [NSColor colorWithRed:0.859 green:0.859 blue:0.173 alpha:1];
		NSColor* nameColour = [NSColor colorWithRed:0.776 green:0.463 blue:0.282 alpha:1];  // orange
		NSColor* encloseColour = [NSColor colorWithRed:0.898 green:0.827 blue:0.471 alpha:1]; // pale yellow 
		NSColor* stringColour = [NSColor colorWithRed:0 green:0.6 blue:0.8 alpha:1.0]; // cyan
		
		
//		NSString *whiteStart = @"(^|[\\s)\\]>])";
		NSString *cmdStart = @"(^|\\s|(?<=[>\\)\\]]))";
		NSString *cmdEnd = @"($|(?=[/<\\(\\[\\s]))";

		
		// NSString *argName = @"/\\w+";
		//NSString *argReal = @"[+-]?([0-9]*[.])?[0-9]+";
		NSString *stringRe = @"\\((\\\\\\)|[^\\)])*\\)";
		NSString *hexRe = @"<[0-9A-Fa-f]+>";
		NSString *arrayRe = @"\\[[^\\]]*\\]";
		NSString *dictRe = @"<<[^>]*>>";
		
		NSString *innerStringRe = @"(?<=\\()(\\\\\\)|[^\\)])*(?=\\))";
		NSString *innerHexRe = @"(?<=<)[0-9A-Fa-f]+(?=>)";
		NSString *innerArrayRe = @"(?<=\\[)[0-9A-Fa-f]+(?=\\])";
		NSString *nameRe = @"/\\w+";
		NSString *commentRe = @"%.*";
	//	NSString *nameRe = [NSString stringWithFormat:@"/\\w+%@",cmdEnd];

		//NSString *realRe = [NSString stringWithFormat:@"%@[+-]?([0-9]*[.])?[0-9]+%@",cmdStart,cmdEnd];
		NSString *realRe = @"[+-]?([0-9]*[.])?[0-9]+";

//		NSString *stringRe = [NSString stringWithFormat:@"%@",argString];
//		NSString *innerStringRe = [NSString stringWithFormat:@"%@",argInnerString];
//		NSString *arrayRe = [NSString stringWithFormat:@"%@",argArray];
//		NSString *hexRe = [NSString stringWithFormat:@"%@",argHex];
//		NSString *innerHexRe = [NSString stringWithFormat:@"%@",argInnerHex];
//		NSString *dictRe = [NSString stringWithFormat:@"%@",argDict];

		
		//NSString *dictRe = [NSString stringWithFormat:@"%@",argDict];

		// NSLog(@"%@",stringRe);
		
		// these are order dependent, migrate to NSArray
		
		colourre_arr = [@[
						  [NSRegularExpression regularExpressionWithPattern:stringRe options:0 error:&error],
						  [NSRegularExpression regularExpressionWithPattern:hexRe options:0 error:&error],
						  [NSRegularExpression regularExpressionWithPattern:arrayRe options:0 error:&error],
						  [NSRegularExpression regularExpressionWithPattern:dictRe options:0 error:&error],
						  [NSRegularExpression regularExpressionWithPattern:innerHexRe options:0 error:&error],
						  [NSRegularExpression regularExpressionWithPattern:realRe options:0 error:&error],
						  [NSRegularExpression regularExpressionWithPattern:nameRe options:0 error:&error],
						  [NSRegularExpression regularExpressionWithPattern:commentRe options:NSRegularExpressionAnchorsMatchLines error:&error],
						  [NSRegularExpression regularExpressionWithPattern:innerStringRe options:0 error:&error]
						 ] retain ] ;
		
		colour_arr = [@[
						encloseColour,
						encloseColour,
						encloseColour,
						encloseColour,
					    hexColour,
					    realColour,
					    nameColour,
						commentColour,
						stringColour
					   ] retain];
		/*
		colour_re = @{
					 [NSRegularExpression regularExpressionWithPattern:innerHexRe options:0 error:&error] : hexColour,
					 [NSRegularExpression regularExpressionWithPattern:innerStringRe options:0 error:&error] : stringColour,
					 [NSRegularExpression regularExpressionWithPattern:stringRe options:0 error:&error] : encloseColour,
					 [NSRegularExpression regularExpressionWithPattern:realRe options:0 error:&error] : realColour,
					 [NSRegularExpression regularExpressionWithPattern:nameRe options:0 error:&error] : nameColour,
					 [NSRegularExpression regularExpressionWithPattern:commentRe options:0 error:&error] : commentColour,
					 [NSRegularExpression regularExpressionWithPattern:hexRe options:0 error:&error] : encloseColour,
					 [NSRegularExpression regularExpressionWithPattern:arrayRe options:0 error:&error] : encloseColour,
					 [NSRegularExpression regularExpressionWithPattern:dictRe options:0 error:&error] : encloseColour,

		};
		 */
		
		//[colour_re retain];
		
		NSString *arg1Name = [NSString stringWithFormat:@"%@\\s+",nameRe];
		NSString *arg1Real = [NSString stringWithFormat:@"%@\\s+",realRe];
		NSString *arg1String = [NSString stringWithFormat:@"%@\\s*",stringRe];
		NSString *arg1Hex = [NSString stringWithFormat:@"%@\\s*",hexRe];

		NSString *arg1Array = [NSString stringWithFormat:@"%@\\s*",arrayRe];
		NSString *arg2Real = [NSString stringWithFormat:@"%@\\s+%@\\s+",realRe,realRe];
		NSString *arg2ArrayReal =[NSString stringWithFormat:@"%@\\s*%@\\s+",arrayRe,realRe];
		NSString *arg2NameDict = [NSString stringWithFormat:@"%@\\s*%@\\s*",nameRe,dictRe];
		NSString *arg2NameReal = [NSString stringWithFormat:@"%@\\s+%@\\s+",nameRe,realRe];
		NSString *arg3Real = [NSString stringWithFormat:@"%@\\s+%@\\s+%@\\s+",realRe,realRe,realRe];
		NSString *arg3RealString = [NSString stringWithFormat:@"%@\\s+%@\\s*%@\\s*",realRe,realRe,stringRe];
		NSString *arg4Real = [NSString stringWithFormat:@"%@\\s+%@\\s+%@\\s+%@\\s+",realRe,realRe,realRe,realRe];
		NSString *arg6Real = [NSString stringWithFormat:@"%@\\s+%@\\s+%@\\s+%@\\s+%@\\s+%@\\s+",realRe,realRe,realRe,realRe,realRe,realRe];

		NSString *arg134Real = [NSString stringWithFormat:@"(%@|%@\\s+%@\\s+%@|%@\\s+%@\\s+%@\\s+%@)\\s+",realRe,realRe,realRe,realRe,realRe,realRe,realRe,realRe];
		NSString *arg134RealOrName = [NSString stringWithFormat:@"((%@|%@\\s+%@\\s+%@|%@\\s+%@\\s+%@\\s+%@)|%@)\\s+", realRe,realRe,realRe,realRe,realRe,realRe,realRe,realRe,nameRe];

		NSDictionary <NSString*,
			NSArray<NSString*>*>* cmdDict = @{
									 cmdStart : @[
												@"B", @"b", @"B\\*", @"b\\*", @"BI", @"BT", @"BX",
												@"EI", @"EMC", @"ET", @"EX", @"F", @"f", @"f\\*",
												@"h", @"ID", @"n", @"Q", @"q", @"S", @"s",
												@"T\\*", @"W", @"W\\*"
											],
									 arg1Name : @[ @"BMC", @"CS", @"cs", @"Do",
												  @"gs", @"MP", @"ri", @"sh"
											 ],
									 arg1Real : @[ @"G", @"g", @"i", @"J", @"j", @"M",
												  @"Tc", @"TL", @"Tr", @"Ts",@"Tw",
												  @"Tz", @"w"],
									 arg1String : @[ @"Tj", @"'" ],
									 arg1Hex : @[ @"Tj", @"'" ],

									 arg1Array : @[ @"TJ" ],
									 arg2Real : @[ @"d0", @"l", @"m", @"TD", @"Td" ],
									 arg2ArrayReal : @[@"d"],
									 arg2NameDict : @[ @"BDC", @"DP"],
									 arg2NameReal : @[ @"Tf" ],
									 arg3Real : @[ @"RG", @"rg" ],
									 arg3RealString : @[ @"\""],  // seriously Adobe wtf?
									 arg4Real : @[  @"K", @"k", @"re", @"v", @"y" ],
									 arg6Real : @[ @"c", @"cm", @"d1", @"Tm" ],
									 arg134Real : @[ @"SC", @"sc" ],
									 arg134RealOrName : @[ @"SCN", @"scn" ]
									 };
		
		NSMutableArray<NSRegularExpression*>*pdfref = [[NSMutableArray alloc] initWithCapacity:32];
		// this keyword highlighter seems a bit pointless now
		for (NSUInteger lv = 0; lv < [cmdDict count]; ++lv)
		{
			NSString *argre = [[cmdDict allKeys] objectAtIndex:lv];
			NSArray<NSString*>* cmds = [cmdDict objectForKey:argre];
			for (NSUInteger cc=0; cc < [cmds count]; ++cc)
			{
				NSString * cmd = [cmds objectAtIndex:cc];
				NSString *regstr = [NSString stringWithFormat:@"%@%@%@",argre,cmd,cmdEnd];
				
				// NSLog(@"RE: %@",regstr);
				
				NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regstr
																					   options:NSRegularExpressionDotMatchesLineSeparators|NSRegularExpressionUseUnixLineSeparators
																						 error:&error];
				
				NSAssert(regex != nil, @"regex fail: %@",regstr);  // you code 'em, you fix 'em
				[pdfref addObject:regex];
			}
		}
		pdf_keyword_re = [pdfref copy];
		[pdfref autorelease];

		
	}
	return self;
}

- (void)textStorageDidProcessEditing:(NSNotification *)notification
{
	_theStorage = [notification object];
	_theLayout = [[_theStorage layoutManagers] firstObject];
	
	NSRange glyphRange = [self.theLayout glyphRangeForBoundingRect:self.theScroll.documentVisibleRect inTextContainer:self.theContainer];
	NSRange editedRange = [self.theLayout characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
	
	[self colouriseRange:editedRange];
	
}

-(void)colouriseAll
{
	NSRange area;
	area.location = 0;
	area.length = [[_theView string] length];
	/*
	NSLog(@"text length: %lu",[[_theView string] length]);
	NSLog(@"theview: %@",_theView);
	NSLog(@"Colorizing %lu characters",area.length);
	*/
//	area.length = [[_theStorage string] length];
	[self colouriseRange:area];
}

-(void)colouriseRange:(NSRange)editedRange
{
	//NSString* codeText = [_theStorage string];
	
	//NSString* codeText = [_theView string];
	//NSString *searchText = [codeText stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	
	NSString* searchText = [_theView string];
	
	NSArray<NSTextCheckingResult*>* matchbox;
	NSArray<NSTextCheckingResult*>* colourbox;

	for (NSRegularExpression *re in pdf_keyword_re)
	{
		matchbox = [re matchesInString:searchText
							   options:0
								 range:editedRange];
		
		for (NSTextCheckingResult* cr in matchbox)
		{
			NSRange fr = [cr range];
			
			// NSLog(@"colouring... %@ to %@",[searchText substringWithRange:fr],keywordColour);
			
			[_theView setTextColor:keywordColour range:fr];
			
		//	NSLog(@"range length: %lu",fr.length);
			
			for (NSUInteger av=0; av < [colourre_arr count]; ++av)
			{
				NSRegularExpression* hire = [colourre_arr objectAtIndex:av];
			//	NSLog(@"scanning %@ in %@",hire,[searchText substringWithRange:fr]);
				colourbox = [hire matchesInString:searchText
									   options:0
										 range:fr];
				
				NSColor * matchColour = [colour_arr objectAtIndex:av];
				for (NSTextCheckingResult* dr in colourbox)
				{
					NSRange gr = [dr range];
					[_theView setTextColor:matchColour range:gr];
				}
			}
		}
	}
//	[_theStorage endEditing];
}

@end
