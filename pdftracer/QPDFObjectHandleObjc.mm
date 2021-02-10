#import "QPDFObjectHandleObjc.hh"

@implementation QPDFObjectHandleObjc

-(instancetype)initWithObject:(QPDFObjectHandle)obj
{
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
    self = [super init];
    if (self)
    {
		dictionaryKeys = nil;
		objectArray = nil;

		std::string qpdfdef = std::string([def cStringUsingEncoding:NSMacOSRomanStringEncoding]);
        qObject = QPDFObjectHandle::parse(qpdfdef);
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

-(NSArray<QPDFObjectHandleObjc*>*)array
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
	return [[NSArray alloc] initWithArray:tempObjectArray];
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
	return [[NSArray alloc] initWithArray:tempKeyArray];
}
-(QPDFObjectHandleObjc*)objectForKey:(NSString*)key
{
	std::string tempKey = std::string([key cStringUsingEncoding:NSMacOSRomanStringEncoding]);
	QPDFObjectHandle tempObj  =  qObject.getKey(tempKey);
	return [[QPDFObjectHandleObjc alloc] initWithObject:tempObj];
}
-(QPDFObjectHandleObjc*)objectAtIndex:(NSUInteger)index
{
	QPDFObjectHandle thisObject = qObject.getArrayItem((int)index);
	return [[QPDFObjectHandleObjc alloc] initWithObject:thisObject];
}
-(void)removeObjectForKey:(NSString*)key
{
	std::string tempKey = std::string([key cStringUsingEncoding:NSMacOSRomanStringEncoding]);
	qObject.removeKey(tempKey);
}
-(void)replaceObject:(QPDFObjectHandleObjc*)obj ForKey:(NSString*)key
{
	std::string ckey = std::string([key cStringUsingEncoding:NSMacOSRomanStringEncoding]);
	qObject.replaceKey(ckey, [obj qpdfobject]);
}
-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(QPDFObjectHandleObjc*)obj
{
	qObject.setArrayItem((int)index, [obj qpdfobject]);
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
	if ([self isDictionary]) {
		for (NSString* keyname in [self keys])
		{
			QPDFObjectHandleObjc* child = [self objectForKey:keyname];
			if([child childrenContainIndirects])
				return YES;
			
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

+ (NSArray<QPDFObjectHandleObjc*>*)arrayWithVector:(std::vector<QPDFObjectHandle>)vec
{
	NSUInteger veclen = vec.size();
	NSMutableArray* tempObjectArray = [NSMutableArray arrayWithCapacity:veclen];
	for (int index = 0; index < veclen; ++index)
	{
		QPDFObjectHandle elem = vec[index];
		QPDFObjectHandleObjc* tempElem = [[QPDFObjectHandleObjc alloc] initWithObject:elem];
		[tempObjectArray addObject:tempElem];
	}
	return [[NSArray alloc] initWithArray:tempObjectArray];
}

@end
