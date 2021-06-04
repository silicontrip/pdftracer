#import "QPDFSyntaxHighlighter.h"

/* https://unicode-org.github.io/icu/ */

@interface Colourise : NSObject
{
}

@property (nonatomic,strong) NSColor* colour;
@property (assign) NSRange range;

@end

@implementation Colourise

@synthesize colour;
@synthesize range;

- (void)dealloc
{
	[self.colour release];
	[super dealloc];
}


@end

@implementation QPDFSyntaxHighlighter

// It might be that this entire class is static...  oh you wish.

// 15 seconds after last text edit, full screen highlight is performed.

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
		// NSString *innerArrayRe = @"(?<=\\[)[0-9A-Fa-f]+(?=\\])";
		NSString *nameRe = @"/\\w+";
		NSString *commentRe = @"%.*";
	//	NSString *nameRe = [NSString stringWithFormat:@"/\\w+%@",cmdEnd];

	//	NSLog(@"init syntax: %@",commentRe);
		
		//NSString *realRe = [NSString stringWithFormat:@"%@[+-]?([0-9]*[.])?[0-9]+%@",cmdStart,cmdEnd];
		NSString *realRe = @"[+-]?([0-9]*[.])?[0-9]+";

		
		//NSString *dictRe = [NSString stringWithFormat:@"%@",argDict];

		// NSLog(@"%@",stringRe);
		
		// these are order dependent, migrate to NSArray [Done]
		
		colourre_arr = [@[
						  [NSRegularExpression regularExpressionWithPattern:stringRe options:0 error:&error],
						  [NSRegularExpression regularExpressionWithPattern:hexRe options:0 error:&error],
						  [NSRegularExpression regularExpressionWithPattern:arrayRe options:0 error:&error],
						  [NSRegularExpression regularExpressionWithPattern:dictRe options:0 error:&error],
						  [NSRegularExpression regularExpressionWithPattern:innerHexRe options:0 error:&error],
						  [NSRegularExpression regularExpressionWithPattern:realRe options:0 error:&error],
						  [NSRegularExpression regularExpressionWithPattern:nameRe options:0 error:&error],
						  [NSRegularExpression regularExpressionWithPattern:commentRe options:0 error:&error],
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

- (void)colouriseAll
{
	NSString* storageString = [[_asyncView textStorage] string];
	NSRange all = NSMakeRange(0, [storageString length]);

	NSAssert((storageString != nil), @" colourise all storage string null");
	
	// this async queue is not the cause of the crash but I'm leaving it out for the moment
	
	// dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ [self colouriseQueueString:storageString forRange:all]; } );
	
	[self colouriseQueueString:storageString forRange:all]; // is the dispatch_async the cause of all this crashing
	
}

- (void)colouriseRange:(NSRange)r
{
	// NSLog(@"%@",[NSThread callStackSymbols]);
	NSString* storageString = [[_asyncView textStorage] string];
	NSAssert((storageString != nil), @" colourise all storage string null");
	
	// dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ [self colouriseQueueString:storageString forRange:r]; } );
	
	[self colouriseQueueString:storageString forRange:r];
}

// hoping this one works better and doesn't crash.
- (void)colouriseRangeThenAll:(NSRange)viewRange
{
	NSString* storageString = [[_asyncView textStorage] string];
	NSRange all = NSMakeRange(0, [storageString length]);

	NSAssert((storageString != nil), @" colourise all storage string null");
	/*
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self colouriseQueueString:storageString forRange:viewRange];
		[self colouriseQueueString:storageString forRange:all];
	} );
	*/
	[self colouriseQueueString:storageString forRange:viewRange];
	[self colouriseQueueString:storageString forRange:all];
	
}

/*
-(void)colouriseQueueString:(NSString*)s
{

	NSRange area;
	area.location = 0;
	area.length = [s length];

	[self colouriseQueueString:s forRange:area];
}
*/

-(void)colouriseQueueString:(NSString*)searchText forRange:(NSRange)area
{
	NSAssert(searchText!=nil,@"searchText nil");
	
	NSMutableArray<Colourise*>* colourInstruct = [NSMutableArray arrayWithCapacity:16];
	
	NSArray<NSTextCheckingResult*>* matchbox;
	NSArray<NSTextCheckingResult*>* colourbox;
	
	for (NSRegularExpression *re in pdf_keyword_re)
	{
		matchbox = [re matchesInString:searchText
							   options:0
								 range:area];
		
		for (NSTextCheckingResult* cr in matchbox)
		{
//			[_theView setTextColor:keywordColour range:fr];
	
			NSRange fr = [cr range];
			Colourise* thisColour = [[Colourise new] autorelease];
			thisColour.colour = keywordColour;
			thisColour.range = fr;
			
			[colourInstruct addObject:thisColour];
			
			
			for (NSUInteger av=0; av < [colourre_arr count]; ++av)
			{
				NSRegularExpression* hire = [colourre_arr objectAtIndex:av];

				colourbox = [hire matchesInString:searchText
										  options:0
											range:fr];
				
				NSColor * matchColour = [colour_arr objectAtIndex:av];
				for (NSTextCheckingResult* dr in colourbox)
				{

					Colourise* moreColour = [[Colourise new] autorelease];
					moreColour.colour = matchColour;
					moreColour.range =  [dr range];

					[colourInstruct addObject:moreColour];

					// [_theView setTextColor:matchColour range:gr];
				}
			}
		}
	}
	
	//NSRegularExpression* commentRe;
	NSError* error;
	NSRegularExpression* commentRe=[NSRegularExpression regularExpressionWithPattern:@"%.*" options:0 error:&error];
	
	NSArray<NSTextCheckingResult*>* commentBox = [commentRe matchesInString:searchText
																	options:0
																	  range:area];
	
	//NSColor * matchColour = [colour_arr objectAtIndex:6];
	// NSColor* commentColour = [NSColor colorWithRed:0.255 green:0.714 blue:0.270 alpha:1];  // settings settings settings
	
	
	for (NSTextCheckingResult* dr in commentBox)
	{
		//		NSRange gr = [dr range];
		
		Colourise* commentColour = [[Colourise new] autorelease];
		commentColour.colour =  [NSColor colorWithRed:0.255 green:0.714 blue:0.270 alpha:1];  // settings settings settings;
		commentColour.range =  [dr range];
		
		[colourInstruct addObject:commentColour];
		
		//[_theView setTextColor:commentColour range:[dr range]];
	}
	
	// this should be much faster than the Regex search
	// but unfortunately not enough.
	
	//I don't care how you do it, as long as its not a complete muppet
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[_asyncView.textStorage beginEditing];
		for (Colourise* cr in colourInstruct)
		{
			[_asyncView setTextColor:cr.colour range:cr.range];  // well just, but too slow that it's unsettlingly noticable
		}
		[_asyncView.textStorage endEditing];
	});


}

// toying with the idea of using NSScanner
// but not anymore
/*
- (void)scanStreamString:(NSString *)s
{
	NSScanner* sc = [[NSScanner alloc] initWithString:s] ;
	// whitespaceAndNewlineCharacterSet
	sc.charactersToBeSkipped =[NSCharacterSet whitespaceAndNewlineCharacterSet];
	sc.caseSensitive = YES;
	

}
*/

@end
