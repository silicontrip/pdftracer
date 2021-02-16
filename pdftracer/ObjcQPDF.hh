#import "ObjcQPDF.h"

#import "ObjcQPDFObjectHandle.hh"

#include <iostream>
#include <qpdf/QPDF.hh>
#include <qpdf/QPDFWriter.hh>

@interface ObjcQPDF ()
{
	@private
	QPDF qDocument;   // but we hide it from all the other
}

@end
