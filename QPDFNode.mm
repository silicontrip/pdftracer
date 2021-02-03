#import "QPDFNode.hh"

@implementation QPDFNode

+ (instancetype)nodeWithParent:(QPDFNode*)pa Named:(NSString *)nm
{
	return [[QPDFNode alloc] initWithParent:pa Named:nm Handle:QPDFObjectHandle::newNull()];
}

+ (instancetype)nodeWithParent:(QPDFNode*)pa Named:(NSString *)nm Handle:(QPDFObjectHandle)qp
{
	return [[QPDFNode alloc] initWithParent:pa Named:nm Handle:qp];
}

- (instancetype)initWithParent:(QPDFNode*)pa Named:(NSString *)nm Handle:(QPDFObjectHandle)qp
{
	NSLog(@"QPDFNode initWithParent: %@ %@ ",pa,nm);
    self = [super init];
    if(self){
		
		name = [NSString stringWithString:nm];
		NSLog(@"New node: '%@' created",name);
		NSLog(@"Parent node: %@",pa);
		[name retain];

		qpdfhandle = qp;
		parentNode = pa;
		if (pa)
			parent = [pa object];
		else
			parent = QPDFObjectHandle::newNull();
    }
    return self;
}
	
- (QPDFObjectHandle)object { return qpdfhandle; }
- (QPDFObjectHandle)parent { return parent; }
- (QPDFNode*)parentNode { return parentNode; }

- (NSString*)name { return name; }



//- (NSString*)description { return [NSString stringWithFormat:@"]}

@end
