#import <AppKit/AppKit.h>
#import "ObjcQPDF.h"
#import "ObjcQPDFObjectHandle.h"

@interface QPDFNode : NSObject
{
	@private
	ObjcQPDFObjectHandle* qpdfhandle;
	ObjcQPDFObjectHandle* parent;
	QPDFNode* parentNode;
	NSString* name;
}

+ (instancetype)nodeWithParent:(QPDFNode*)pa Named:(NSString *)nm;
+ (instancetype)nodeWithParent:(QPDFNode*)pa Named:(NSString *)nm Handle:(ObjcQPDFObjectHandle*)qp;
- (instancetype)initWithParent:(QPDFNode*)pa Named:(NSString *)nm Handle:(ObjcQPDFObjectHandle*)qp;
- (ObjcQPDFObjectHandle*)object;
- (NSString*)unparse;
- (NSString*)unparseResolved;
- (BOOL)hasParent;
- (ObjcQPDFObjectHandle*)parent;
- (QPDFNode*)parentNode;
- (NSString*)name;

@end
