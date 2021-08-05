#import "ObjcQPDFObjectHandle.hh"

@implementation ObjcQPDFObjectHandle

// C++ data type, so cannot expose this interface to the rest of the classes
- (instancetype)initWithObject:(QPDFObjectHandle)obj
{
//	NSLog(@"ObjcObjectHandle initWithObject %@",
//	[NSString stringWithFormat:@"%s",obj.unparse().c_str()]);
	
    self = [super init];
    if (self)
    {
		dictionaryKeys = nil;
		objectArray = nil;
        qObject = QPDFObjectHandle(obj);
    }
    return self;
}

- (instancetype)initWithString:(NSString* _Nonnull)def
{
	//NSLog(@"ObjcObjectHandle initWithString %@",def);

    self = [super init];
    if (self)
    {
		dictionaryKeys = nil;
		objectArray = nil;
		
		std::string qpdfdef = std::string([def cStringUsingEncoding:NSMacOSRomanStringEncoding]);
		try {
        	qObject = QPDFObjectHandle::parse(qpdfdef);
		} catch (std::logic_error e) {
			return nil;
		}
    }
    return self;
}

// returns
- (ObjcQPDF* _Nullable)owner
{
	QPDF* owner = qObject.getOwningQPDF();
	
//	NSLog(@"from object: %@",self);
//	NSLog(@"Owner .. %lx",(unsigned long)owner);
	if (owner)
		return [[[ObjcQPDF alloc] initWithQPDF:owner] autorelease];
	else
		return nil;
}

- (BOOL)isNull { return qObject.isNull(); }
- (BOOL)isStream { return qObject.isStream(); }
- (BOOL)isString { return qObject.isString(); }
- (BOOL)isName { return qObject.isName(); }
- (BOOL)isArray { return qObject.isArray(); }
- (BOOL)isIndirect { return qObject.isIndirect(); }
- (BOOL)isDictionary { return qObject.isDictionary(); }
- (BOOL)isExpandable { return qObject.isArray() || qObject.isDictionary(); }

- (NSString* _Nullable)dictionaryType
{
	if ([self isDictionary])
	{
		ObjcQPDFObjectHandle* type = [self objectForKey:@"/Type"];
		if (type)
		{
			if ([type isName])
			{
				return [type name];
			}
		}
	}
	return nil;
}

- (BOOL)isPage {
	if ( [[self dictionaryType] isEqualToString:@"/Page"])
	{
		return YES;
	}
	return NO;
}

- (NSInteger)pageNumber
{
	if ([self isPage])
{
		ObjcQPDF* qDoc = [self owner];
		if (qDoc)
			return [[qDoc pageIndexForIndirect:[self objectGenerationID]] longValue];
	}
	return -1;
}

- (object_type_e)type { return (object_type_e)qObject.getTypeCode(); }

- (NSUInteger)count
{
	if ([self isArray]) {
        return qObject.getArrayNItems();
	} else if ([self isDictionary]) {
		return qObject.getKeys().size();
	}
	return 0;
}

- (NSArray<ObjcQPDFObjectHandle*>* _Nonnull)array
{
 
	NSMutableArray* tempObjectArray = [NSMutableArray arrayWithCapacity:[self count]];
	for (int index = 0; index <[self count]; ++index)
		[tempObjectArray addObject:[self objectAtIndex:index]];
/* // we don't handle cache invalidation yet
	objectArray = [[NSArray alloc] initWithArray:tempObjectArray];
	return objectArray;
 */
	return [[[NSArray alloc] initWithArray:tempObjectArray] autorelease];
}

- (ObjcQPDFObjectHandle* _Nonnull)streamDictionary
{
	return [[[ObjcQPDFObjectHandle alloc] initWithObject:qObject.getDict() ] autorelease];
}

- (NSData* _Nullable)stream
{
	try {
		PointerHolder<Buffer> bufRef = qObject.getStreamData();
		Buffer* buf = bufRef.getPointer();
		size_t sz = buf->getSize();
		unsigned char * bb = buf->getBuffer();
		return [[[NSData alloc] initWithBytes:bb length:sz] autorelease];
	} catch (QPDFExc e) {
		return nil;
	}

}

