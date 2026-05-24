#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "QPDFTextView.h"

@interface QPDFSyntaxHighlighter : NSObject
{
	NSArray* pdf_keyword_re;
	NSArray* colourre_arr;
	NSArray* colour_arr;
	NSColor* keywordColour;
	QPDFTextView* _asyncView;
	BOOL _shouldCancel;  // Flag to abort in-progress colorization

}

@property (nonatomic,strong) QPDFTextView* asyncView;
/*
@property (nonatomic,strong) NSTextStorage* theStorage;
@property (nonatomic,strong) NSTextContainer* theContainer;
@property (nonatomic,strong) NSLayoutManager* theLayout;
@property (nonatomic,strong) NSScrollView* theScroll;
*/

- (instancetype)init;
- (void)cancelColorization;
- (void)colouriseRange:(NSRange)r;
- (void)colouriseAll;
- (void)colouriseRangeThenAll:(NSRange)r;
// - (void)colouriseQueueString:(NSString*)searchText;
- (void)colouriseQueueString:(NSString*)searchText forRange:(NSRange)area;


@end
