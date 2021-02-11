#import "QPDFNode.h"

@implementation QPDFNode

+ (instancetype)nodeWithParent:(QPDFNode*)pa Named:(NSString *)nm
{
	return [[QPDFNode alloc] initWithParent:pa Named:nm Handle:[QPDFObjectHandleObjc null]];
}

+ (instancetype)nodeWithParent:(QPDFNode*)pa Named:(NSString *)nm Handle:(QPDFObjectHandleObjc*)qp
{
	return [[QPDFNode alloc] initWithParent:pa Named:nm Handle:qp];
}

- (instancetype)initWithParent:(QPDFNode*)pa Named:(NSString *)nm Handle:(QPDFObjectHandleObjc*)qp
{
	// NSLog(@"QPDFNode initWithParent: %@ %@ ",pa,nm);
    self = [super init];
    if(self){
		
		name = [NSString stringWithString:nm];
		// NSLog(@"New node: '%@' created",name);
		// NSLog(@"Parent node: %@",pa);
		[name retain];

		qpdfhandle = qp;
		parentNode = pa;
		if (pa)
			parent = [pa object];
		else
			parent = [QPDFObjectHandleObjc null];
    }
    return self;
}
	
- (QPDFObjectHandleObjc*)object { return qpdfhandle; }
- (QPDFObjectHandleObjc*)parent { return parent; }
- (QPDFNode*)parentNode { return parentNode; }

- (NSString*)name { return name; }



//- (NSString*)description { return [NSString stringWithFormat:@"]}

@end
