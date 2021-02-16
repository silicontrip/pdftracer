#import <Foundation/Foundation.h>
// I'd like to turn this into a class cluster
@interface ObjcQPDFObjectHandle : NSObject
{
// do not put c++ in the header
	NSArray<NSString*>* dictionaryKeys;
	NSArray<ObjcQPDFObjectHandle*>* objectArray;
}

-(instancetype)initWithString:(NSString*)def;
-(BOOL)isNull;
-(BOOL)isStream;
-(BOOL)isArray;
-(BOOL)isDictionary;
-(BOOL)isExpandable;
-(NSUInteger)count;

-(NSArray<NSString*>*)keys;
-(ObjcQPDFObjectHandle*)objectForKey:(NSString*)key;
-(ObjcQPDFObjectHandle*)objectAtIndex:(NSUInteger)index;
-(void)removeObjectForKey:(NSString*)key;
-(void)replaceObject:(ObjcQPDFObjectHandle*)obj forKey:(NSString*)key;
-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(ObjcQPDFObjectHandle*)obj;

-(NSData*)stream;
-(void)replaceStreamData:(NSString*)data;
-(NSString*)name;
-(NSString*)typeName;
-(NSString*)unparse;
-(NSString*)unparseResolved;
-(BOOL)childrenContainIndirects;
+ (ObjcQPDFObjectHandle*)newNull;

@end
