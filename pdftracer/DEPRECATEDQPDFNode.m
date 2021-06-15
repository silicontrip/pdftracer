#import "DEPRECATEDQPDFNode.h"

// moving the minimal additional functionality this provides into the Object Handle class
@implementation DEPRECATEDQPDFNode

+ (instancetype)nodeWithParent:(DEPRECATEDQPDFNode*)pa Named:(NSString *)nm
{
	return [[[DEPRECATEDQPDFNode alloc] initWithParent:pa Named:nm Handle:[ObjcQPDFObjectHandle newNull]] autorelease];
}

+ (instancetype)nodeWithParent:(DEPRECATEDQPDFNode*)pa Named:(NSString *)nm Handle:(ObjcQPDFObjectHandle*)qp
{
	return [[[DEPRECATEDQPDFNode alloc] initWithParent:pa Named:nm Handle:qp] autorelease];
}

- (instancetype)initWithParent:(nullable DEPRECATEDQPDFNode*)pa Named:(nonnull NSString *)nm Handle:(nonnull ObjcQPDFObjectHandle*)qp
{
	//NSLog(@"DEPRECATEDQPDFNode initWithParent: %@ Named: %@ ",pa,nm);
    self = [super init];
    if(self){
		
		name = [NSString stringWithString:nm];
	//	NSLog(@"New node: '%@' created",name);
	//	NSLog(@"Parent node: %@",pa);
		[name retain];

		qpdfhandle = [qp retain];
		parentNode = pa;
		parent = nil;
		if (pa != nil)
		{
			//NSLog(@"Node named: %@ parent: %@ obHandle: %@",name,[pa object],qp);
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

- (ObjcQPDF*)owner
{
	ObjcQPDF* own = [qpdfhandle owner];
	if (own == nil)
		own = [parentNode owner];  // it is possible to hit the top of the tree.
	
	return own;
}

// - (QPDFObjectHandleObjc*)parent { return parent; }

- (ObjcQPDFObjectHandle*)parent
{
	DEPRECATEDQPDFNode * qn = [self parentNode];
	if (qn==nil)
		return nil;
	return [qn object];
}
- (BOOL)hasParent
{
	return ([self parentNode] != nil);
}
- (DEPRECATEDQPDFNode*)parentNode { return parentNode; }

- (NSString*)name { return name; }

- (NSString*)unparse
{
	return [qpdfhandle unparse];
}

- (NSString*)unparseResolved
{
	return [qpdfhandle unparseResolved];
}

- (NSString*)text
{
	if ([qpdfhandle isStream]) {
		return [[[NSString alloc] initWithData:[qpdfhandle stream] encoding:NSMacOSRomanStringEncoding ] autorelease];
	} else {
		return [qpdfhandle unparseResolved];
	}
}

- (NSString*)description {
	
//	NSString *superString = [super description];  // All hail Trance masters Cygnus X and their track superstring
//	[NSString stringWithFormat:@"<<%@  /name %@ /Parent %@"
	if ([self parentNode] != nil)
		return [NSString stringWithFormat:@"%@ - %@ ^ %@",[self name],[self object],[[self parentNode]object]];
	else
		return [NSString stringWithFormat:@"%@ - %@ ^ nil",[self name],[self object]];

//	return [NSString stringWithFormat:@"]
			
}

@end