- (NSArray<NSString*>* _Nonnull)keys
{
//	if (dictionaryKeys)
	//	return dictionaryKeys;
	
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

- (ObjcQPDFObjectHandle* _Nullable)objectForKey:(NSString* _Nonnull)key
{
	std::string tempKey = std::string([key cStringUsingEncoding:NSMacOSRomanStringEncoding]);
	BOOL hasKey = qObject.hasKey(tempKey);
	if (hasKey) {
		QPDFObjectHandle tempObj  =  qObject.getKey(tempKey);
	
	//NSLog(@"object for key: is initialised: %d",tempObj.isInitialized());
	
		return [[[ObjcQPDFObjectHandle alloc] initWithObject:tempObj] autorelease];
	}
	return nil;
}


- (ObjcQPDFObjectHandle*)objectAtIndex:(NSUInteger)index
{
	// should I check that this is an array?
	QPDFObjectHandle thisObject = qObject.getArrayItem((int)index);
	return [[[ObjcQPDFObjectHandle alloc] initWithObject:thisObject] autorelease];
}

- (void)removeObjectForKey:(NSString* _Nonnull)key
{
	std::string tempKey = std::string([key cStringUsingEncoding:NSMacOSRomanStringEncoding]);
	qObject.removeKey(tempKey);
}

- (void)removeObjectAtIndex:(int)index;
{
	qObject.eraseItem(index);
}

- (void)replaceObject:(ObjcQPDFObjectHandle* _Nonnull)obj forKey:(NSString*)key
{
	// NSLog(@"Replace object: %@ for: %@",obj,key);
	NSAssert(obj!=nil,@"[ObjcQPDFObjectHandle replaceObject obj==nil");

	if (obj != nil)
	{
		std::string ckey = std::string([key cStringUsingEncoding:NSMacOSRomanStringEncoding]);
		QPDFObjectHandle rObject = [obj qpdfobject];

		qObject.replaceKey(ckey, rObject);
	}
//	else {
		// I doubt that this should ever be called.
		//NSLog(@"Warning danger Will Robinson replacement object is nil");  // but I like this string
//	}
	
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(ObjcQPDFObjectHandle* _Nonnull)obj
{
//	NSLog(@"Replace object: %lu for: %@",index,obj);
	NSAssert(obj!=nil,@"[ObjcQPDFObjectHandle replaceObjectAtIndex obj==nil");

	if (obj != nil)
	{
	qObject.setArrayItem((int)index, [obj qpdfobject]);
	}
}

- (void)addObject:(ObjcQPDFObjectHandle* _Nonnull)obj
{
	if (obj != nil)
	{
		// shouldn't I also check that this is the correct object type
		qObject.appendItem([obj qpdfobject]);
	}
}

- (void)replaceStreamData:(NSString* _Nonnull)data
{
	std::string replacement = std::string([data cStringUsingEncoding:NSMacOSRomanStringEncoding]);
	qObject.replaceStreamData(replacement,QPDFObjectHandle::newNull(),QPDFObjectHandle::newNull());
}

- (NSString* _Nonnull)name
{
	return [NSString stringWithCString:qObject.getName().c_str() encoding:NSMacOSRomanStringEncoding];
}

- (NSString* _Nonnull)typeName
{
	return [NSString stringWithCString:qObject.getTypeName() encoding:NSMacOSRomanStringEncoding];
}

- (NSString* _Nonnull)unparse
{
	std::string type =qObject.getTypeName();
//	NSLog(@"qObject type:%s", type.c_str() );
	return [NSString stringWithCString:qObject.unparse().c_str() encoding:NSMacOSRomanStringEncoding];
}

- (NSString* _Nonnull)unparseResolved
{
	return [NSString stringWithCString:qObject.unparseResolved().c_str() encoding:NSMacOSRomanStringEncoding];
}

- (NSString* _Nonnull)objectGenerationID
{
	return [NSString stringWithFormat:@"%d %d R",qObject.getObjectID(),qObject.getGeneration()];
}

- (BOOL)childrenContainIndirects
{
	// remember not to follow /Parent names
	if ([self isDictionary]) {
		for (NSString* keyname in [self keys])
		{
			// NSLog(@"children of %@",keyname);  // don't follow parent.
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

// c++ method
- (QPDFObjectHandle)qpdfobject
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

- (NSString* _Nonnull)text
{
	if ([self isStream]) {
		return [[[NSString alloc] initWithData:[self stream] encoding:NSMacOSRomanStringEncoding ] autorelease];
	} else {
		return [self unparseResolved];
	}
}

- (NSString* _Nonnull)description
{
	NSString* nn = [super description];
	NSString* tn = [self typeName];
	NSString* up = [self unparse];
	
	return [NSString stringWithFormat:@"%@ %@ %@",nn,tn,up];
}

+ (ObjcQPDFObjectHandle* _Nonnull)newNull
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newNull()];
}
+ (ObjcQPDFObjectHandle* _Nonnull)newBool:(BOOL)b
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newBool(b)];
}

+ (ObjcQPDFObjectHandle* _Nonnull)newInteger:(NSInteger)i
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newInteger(i)];
}
+ (ObjcQPDFObjectHandle* _Nonnull)newReal:(double)n
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newReal(n)];
}

