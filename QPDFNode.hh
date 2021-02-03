#import <AppKit/AppKit.h>
#import <qpdf/QPDF.hh>

@interface QPDFNode : NSObject
{
	@private
	QPDFObjectHandle qpdfhandle;
	QPDFObjectHandle parent;
	QPDFNode* parentNode;
	NSString* name;
}

+ (instancetype)nodeWithParent:(QPDFNode*)pa Named:(NSString *)nm;
+ (instancetype)nodeWithParent:(QPDFNode*)pa Named:(NSString *)nm Handle:(QPDFObjectHandle)qp;
- (instancetype)initWithParent:(QPDFNode*)pa Named:(NSString *)nm Handle:(QPDFObjectHandle)qp;
- (QPDFObjectHandle)object;
- (QPDFObjectHandle)parent;
- (QPDFNode*)parentNode;
- (NSString*)name;
// - (NSString*)description;

@end
