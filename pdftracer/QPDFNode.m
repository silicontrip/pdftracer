#import "QPDFNode.h"

@implementation QPDFNode

+ (instancetype)nodeWithParent:(QPDFNode*)pa Named:(NSString *)nm
{
	return [[[QPDFNode alloc] initWithParent:pa Named:nm Handle:[QPDFObjectHandleObjc newNull]] autorelease];
}

+ (instancetype)nodeWithParent:(QPDFNode*)pa Named:(NSString *)nm Handle:(QPDFObjectHandleObjc*)qp
{
	return [[[QPDFNode alloc] initWithParent:pa Named:nm Handle:qp] autorelease];
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

		qpdfhandle = [qp retain];
		parentNode = pa;
		parent = nil;
		if (pa)
		{
			NSLog(@"parent node object: %x",[pa object]);
			parent = [pa object];
		}
		else
			parent = [QPDFObjectHandleObjc newNull];
    }
    return self;
}
	
- (QPDFObjectHandleObjc*)object { return qpdfhandle; }
- (QPDFObjectHandleObjc*)parent { return parent; }
- (QPDFNode*)parentNode { return parentNode; }

- (NSString*)name { return name; }


/*
- (NSString*)description {
	
	NSString *superString = [super description];  // All hail Trance masters Cygnus X and their track superstring
	[NSString stringWithFormat:@"<<%@  /name %@ /Parent %@"
	
//	return [NSString stringWithFormat:@"]
			
}
*/
@end
