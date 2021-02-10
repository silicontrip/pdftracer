#import <Foundation/Foundation.h>

@interface Arguments : NSObject {
@private
	NSDictionary <NSString*, NSString*> *options;
	NSArray<NSString*>*arguments;
}

+ (instancetype)argumentsWithCount:(int)argc values:(char*const*)argv;
+ (instancetype)argumentsWithOptions:(NSString*)arg count:(int)argc values:(char*const*)argv; //replaces the others
+ (id)argumentsWithArgOptions:(NSString*)arg Count:(int)argc Values:(char*const*)argv;
-(id) initWithArgOptions:(NSString *)arg Count:(int)argc Values:(char*const*)argv;

- (NSUInteger)countOptions;
- (NSUInteger)countArguments;
- (NSUInteger)countPositionalArguments;
- (NSString*)positionalArgumentAt:(NSUInteger)i;
- (NSString*)argumentAt:(NSUInteger)i; 
- (NSString*)stringFor:(NSString*)arg;
- (BOOL)hasOption:(NSString*)opt;
- (NSUInteger)count;

@end