+ (ObjcQPDFObjectHandle* _Nonnull)newString:(NSString* _Nonnull)s
{
	const char* cs = [s cStringUsingEncoding:NSMacOSRomanStringEncoding];
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newString(std::string(cs))];
}
+ (ObjcQPDFObjectHandle* _Nonnull)newName:(NSString* _Nonnull)s
{
	const char* cs = [s cStringUsingEncoding:NSMacOSRomanStringEncoding];
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newName(std::string(cs))];
}
+ (ObjcQPDFObjectHandle* _Nonnull)newArray
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newArray()];
}
+ (ObjcQPDFObjectHandle* _Nonnull)newArrayWithArray:(NSArray<ObjcQPDFObjectHandle*>* _Nonnull)array
{
	// std::vector<QPDFObjectHandle> const& items);

	ObjcQPDFObjectHandle* par = [ObjcQPDFObjectHandle newArray];
	
	for (ObjcQPDFObjectHandle* ai in array)
		[par addObject:ai];
	
	return par;
}
+ (ObjcQPDFObjectHandle* _Nonnull)newArrayWithRectangle:(CGRect)rect
{
	ObjcQPDFObjectHandle* par = [ObjcQPDFObjectHandle newArray];
	[par addObject:[ObjcQPDFObjectHandle realWith:rect.origin.x]];
	[par addObject:[ObjcQPDFObjectHandle realWith:rect.origin.y]];
	[par addObject:[ObjcQPDFObjectHandle realWith:rect.size.width]];
	[par addObject:[ObjcQPDFObjectHandle realWith:rect.size.height]];

	return par;
}
+ (ObjcQPDFObjectHandle* _Nonnull)newArrayWithMatrix:(CGAffineTransform)matrix
{
	ObjcQPDFObjectHandle* par = [ObjcQPDFObjectHandle newArray];
	[par addObject:[ObjcQPDFObjectHandle realWith:matrix.a]];
	[par addObject:[ObjcQPDFObjectHandle realWith:matrix.b]];
	[par addObject:[ObjcQPDFObjectHandle realWith:matrix.c]];
	[par addObject:[ObjcQPDFObjectHandle realWith:matrix.d]];
	[par addObject:[ObjcQPDFObjectHandle realWith:matrix.tx]];
	[par addObject:[ObjcQPDFObjectHandle realWith:matrix.tx]];

	return par;
}
+ (ObjcQPDFObjectHandle* _Nonnull)newDictionary
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newDictionary()];
}
+ (ObjcQPDFObjectHandle* _Nonnull)newDictionaryWithDictionary:(NSDictionary<NSString*,ObjcQPDFObjectHandle*>*)dict
{
	NSAssert(NO,@"newDictionaryWithDictionary unimplemented");
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newDictionary()];
}

+ (ObjcQPDFObjectHandle* _Nonnull)newStreamForQPDF:(ObjcQPDF* _Nonnull)oQpdf
{
	// NSLog(@"new Stream");
	
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newStream([oQpdf qpdf])];
}

