//
//  ObjcPDFObject.h
//  pdftracer
//
//  Created by Mark Heath on 24/2/21.
//  Copyright © 2021 silicontrip. All rights reserved.
//
#import "ObjcPDFDocument.h"

@protocol ObjcPDFDocument;

#ifndef ObjcPDFObject_h
#define ObjcPDFObject_h

@protocol ObjcPDFObject <NSObject>

- (instancetype)initWithObject:(id<ObjcPDFObject>)object;
- (instancetype)initWithString:(NSString*)string;

- (id<ObjcPDFDocument>)owner;
- (BOOL)isNull;
- (BOOL)isStream;
- (BOOL)isArray;
- (BOOL)isDictionary;
- (BOOL)isExpandable;
- (BOOL)isIndirect;
- (NSInteger)count;
- (id<ObjcPDFObject>)objectForKey:(NSString*)key;
- (NSArray<id<ObjcPDFObject>>*)array;
- (id<ObjcPDFObject>)streamDictionary;
- (NSData*)stream;
- (NSArray<NSString*>*)keys;
- (id<ObjcPDFObject>)objectAtIndex:(NSUInteger)index;
- (void)removeObjectForKey:(NSString*)key;
- (void)replaceObject:(id<ObjcPDFObject>)obj forKey:(NSString*)key;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id<ObjcPDFObject>)obj;
- (void)replaceStreamData:(NSString*)data;
- (NSString*)name;
- (NSString*)typeName;
- (NSString*)unparse;
- (NSString*)unparseResolved;
- (NSString*)objectGenerationID;
- (BOOL)childrenContainIndirects;
+ (id<ObjcPDFObject>)newNull;

@end

#endif /* ObjcPDFObject_h */
