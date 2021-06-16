#import <Foundation/Foundation.h>
#import "ObjcPDFObject.h"

// I'd like to turn this into a class cluster

@class ObjcQPDF;

enum object_type_e {
	// Object types internal to qpdf
	ot_uninitialized,
	ot_reserved,
	// Object types that can occur in the main document
	ot_null,
	ot_boolean,
	ot_integer,
	ot_real,
	ot_string,
	ot_name,
	ot_array,
	ot_dictionary,
	ot_stream,
	// Additional object types that can occur in content streams
	ot_operator,
	ot_inlineimage,
};

typedef enum object_type_e object_type_e;

// The Foundation way...


typedef NS_ENUM(NSInteger, QPDFObjectType) {
 	QPDFObjectTypeUninitialized = 0,
 	QPDFObjectTypeReserved = 1,
 	QPDFObjectTypeNull = 2
};

// err but not right now, but wait there's more

@interface ObjcQPDFObjectHandle : NSObject<ObjcPDFObject>
{
// do not put c++ in the header
	NSArray<NSString*>* dictionaryKeys;
	NSArray<ObjcQPDFObjectHandle*>* objectArray;
}

// these only make sense when they are attached to a PDF structure
@property (nonatomic,assign) ObjcQPDFObjectHandle* parent;
@property (nonatomic,strong) NSString* elementName;

-(instancetype)initWithString:(NSString*)def;
-(BOOL)isNull;
-(BOOL)isStream;
-(BOOL)isArray;
-(BOOL)isDictionary;
-(BOOL)isExpandable;
-(BOOL)isIndirect;
-(BOOL)isName;
-(BOOL)isPage;

-(NSUInteger)count;
-(object_type_e)type;

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
- (NSString*)text;

-(BOOL)childrenContainIndirects;

+ (ObjcQPDFObjectHandle*)nullObject;
+ (ObjcQPDFObjectHandle*)boolWith:(BOOL)b;
+ (ObjcQPDFObjectHandle*)intWith:(NSInteger)b;
+ (ObjcQPDFObjectHandle*)realWith:(double)b;
+ (ObjcQPDFObjectHandle*)stringWith:(NSString*)b;
+ (ObjcQPDFObjectHandle*)nameWith:(NSString*)b;
+ (ObjcQPDFObjectHandle*)arrayObject;
+ (ObjcQPDFObjectHandle*)arrayWithArray:(NSArray<ObjcQPDFObjectHandle*>*)array;
+ (ObjcQPDFObjectHandle*)arrayWithRectangle:(CGRect)rect;
+ (ObjcQPDFObjectHandle*)arrayWithMatrix:(CGAffineTransform)matrix;
+ (ObjcQPDFObjectHandle*)dictionaryObject;
+ (ObjcQPDFObjectHandle*)dictionaryWithDictionary:(NSDictionary<NSString*,ObjcQPDFObjectHandle*>*)dict;

// too many news
+ (ObjcQPDFObjectHandle*)newNull;
+ (ObjcQPDFObjectHandle*)newBool:(BOOL)b;
+ (ObjcQPDFObjectHandle*)newInteger:(NSInteger)i;
+ (ObjcQPDFObjectHandle*)newReal:(double)n;
+ (ObjcQPDFObjectHandle*)newString:(NSString*)s;
+ (ObjcQPDFObjectHandle*)newName:(NSString*)s;
+ (ObjcQPDFObjectHandle*)newArray;
+ (ObjcQPDFObjectHandle*)newArrayWithArray:(NSArray<ObjcQPDFObjectHandle*>*)array;
+ (ObjcQPDFObjectHandle*)newArrayWithRectangle:(CGRect)rect;
+ (ObjcQPDFObjectHandle*)newArrayWithMatrix:(CGAffineTransform)matrix;
+ (ObjcQPDFObjectHandle*)newDictionary;
+ (ObjcQPDFObjectHandle*)newDictionaryWithDictionary:(NSDictionary<NSString*,ObjcQPDFObjectHandle*>*)dict;

+ (ObjcQPDFObjectHandle*)newStreamForQPDF:(ObjcQPDF*)qpdf;
+ (ObjcQPDFObjectHandle*)newStreamForQPDF:(ObjcQPDF*)qpdf withData:(NSData*)data;
+ (ObjcQPDFObjectHandle*)newStreamForQPDF:(ObjcQPDF*)qpdf withString:(NSString*)data;
+ (ObjcQPDFObjectHandle*)newIndirect:(NSString*)objGen for:(ObjcQPDF*)qpdf;



@end
