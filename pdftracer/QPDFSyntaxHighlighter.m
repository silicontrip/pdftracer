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
	//	NSColor* commentColour = [NSColor colorWithRed:0.255 green:0.714 blue:0.270 alpha:1];
		NSColor* hexColour = [NSColor colorWithRed:0.859 green:0.173 blue:0.220 alpha:1];
		NSColor* stringColour = [NSColor colorWithRed:0.6 green:0.8 blue:0.4 alpha:1];
	//	NSColor* hexColour = [NSColor colorWithRed:0.859 green:0.859 blue:0.173 alpha:1];
		NSColor* nameColour = [NSColor colorWithRed:0.776 green:0.463 blue:0.282 alpha:1];
		NSColor* realColour = [NSColor colorWithRed:0.471 green:0.427 blue:0.769 alpha:1];

		NSString *argName = @"/\\w+";
		NSString *argReal = @"[+-]?([0-9]*[.])?[0-9]+";
		NSString *argString = @"\\((\\\\\\)|[^\\)])*\\)";
		NSString *argHex = @"<[0-9A-F]+>";
		NSString *argArray = @"\\[[^\\]]*\\]";
		NSString *argDict = @"<<[^>]*>>";
		
		NSString *cmdStart = @"(^|\\s+)";
		NSString *cmdEnd = @"($|(?=\\s+))";
		
		NSString *nameRe = [NSString stringWithFormat:@"%@%@%@",cmdStart,argName,cmdEnd];
		NSString *realRe = [NSString stringWithFormat:@"%@%@%@",cmdStart,argReal,cmdEnd];
		NSString *stringRe = [NSString stringWithFormat:@"%@",argString];
		NSString *arrayRe = [NSString stringWithFormat:@"%@",argArray];
		NSString *hexRe = [NSString stringWithFormat:@"%@",argHex];

		NSString *dictRe = [NSString stringWithFormat:@"%@",argDict];

		// NSLog(@"%@",stringRe);
		
		colour_re = @{
			[NSRegularExpression regularExpressionWithPattern:hexRe options:0 error:&error] : hexColour,
			[NSRegularExpression regularExpressionWithPattern:arrayRe options:0 error:&error] : realColour,
			[NSRegularExpression regularExpressionWithPattern:realRe options:0 error:&error] : realColour,
			[NSRegularExpression regularExpressionWithPattern:nameRe options:0 error:&error] : nameColour,
			[NSRegularExpression regularExpressionWithPattern:stringRe options:0 error:&error] : stringColour,
//					  [NSRegularExpression regularExpressionWithPattern:dictRe options:0 error:&error] : dictColour,
		};
		
		[colour_re retain];
		
		NSString *arg1Name = [NSString stringWithFormat:@"%@\\s+",argName];
		NSString *arg1Real = [NSString stringWithFormat:@"%@\\s+",argReal];
		NSString *arg1String = [NSString stringWithFormat:@"%@\\s*",argString];
		NSString *arg1Hex = [NSString stringWithFormat:@"%@\\s*",argHex];

		NSString *arg1Array = [NSString stringWithFormat:@"%@\\s*",argArray];
		NSString *arg2Real = [NSString stringWithFormat:@"%@\\s+%@\\s+",argReal,argReal];
		NSString *arg2NameDict = [NSString stringWithFormat:@"%@\\s+%@\\s+",argName,argDict];
		NSString *arg2NameReal = [NSString stringWithFormat:@"%@\\s+%@\\s+",argName,argReal];
		NSString *arg3Real = [NSString stringWithFormat:@"%@\\s+%@\\s+%@\\s+",argReal,argReal,argReal];
		NSString *arg3RealString = [NSString stringWithFormat:@"%@\\s+%@\\s*%@\\s*",argReal,argReal,argString];
		NSString *arg4Real = [NSString stringWithFormat:@"%@\\s+%@\\s+%@\\s+%@\\s+",argReal,argReal,argReal,argReal];
		NSString *arg6Real = [NSString stringWithFormat:@"%@\\s+%@\\s+%@\\s+%@\\s+%@\\s+%@\\s+",argReal,argReal,argReal,argReal,argReal,argReal];

		NSString *arg134Real = [NSString stringWithFormat:@"(%@|%@\\s+%@\\s+%@|%@\\s+%@\\s+%@\\s+%@)\\s+",argReal,argReal,argReal,argReal,argReal,argReal,argReal,argReal];
		NSString *arg134RealOrName = [NSString stringWithFormat:@"((%@|%@\\s+%@\\s+%@|%@\\s+%@\\s+%@\\s+%@)|%@)\\s+",argReal,argReal,argReal,argReal,argReal,argReal,argReal,argReal,argName];

		NSDictionary <NSString*,
			NSArray<NSString*>*>* cmdDict = @{
									 @"" : @[
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
									 arg2Real : @[ @"d", @"d0", @"l", @"m", @"TD", @"Td" ],
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
				NSString *regstr = [NSString stringWithFormat:@"%@%@%@%@",cmdStart,argre,cmd,cmdEnd];
				NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regstr
																					   options:NSRegularExpressionDotMatchesLineSeparators|NSRegularExpressionUseUnixLineSeparators
																						 error:&error];
				NSAssert(regex != nil, @"regex fail: %@",regstr);
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
	area.length = [[_theStorage string] length];
	[self colouriseRange:area];
}

-(void)colouriseRange:(NSRange)editedRange
{
	NSString* codeText = [_theStorage string];
	NSString *searchText = [codeText stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	
//	[_theStorage beginEditing];
	// remove the old colors

	//[_theStorage removeAttribute:NSForegroundColorAttributeName range:editedRange];
	
	NSDictionary* attrib = @{
							 NSForegroundColorAttributeName: [NSColor whiteColor]
							 };
	[_theStorage setAttributes:attrib range:editedRange];
	
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
			
			[_theStorage addAttribute:NSForegroundColorAttributeName
								value:keywordColour
								range:fr];
			
		//	NSLog(@"range length: %lu",fr.length);
			
			for (NSUInteger av=0; av < [colour_re count]; ++av)
			{
				NSRegularExpression* hire = [[colour_re allKeys] objectAtIndex:av];
		//	NSLog(@"scanning %@ in %@",hire,[searchText substringWithRange:fr]);
				colourbox = [hire matchesInString:searchText
									   options:0
										 range:fr];
				
				NSColor * matchColour = [colour_re objectForKey:hire];
				for (NSTextCheckingResult* dr in colourbox)
				{
					NSRange gr = [dr range];
					// NSLog(@"%@ -> %lu-%lu %@",hire,gr.location,(gr.location+gr.length),[searchText substringWithRange:gr]);
					// NSLog(@"match colour: %@",matchColour);

					[_theStorage addAttribute:NSForegroundColorAttributeName
										value:matchColour
										range:gr];
				}
			}
		}

	}
//	[_theStorage endEditing];
}

@end
