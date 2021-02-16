#import "QPDFNode.h"

@implementation QPDFNode

+ (instancetype)nodeWithParent:(QPDFNode*)pa Named:(NSString *)nm
{
	return [[[QPDFNode alloc] initWithParent:pa Named:nm Handle:[ObjcQPDFObjectHandle newNull]] autorelease];
}

+ (instancetype)nodeWithParent:(QPDFNode*)pa Named:(NSString *)nm Handle:(ObjcQPDFObjectHandle*)qp
{
	return [[[QPDFNode alloc] initWithParent:pa Named:nm Handle:qp] autorelease];
}

- (instancetype)initWithParent:(nullable QPDFNode*)pa Named:(nonnull NSString *)nm Handle:(nonnull ObjcQPDFObjectHandle*)qp
{
	// NSLog(@"QPDFNode initWithParent: %@ %@ ",pa,nm);
    self = [super init];
    if(self){
		
		name = [NSString stringWithString:nm];
		NSLog(@"New node: '%@' created",name);
		NSLog(@"Parent node: %@",pa);
		[name retain];

		qpdfhandle = [qp retain];
		parentNode = pa;
		parent = nil;
		if (pa != nil)
		{
			NSLog(@"Node named: %@ parent: %@ obHandle: %@",name,[pa object],qp);
			parent = [pa object];
		}
		else
		{
			parent = nil; // [QPDFObjectHandleObjc newNull];
		}
    }
    return self;
}
	
- (ObjcQPDFObjectHandle*)object { return qpdfhandle; }
// - (QPDFObjectHandleObjc*)parent { return parent; }

- (ObjcQPDFObjectHandle*)parent
{
	QPDFNode * qn = [self parentNode];
	if (qn==nil)
		return nil;
	return [qn object];
}
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
