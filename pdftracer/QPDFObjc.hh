#import "QPDFObjc.h"

#import "QPDFObjectHandleObjc.hh"

#include <iostream>
#include <qpdf/QPDF.hh>
#include <qpdf/QPDFWriter.hh>

@interface QPDFObjc ()
{
	@private
	QPDF qDocument;   // but we hide it from all the other
}

@end
