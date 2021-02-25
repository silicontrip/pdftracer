#import <Foundation/Foundation.h>
#import "ObjcPDFObject.h"

// I'd like to turn this into a class cluster

@class ObjcQPDF;

@interface ObjcQPDFObjectHandle : NSObject<ObjcPDFObject>
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
-(BOOL)isIndirect;
-(NSUInteger)count;

-(ObjcQPDF*)owner;

-(NSArray<NSString*>*)keys;
-(NSArray<ObjcQPDFObjectHandle*>*)array;
-(ObjcQPDFObjectHandle*)objectForKey:(NSString*)key;
-(ObjcQPDFObjectHandle*)objectAtIndex:(NSUInteger)index;
-(ObjcQPDFObjectHandle*)streamDictionary;
-(void)removeObjectForKey:(NSString*)key;
-(void)removeObjectAtIndex:(int)index;
-(void)replaceObject:(ObjcQPDFObjectHandle*)obj forKey:(NSString*)key;
-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(ObjcQPDFObjectHandle*)obj;
-(void)addObject:(ObjcQPDFObjectHandle*)obj;
//-(void)removeID:(NSString*)objGen;

-(NSData*)stream;
-(void)replaceStreamData:(NSString*)data;
-(NSString*)name;
-(NSString*)typeName;
-(NSString*)unparse;
-(NSString*)unparseResolved;
-(NSString*)objectGenerationID;

-(BOOL)childrenContainIndirects;

+ (ObjcQPDFObjectHandle*)newNull;


@end
