#import <AppKit/AppKit.h>

@interface QPDFHelp : NSObject <NSUserInterfaceItemSearching>
{
  NSArray<NSString*>* pdf_command_set;
}

- (instancetype)init;
- (void)searchForItemsWithSearchString:(NSString *)searchString resultLimit:(NSInteger)resultLimit matchedItemHandler:(void (^)(NSArray *items))handleMatchedItems;
- (NSArray *)localizedTitlesForItem:(id)item;
- (void)performActionForItem:(id)item;

@end
