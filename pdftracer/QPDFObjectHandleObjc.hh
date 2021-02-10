#import "QPDFObjectHandleObjc.h"
#import "QPDFObjc.hh"
// they all go in the other one
#include <qpdf/QPDF.hh>
#include <qpdf/QPDFWriter.hh>
// put c++ here in the extension interface.
@interface QPDFObjectHandleObjc()
{
	@private
    QPDFObjectHandle qObject;
}

-(instancetype)initWithObject:(QPDFObjectHandle)obj;
-(QPDFObjectHandle)qpdfobject;  // where is this needed ?
+(NSArray<QPDFObjectHandleObjc*>*)arrayWithVector:(std::vector<QPDFObjectHandle>)vec;

@end
