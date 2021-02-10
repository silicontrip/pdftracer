#import <Foundation/Foundation.h>
// I'd like to turn this into a class cluster
@interface QPDFObjectHandleObjc : NSObject
{
// do not put c++ in the header
	NSArray<NSString*>* dictionaryKeys;
	NSArray<NSString*>* objectArray;
}

-(instancetype)initWithString:(NSString*)def;
-(BOOL)isNull;
-(BOOL)isStream;
-(BOOL)isArray;
-(BOOL)isDictionary;
-(BOOL)isExpandable;
-(NSUInteger)count;
-(NSArray<NSString*>*)keys;
-(QPDFObjectHandleObjc*)objectForKey:(NSString*)key;
-(QPDFObjectHandleObjc*)objectAtIndex:(NSUInteger)index;
-(void)removeObjectForKey:(NSString*)key;
-(void)replaceObject:(QPDFObjectHandleObjc*)obj ForKey:(NSString*)key;
-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(QPDFObjectHandleObjc*)obj;

-(void)replaceStreamData:(NSData*)data;
-(NSString*)name;
-(NSString*)typeName;
-(NSString*)unparse;
-(NSString*)unparseResolved;
-(BOOL)childrenContainIndirects;

@end
