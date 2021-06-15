#import <AppKit/AppKit.h>
#import "ObjcQPDF.h"
#import "ObjcQPDFObjectHandle.h"

@interface DEPRECATEDQPDFNode : NSObject
{
	@private
	ObjcQPDFObjectHandle* qpdfhandle;
	ObjcQPDFObjectHandle* parent;
	DEPRECATEDQPDFNode* parentNode;
	NSString* name;
}

+ (instancetype)nodeWithParent:(DEPRECATEDQPDFNode*)pa Named:(NSString *)nm;
+ (instancetype)nodeWithParent:(DEPRECATEDQPDFNode*)pa Named:(NSString *)nm Handle:(ObjcQPDFObjectHandle*)qp;
- (instancetype)initWithParent:(DEPRECATEDQPDFNode*)pa Named:(NSString *)nm Handle:(ObjcQPDFObjectHandle*)qp;
- (ObjcQPDFObjectHandle*)object;
- (ObjcQPDF*)owner;
- (NSString*)unparse;
- (NSString*)unparseResolved;
- (NSString*)text;
- (BOOL)hasParent;
- (ObjcQPDFObjectHandle*)parent;
- (DEPRECATEDQPDFNode*)parentNode;
- (NSString*)name;

@end
