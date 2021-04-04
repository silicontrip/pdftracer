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
		// NSLog(@"lists: %@",[NSColorList availableColorLists]);
		//keywordColour = [NSColor colorWithCatalogName:@"Web Safe Colors" colorName:@"AA1188"];
		keywordColour = [[NSColor colorWithRed:0.698 green:0.094 blue:0.537 alpha:1] retain];
		NSLog(@"keyword: %@",keywordColour);
					//	 + (NSColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
		
		NSArray <NSString*> * pdf_command_set = @[
			@"\\s+B\\s+",
			@"\\s+b\\s+",
			@"\\s+B\\*\\s+",
			@"\\s+b\\*\\s+",
			@"\\s+BI\\s+",
			@"\\s+BT\\s+",
			@"\\s+BX\\s+",
			@"\\s+EI\\s+",
			@"\\s+EMC\\s+",
			@"\\s+ET\\s+",
			@"\\s+EX\\s+",
			@"\\s+F\\s+",
			@"\\s+f\\s+",
			@"\\s+f\\*\\s+",
			@"\\s+h\\s+",
			@"\\s+ID\\s+",
			@"\\s+n\\s+",
			@"\\s+Q\\s+",
			@"\\s+q\\s+",
			@"\\s+S\\s+",
			@"\\s+s\\s+",
			@"\\s+T\\*\\s+",
			@"\\s+W\\s+",
			@"\\s+W\\*\\s+",
			@"[\\s\\n]+-?[\\.0-9]+[\\s\\n]+-?[\\.0-9]+[\\s\\n]+-?[\\.0-9]+[\\s\\n]+-?[\\.0-9]+[\\s\\n]+-?[\\.0-9]+[\\s\\n]+-?[\\.0-9]+\\s+c\\s+",
			@"/\\w+\\s+BMC\\s+",
			@"/\\w+\\s+CS\\s+",
			@"/\\w+\\s+cs\\s+",
			@"/\\w+\\s+Do\\s+",
			@"/\\w+\\s+gs\\s+",
			@"/\\w+\\s+MP\\s+",
			@"/\\w+\\s+ri\\s+",
			@"/\\w+\\s+sh\\s+",
			@"\\s+-?[\\.0-9]+\\s+G\\s+",
			@"\\s+-?[\\.0-9]+\\s+g\\s+",
			@"\\s+-?[\\.0-9]+\\s+i\\s+",
			@"\\s+-?[\\.0-9]+\\s+J\\s+",
			@"\\s+-?[\\.0-9]+\\s+j\\s+",
			@"\\s+-?[\\.0-9]+\\s+M\\s+",
			@"\\s+-?[\\.0-9]+\\s+Tc\\s+",
			@"\\s+-?[\\.0-9]+\\s+TL\\s+",
			@"\\s+-?[\\.0-9]+\\s+Tr\\s+",
			@"\\s+-?[\\.0-9]+\\s+Ts\\s+",
			@"\\s+-?[\\.0-9]+\\s+Tw\\s+",
			@"\\s+-?[\\.0-9]+\\s+Tz\\s+",
			@"\\s+-?[\\.0-9]+\\s+w\\s+"

		];

		// make regexp array

		NSMutableArray<NSRegularExpression*>*pdfref = [[NSMutableArray alloc] initWithCapacity:[pdf_command_set count]];
		
		NSError *error = NULL;
		for (NSString * regstr in pdf_command_set)
		{
			NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regstr
																				   options:NSRegularExpressionDotMatchesLineSeparators|NSRegularExpressionUseUnixLineSeparators
																					 error:&error];
			[pdfref addObject:regex];
		}
		pdf_keyword_re = [pdfref copy];
	}
	return self;
}

- (void)textStorageDidProcessEditing:(NSNotification *)notification
{
	NSTextStorage *textStorage = [notification object];
	//NSColor *blue = [NSColor blueColor]; // prefs
	NSRange area;
	NSString *codeText = [textStorage string];
	NSUInteger length = [codeText length];

	
	NSString *searchText = [codeText stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	
	 NSLog(@"%@",searchText);
	
//	for (NSInteger i = 0 ; i < [codeText length]; ++i)
//		if (*(charText+1) == 10) *(charText+i)=32;
	
	// determine onscreen range
	// remove the old colors
	area.location = 0;
	area.length = length;

	[textStorage removeAttribute:NSForegroundColorAttributeName range:area];

	
	
	NSArray<NSTextCheckingResult*>* matchbox;
	for (NSRegularExpression *re in pdf_keyword_re)
	{
				matchbox = [re matchesInString:searchText
							   options:0
								 range:area];
		
		for (NSTextCheckingResult* cr in matchbox)
		{
			NSRange fr = [cr range];
			// if([cr range])
			NSLog(@"%@ -> %lu-%lu %@",re,fr.location,(fr.location+fr.length),[searchText substringWithRange:fr]);
		//	NSLog(@"colour: %@",keywordColour);
			
		//	NSLog(@"check result: %@",NSStringFromRange([cr range]));
			
				[textStorage addAttribute:NSForegroundColorAttributeName
								value:keywordColour
								range:[cr range]];
		}

	}


}

@end
