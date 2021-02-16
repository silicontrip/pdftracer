#import "ObjcQPDFObjectHandle.hh"

@implementation ObjcQPDFObjectHandle

// C++ data type
-(instancetype)initWithObject:(QPDFObjectHandle)obj
{
	NSLog(@"ObjcObjectHandle initWithObject");
    self = [super init];
    if (self)
    {
		dictionaryKeys = nil;
		objectArray = nil;
        qObject = QPDFObjectHandle(obj);
    }
    return self;
}
-(instancetype)initWithString:(NSString*)def
{
	NSLog(@"ObjcObjectHandle initWithString");

    self = [super init];
    if (self)
    {
		dictionaryKeys = nil;
		objectArray = nil;

		NSLog(@"NS String: <<%@>>",def);
		
		std::string qpdfdef = std::string([def cStringUsingEncoding:NSMacOSRomanStringEncoding]);
		try {
        	qObject = QPDFObjectHandle::parse(qpdfdef);
		} catch (QPDFExc e) {
			return nil;
		}
    }
    return self;
}
-(BOOL)isNull { return qObject.isNull(); }
-(BOOL)isStream { return qObject.isStream(); }
-(BOOL)isArray { return qObject.isArray(); }
-(BOOL)isIndirect { return qObject.isIndirect(); }
-(BOOL)isDictionary { return qObject.isDictionary(); }
-(BOOL)isExpandable { return qObject.isArray() || qObject.isDictionary(); }

-(NSUInteger)count
{
	if ([self isArray]) {
        return qObject.getArrayNItems();
	} else if ([self isDictionary]) {
		return qObject.getKeys().size();
	}
	return 0;
}

-(NSArray<ObjcQPDFObjectHandle*>*)array
{
	if (objectArray)
		return objectArray;
	
	NSMutableArray* tempObjectArray = [NSMutableArray arrayWithCapacity:[self count]];
	for (int index = 0; index <[self count]; ++index)
		[tempObjectArray addObject:[self objectAtIndex:index]];
/* // we don't handle cache invalidation yet
	objectArray = [[NSArray alloc] initWithArray:tempObjectArray];
	return objectArray;
 */
	return [[[NSArray alloc] initWithArray:tempObjectArray] autorelease];
}

-(NSData*)stream
{
	PointerHolder<Buffer> bufRef = qObject.getStreamData();
	
	Buffer* buf = bufRef.getPointer();
	size_t sz = buf->getSize();
	unsigned char * bb = buf->getBuffer();
	return [[[NSData alloc] initWithBytes:bb length:sz] autorelease];
}

-(NSArray<NSString*>*)keys
{
	if (dictionaryKeys)
		return dictionaryKeys;
	
	NSMutableArray* tempKeyArray = [NSMutableArray arrayWithCapacity:[self count]];

	std::set<std::string> keys = qObject.getKeys();  // I need this to be order preserving.
	std::vector<std::string> ord(keys.begin(), keys.end());
	std::set<std::string>::iterator iterKey;
	for(iterKey = keys.begin(); iterKey != keys.end(); ++iterKey)
	{
		std::string itKey{ *iterKey };
		NSString* keyString = [NSString stringWithCString:itKey.c_str() encoding:NSMacOSRomanStringEncoding ];
		[tempKeyArray addObject:keyString];
	}
	/*  // we don't handle cache invalidation yet
	dictionaryKeys = [[NSArray alloc] initWithArray:tempKeyArray];
	return dictionaryKeys;
	 */
	return [[[NSArray alloc] initWithArray:tempKeyArray] autorelease];
}
-(ObjcQPDFObjectHandle*)objectForKey:(NSString*)key
{
	std::string tempKey = std::string([key cStringUsingEncoding:NSMacOSRomanStringEncoding]);
	QPDFObjectHandle tempObj  =  qObject.getKey(tempKey);
	return [[[ObjcQPDFObjectHandle alloc] initWithObject:tempObj] autorelease];
}
-(ObjcQPDFObjectHandle*)objectAtIndex:(NSUInteger)index
{
	QPDFObjectHandle thisObject = qObject.getArrayItem((int)index);
	return [[[ObjcQPDFObjectHandle alloc] initWithObject:thisObject] autorelease];
}

-(void)removeObjectForKey:(NSString*)key
{
	std::string tempKey = std::string([key cStringUsingEncoding:NSMacOSRomanStringEncoding]);
	qObject.removeKey(tempKey);
}

-(void)replaceObject:(nonnull ObjcQPDFObjectHandle*)obj forKey:(NSString*)key
{
	if (obj != nil)
	{
		std::string ckey = std::string([key cStringUsingEncoding:NSMacOSRomanStringEncoding]);
		QPDFObjectHandle rObject = [obj qpdfobject];

		qObject.replaceKey(ckey, rObject);
	} else {
		NSLog(@"Warning danger Will Robinson replacement object is nil");
	}
}

-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(ObjcQPDFObjectHandle*)obj
{
	if (obj != nil)
	{
		qObject.setArrayItem((int)index, [obj qpdfobject]);
	}
}

-(void)replaceStreamData:(NSString*)data
{
	std::string replacement = std::string([data cStringUsingEncoding:NSMacOSRomanStringEncoding]);
	qObject.replaceStreamData(replacement,QPDFObjectHandle::newNull(),QPDFObjectHandle::newNull());
}

-(NSString*)name
{
	return [NSString stringWithCString:qObject.getName().c_str() encoding:NSMacOSRomanStringEncoding];
}
-(NSString*)typeName
{
	return [NSString stringWithCString:qObject.getTypeName() encoding:NSMacOSRomanStringEncoding];
}

-(NSString*)unparse
{
	return [NSString stringWithCString:qObject.unparse().c_str() encoding:NSMacOSRomanStringEncoding];

}
-(NSString*)unparseResolved
{
	return [NSString stringWithCString:qObject.unparseResolved().c_str() encoding:NSMacOSRomanStringEncoding];

}
-(BOOL)childrenContainIndirects
{
	// remember not to follow /Parent names
	if ([self isDictionary]) {
		for (NSString* keyname in [self keys])
		{
			NSLog(@"children of %@",keyname);  // don't follow parent.
			if ([keyname caseInsensitiveCompare:@"/parent"] != NSOrderedSame)
			{
				ObjcQPDFObjectHandle* child = [self objectForKey:keyname];
				if([child childrenContainIndirects])
					return YES;
			}
			return NO;
		}
	} else if ([self isArray]) {
			for (int index=0; index<[self count];++index)
			{
				if ([[self objectAtIndex:index] childrenContainIndirects])
					return YES;
			}
	} else if ([self isIndirect]) {
		return YES;
	}
		return NO;
}

-(QPDFObjectHandle)qpdfobject
{
	return qObject;
}

+ (NSArray<ObjcQPDFObjectHandle*>*)arrayWithVector:(std::vector<QPDFObjectHandle>)vec
{
	NSUInteger veclen = vec.size();
	NSMutableArray* tempObjectArray = [NSMutableArray arrayWithCapacity:veclen];
	for (int index = 0; index < veclen; ++index)
	{
		QPDFObjectHandle elem = vec[index];
		ObjcQPDFObjectHandle* tempElem = [[[ObjcQPDFObjectHandle alloc] initWithObject:elem] autorelease];
		[tempObjectArray addObject:tempElem];
	}
	return [[[NSArray alloc] initWithArray:tempObjectArray] autorelease];
}
+ (ObjcQPDFObjectHandle*)newNull
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newNull()];
}

@end
