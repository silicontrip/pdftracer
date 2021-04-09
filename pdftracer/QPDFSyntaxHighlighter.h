#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface QPDFSyntaxHighlighter : NSObject
{
	// NSArray <NSString*> * pdf_command_set;
	NSArray <NSRegularExpression*> * pdf_keyword_re;
	// NSArray <NSRegularExpression*> * pdf_comment_re;
	//NSArray <NSRegularExpression*> * pdf_string_re;
	//NSArray <NSRegularExpression*> * pdf_hex_re;
	//NSArray <NSRegularExpression*> * pdf_name_re;
	
	NSArray <NSRegularExpression*>* colourre_arr;
	NSArray <NSColor*>* colour_arr;
	
	// NSDictionary <NSRegularExpression*,NSColor*>* colour_re;
	NSColor *keywordColour;  // talk about conflicting spelling :-P
	/*
	NSColor *commentColour;
	NSColor *stringColour;
	NSColor *hexColour;
	NSColor* nameColour;
	NSColor* argumentColour;  // but everything other than a keyword is an argument
	*/
}

@property (nonatomic,strong) NSTextView* theView;
@property (nonatomic,strong) NSTextStorage* theStorage;
@property (nonatomic,strong) NSTextContainer* theContainer;
@property (nonatomic,strong) NSLayoutManager* theLayout;
@property (nonatomic,strong) NSScrollView* theScroll;

- (instancetype)init;
- (void)textStorageDidProcessEditing:(NSNotification *)notification;
- (void)colouriseRange:(NSRange)r;
- (void)colouriseAll;

@end
