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
	QPDFObjectTypeNull = 2,
	QPDFObjectTypeBoolean = 3,
	QPDFObjectTypeInteger = 4,
	QPDFObjectTypeReal = 5,
	QPDFObjectTypeString = 6,
	QPDFObjectTypeName = 7,
	QPDFObjectTypeArray = 8,
	QPDFObjectTypeDictionary = 9,
	QPDFObjectTypeStream = 10,
	QPDFObjectTypeOperator = 11,
	QPDFObjectTypeInlineImage = 12
};

// err but not right now, but wait there's more

@interface ObjcQPDFObjectHandle : NSObject<ObjcPDFObject>
{
// do not put c++ in the header
	NSArray<NSString*>* dictionaryKeys;
	NSArray<ObjcQPDFObjectHandle*>* objectArray;
}

// these only make sense when they are attached to a PDF structure
@property (nonatomic,assign) ObjcQPDFObjectHandle* _Nullable parent;
@property (nonatomic,strong) NSString* _Nullable elementName;

- (void)addObject:(ObjcQPDFObjectHandle* _Nonnull)obj;
- (NSArray<ObjcQPDFObjectHandle*>* _Nonnull)array;
+ (ObjcQPDFObjectHandle* _Nonnull)arrayObject;
+ (ObjcQPDFObjectHandle* _Nonnull)arrayWithArray:(NSArray<ObjcQPDFObjectHandle*>* _Nonnull)array;
+ (ObjcQPDFObjectHandle* _Nonnull)arrayWithMatrix:(CGAffineTransform)matrix;
+ (ObjcQPDFObjectHandle* _Nonnull)arrayWithRectangle:(CGRect)rect;
// + (NSArray<ObjcQPDFObjectHandle*>*)arrayWithVector:(std::vector<QPDFObjectHandle>)vec
+ (ObjcQPDFObjectHandle* _Nonnull)boolWith:(BOOL)b;
- (BOOL)childrenContainIndirects;
- (NSUInteger)count;
- (NSString* _Nonnull)description;
+ (ObjcQPDFObjectHandle* _Nonnull)dictionaryObject;
- (NSString* _Nullable)dictionaryType;
+ (ObjcQPDFObjectHandle* _Nonnull)dictionaryWithDictionary:(NSDictionary<NSString*,ObjcQPDFObjectHandle*>* _Nonnull)dict;
// - (instancetype)initWithObject:(QPDFObjectHandle)obj
- (instancetype _Nullable)initWithString:(NSString* _Nonnull)def;
+ (ObjcQPDFObjectHandle* _Nonnull)intWith:(NSInteger)b;
- (BOOL)isArray;
- (BOOL)isDictionary;
- (BOOL)isExpandable;
- (BOOL)isIndirect;
- (BOOL)isName;
- (BOOL)isNull;
- (BOOL)isPage;
- (BOOL)isStream;
- (NSArray<NSString*>* _Nonnull)keys;
- (NSString* _Nonnull)name;
+ (ObjcQPDFObjectHandle* _Nonnull)nameWith:(NSString* _Nonnull)b;
+ (ObjcQPDFObjectHandle* _Nonnull)newArray;
+ (ObjcQPDFObjectHandle* _Nonnull)newArrayWithArray:(NSArray<ObjcQPDFObjectHandle*>* _Nonnull)array;
+ (ObjcQPDFObjectHandle* _Nonnull)newArrayWithMatrix:(CGAffineTransform)matrix;
+ (ObjcQPDFObjectHandle* _Nonnull)newArrayWithRectangle:(CGRect)rect;
+ (ObjcQPDFObjectHandle* _Nonnull)newBool:(BOOL)b;
+ (ObjcQPDFObjectHandle* _Nonnull)newDictionary;
+ (ObjcQPDFObjectHandle* _Nonnull)newDictionaryWithDictionary:(NSDictionary<NSString*,ObjcQPDFObjectHandle*>* _Nonnull)dict;
+ (ObjcQPDFObjectHandle* _Nonnull)newIndirect:(NSString* _Nonnull)objGen for:(ObjcQPDF* _Nonnull)qpdf;
+ (ObjcQPDFObjectHandle* _Nonnull)newIndirect:(NSString* _Nonnull)objGen usingReference:(ObjcQPDFObjectHandle* _Nonnull)qpdfoh;
+ (ObjcQPDFObjectHandle* _Nonnull)newInteger:(NSInteger)i;
+ (ObjcQPDFObjectHandle* _Nonnull)newName:(NSString* _Nonnull)s;
+ (ObjcQPDFObjectHandle* _Nonnull)newNull;
+ (ObjcQPDFObjectHandle* _Nonnull)newReal:(double)n;
+ (ObjcQPDFObjectHandle* _Nonnull)newStreamForQPDF:(ObjcQPDF* _Nonnull)oQpdf;
+ (ObjcQPDFObjectHandle* _Nonnull)newStreamForQPDF:(ObjcQPDF* _Nonnull)oQpdf withData:(NSData* _Nonnull)data;
+ (ObjcQPDFObjectHandle* _Nonnull)newStreamForQPDF:(ObjcQPDF* _Nonnull)oQpdf withString:(NSString* _Nonnull)data;
+ (ObjcQPDFObjectHandle* _Nonnull)newString:(NSString* _Nonnull)s;
+ (ObjcQPDFObjectHandle* _Nonnull)nullObject;
- (ObjcQPDFObjectHandle* _Nonnull)objectAtIndex:(NSUInteger)index;
- (ObjcQPDFObjectHandle* _Nullable)objectForKey:(NSString* _Nonnull)key;
- (NSString* _Nonnull)objectGenerationID;
- (ObjcQPDF* _Nullable)owner;
- (NSInteger)pageNumber;
// - (QPDFObjectHandle)qpdfobject
+ (ObjcQPDFObjectHandle* _Nonnull)realWith:(double)b;
- (void)removeObjectAtIndex:(int)index;
- (void)removeObjectForKey:(NSString* _Nonnull)key;
- (void)replaceObject:(ObjcQPDFObjectHandle* _Nonnull)obj forKey:(NSString* _Nonnull)key;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(ObjcQPDFObjectHandle* _Nonnull)obj;
- (void)replaceStreamData:(NSString* _Nonnull)data;
- (NSData* _Nullable)stream;
- (ObjcQPDFObjectHandle* _Nonnull)streamDictionary;
+ (ObjcQPDFObjectHandle* _Nonnull)stringWith:(NSString* _Nonnull)b;
- (NSString* _Nonnull)text;
- (object_type_e)type;
- (NSString* _Nonnull)typeName;
- (NSString* _Nonnull)unparse;
- (NSString* _Nonnull)unparseResolved;

@end
