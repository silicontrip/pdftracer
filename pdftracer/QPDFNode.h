#import <AppKit/AppKit.h>
#import "QPDFObjc.h"
#import "QPDFObjectHandleObjc.h"

@interface QPDFNode : NSObject
{
	@private
	QPDFObjectHandleObjc* qpdfhandle;
	QPDFObjectHandleObjc* parent;
	QPDFNode* parentNode;
	NSString* name;
}

+ (instancetype)nodeWithParent:(QPDFNode*)pa Named:(NSString *)nm;
+ (instancetype)nodeWithParent:(QPDFNode*)pa Named:(NSString *)nm Handle:(QPDFObjectHandleObjc*)qp;
- (instancetype)initWithParent:(QPDFNode*)pa Named:(NSString *)nm Handle:(QPDFObjectHandleObjc*)qp;
- (QPDFObjectHandleObjc*)object;
- (QPDFObjectHandleObjc*)parent;
- (QPDFNode*)parentNode;
- (NSString*)name;
// - (NSString*)description;

@end
