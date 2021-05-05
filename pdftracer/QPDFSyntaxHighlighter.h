#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "QPDFTextView.h"

@interface QPDFSyntaxHighlighter : NSObject
{
	NSArray <NSRegularExpression*> * pdf_keyword_re;
	NSArray <NSRegularExpression*>* colourre_arr;
	NSArray <NSColor*>* colour_arr;
	
	NSColor *keywordColour;  // talk about conflicting spelling :-P

}

@property (nonatomic,strong) QPDFTextView* asyncView;
/*
@property (nonatomic,strong) NSTextStorage* theStorage;
@property (nonatomic,strong) NSTextContainer* theContainer;
@property (nonatomic,strong) NSLayoutManager* theLayout;
@property (nonatomic,strong) NSScrollView* theScroll;
*/

- (instancetype)init;
- (void)colouriseRange:(NSRange)r;
- (void)colouriseAll;
- (void)colouriseRangeThenAll:(NSRange)r;
- (void)colouriseQueueString:(NSString*)searchText;
- (void)colouriseQueueString:(NSString*)searchText forRange:(NSRange)area;


@end
