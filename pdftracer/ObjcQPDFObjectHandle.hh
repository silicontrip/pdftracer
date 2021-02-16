#import "ObjcQPDFObjectHandle.h"
#import "ObjcQPDF.hh"
// they all go in the other one
#include <qpdf/QPDF.hh>
#include <qpdf/QPDFWriter.hh>
// put c++ here in the extension interface.
@interface ObjcQPDFObjectHandle()
{
	@private
    QPDFObjectHandle qObject;
}

-(instancetype)initWithObject:(QPDFObjectHandle)obj;
-(QPDFObjectHandle)qpdfobject;  // where is this needed ?
+(NSArray<ObjcQPDFObjectHandle*>*)arrayWithVector:(std::vector<QPDFObjectHandle>)vec;

@end