+ (ObjcQPDFObjectHandle* _Nonnull)newStreamForQPDF:(ObjcQPDF* _Nonnull)oQpdf withData:(NSData* _Nonnull)data
{
	
	unsigned char* bd =(unsigned char*) [data bytes];
	size_t noBytes = [data length];
	
	Buffer* buf = new Buffer(bd,noBytes);
	
	PointerHolder<Buffer> phb(buf);
	
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newStream([oQpdf qpdf],phb)];
}
+ (ObjcQPDFObjectHandle* _Nonnull)newStreamForQPDF:(ObjcQPDF* _Nonnull)oQpdf withString:(NSString* _Nonnull)data
{
	std::string stringData([data cStringUsingEncoding:NSMacOSRomanStringEncoding]);
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newStream([oQpdf qpdf],stringData)];
}
+ (ObjcQPDFObjectHandle* _Nonnull)newIndirect:(NSString* _Nonnull)objGen for:(ObjcQPDF* _Nonnull)qpdf
{
	NSArray<NSString*>* objElem= [objGen componentsSeparatedByString:@" "];
	int objid = [[objElem objectAtIndex:0] intValue];
	int genid = [[objElem objectAtIndex:1] intValue];
	
	QPDFObjGen newGen(objid, genid);
	QPDFObjectHandle oh = [qpdf qpdf]->getObjectByObjGen(newGen);
	
	return [[ObjcQPDFObjectHandle alloc] initWithObject:oh];
	//QPDFObjectHandle::newIndirect([qpdf qpdf], objid, genid)];

}

+ (ObjcQPDFObjectHandle* _Nonnull)nullObject { return [[ObjcQPDFObjectHandle newNull] autorelease]; }
+ (ObjcQPDFObjectHandle* _Nonnull)boolWith:(BOOL)b { return [[ObjcQPDFObjectHandle newBool:b] autorelease]; }
+ (ObjcQPDFObjectHandle* _Nonnull)intWith:(NSInteger)b { return [[ObjcQPDFObjectHandle newInteger:b] autorelease]; }
+ (ObjcQPDFObjectHandle* _Nonnull)realWith:(double)b { return [[ObjcQPDFObjectHandle newReal:b] autorelease]; }
+ (ObjcQPDFObjectHandle* _Nonnull)stringWith:(NSString* _Nonnull)b { return [[ObjcQPDFObjectHandle newString:b] autorelease]; }
+ (ObjcQPDFObjectHandle* _Nonnull)nameWith:(NSString* _Nonnull)b { return [[ObjcQPDFObjectHandle newName:b] autorelease]; }
+ (ObjcQPDFObjectHandle* _Nonnull)arrayObject { return [[ObjcQPDFObjectHandle newArray] autorelease]; }
+ (ObjcQPDFObjectHandle* _Nonnull)arrayWithArray:(NSArray<ObjcQPDFObjectHandle*>* _Nonnull)array { return [[ObjcQPDFObjectHandle newArrayWithArray:array] autorelease]; }
+ (ObjcQPDFObjectHandle* _Nonnull)arrayWithRectangle:(CGRect)rect { return [[ObjcQPDFObjectHandle newArrayWithRectangle:rect] autorelease]; }
+ (ObjcQPDFObjectHandle* _Nonnull)arrayWithMatrix:(CGAffineTransform)matrix { return [[ObjcQPDFObjectHandle newArrayWithMatrix:matrix] autorelease]; }
+ (ObjcQPDFObjectHandle* _Nonnull)dictionaryObject { return [[ObjcQPDFObjectHandle newDictionary] autorelease]; }
+ (ObjcQPDFObjectHandle* _Nonnull)dictionaryWithDictionary:(NSDictionary<NSString*,ObjcQPDFObjectHandle*>* _Nonnull)dict { return [[ObjcQPDFObjectHandle newDictionaryWithDictionary:dict] autorelease]; }

/*
+ (ObjcQPDFObjectHandle*)newIndirect:(NSString*)objGen usingReference:(ObjcQPDFObjectHandle*)qpdfoh
{
	NSArray<NSString*>* objElem= [objGen componentsSeparatedByString:@" "];
	int objid = [[objElem objectAtIndex:0] intValue];
	int genid = [[objElem objectAtIndex:1] intValue];
	
	QPDFObjGen newGen(objid, genid);
	QPDFObjectHandle oh = [[qpdf qpdf]->getObjectByObjGen(newGen);
	
	return [[ObjcQPDFObjectHandle alloc] initWithObject:oh];
	//QPDFObjectHandle::newIndirect([qpdf qpdf], objid, genid)];
	
}
*/

@end
