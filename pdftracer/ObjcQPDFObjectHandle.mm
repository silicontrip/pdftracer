#import "ObjcQPDFObjectHandle.hh"

@implementation ObjcQPDFObjectHandle

// C++ data type, so cannot expose this interface to the rest of the classes
-(instancetype)initWithObject:(QPDFObjectHandle)obj
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

-(instancetype)initWithString:(NSString*)def
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
		} catch (QPDFExc e) {
			return nil;
		}
    }
    return self;
}

-(ObjcQPDF*)owner
{
	return [[[ObjcQPDF alloc] initWithQPDF:qObject.getOwningQPDF()] autorelease];
}

-(BOOL)isNull { return qObject.isNull(); }
-(BOOL)isStream { return qObject.isStream(); }
-(BOOL)isArray { return qObject.isArray(); }
-(BOOL)isIndirect { return qObject.isIndirect(); }
-(BOOL)isDictionary { return qObject.isDictionary(); }
-(BOOL)isExpandable { return qObject.isArray() || qObject.isDictionary(); }

-(object_type_e)type { return (object_type_e)qObject.getTypeCode(); }

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
 
	NSMutableArray* tempObjectArray = [NSMutableArray arrayWithCapacity:[self count]];
	for (int index = 0; index <[self count]; ++index)
		[tempObjectArray addObject:[self objectAtIndex:index]];
/* // we don't handle cache invalidation yet
	objectArray = [[NSArray alloc] initWithArray:tempObjectArray];
	return objectArray;
 */
	return [[[NSArray alloc] initWithArray:tempObjectArray] autorelease];
}

-(ObjcQPDFObjectHandle*)streamDictionary
{
	return [[[ObjcQPDFObjectHandle alloc] initWithObject:qObject.getDict() ] autorelease];
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

-(ObjcQPDFObjectHandle*)objectForKey:(NSString*)key
{
	std::string tempKey = std::string([key cStringUsingEncoding:NSMacOSRomanStringEncoding]);
	QPDFObjectHandle tempObj  =  qObject.getKey(tempKey);
	return [[[ObjcQPDFObjectHandle alloc] initWithObject:tempObj] autorelease];
}

-(ObjcQPDFObjectHandle*)objectAtIndex:(NSUInteger)index
{
	// should I check that this is an array?
	QPDFObjectHandle thisObject = qObject.getArrayItem((int)index);
	return [[[ObjcQPDFObjectHandle alloc] initWithObject:thisObject] autorelease];
}

-(void)removeObjectForKey:(NSString*)key
{
	std::string tempKey = std::string([key cStringUsingEncoding:NSMacOSRomanStringEncoding]);
	qObject.removeKey(tempKey);
}

-(void)removeObjectAtIndex:(int)index;
{
	qObject.eraseItem(index);
}

-(void)replaceObject:(nonnull ObjcQPDFObjectHandle*)obj forKey:(NSString*)key
{
	//NSLog(@"Replace object");
	if (obj != nil)
	{
		std::string ckey = std::string([key cStringUsingEncoding:NSMacOSRomanStringEncoding]);
		QPDFObjectHandle rObject = [obj qpdfobject];

		qObject.replaceKey(ckey, rObject);
	} else {
		// I doubt that this should ever be called.
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

-(void)addObject:(ObjcQPDFObjectHandle *)obj
{
	if (obj != nil)
	{
		// shouldn't I also check that this is the correct object type
		qObject.appendItem([obj qpdfobject]);
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
	std::string type =qObject.getTypeName();
//	NSLog(@"qObject type:%s", type.c_str() );
	return [NSString stringWithCString:qObject.unparse().c_str() encoding:NSMacOSRomanStringEncoding];
}

-(NSString*)unparseResolved
{
	return [NSString stringWithCString:qObject.unparseResolved().c_str() encoding:NSMacOSRomanStringEncoding];
}

-(NSString*)objectGenerationID
{
	return [NSString stringWithFormat:@"%d %d R",qObject.getObjectID(),qObject.getGeneration()];
}

-(BOOL)childrenContainIndirects
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

- (NSString*)description
{
	NSString* nn = [super description];
	NSString* tn = [self typeName];
	NSString* up = [self unparse];
	
	return [NSString stringWithFormat:@"%@ %@ %@",nn,tn,up];
}

+ (ObjcQPDFObjectHandle*)newNull
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newNull()];
}
+ (ObjcQPDFObjectHandle*)newBool:(BOOL)b
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newBool(b)];
}

+ (ObjcQPDFObjectHandle*)newInteger:(NSInteger)i
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newInteger(i)];
}
+ (ObjcQPDFObjectHandle*)newReal:(double)n
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newReal(n)];
}

+ (ObjcQPDFObjectHandle*)newString:(NSString*)s
{
	const char* cs = [s cStringUsingEncoding:NSMacOSRomanStringEncoding];
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newString(std::string(cs))];
}
+ (ObjcQPDFObjectHandle*)newName:(NSString*)s
{
	const char* cs = [s cStringUsingEncoding:NSMacOSRomanStringEncoding];
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newName(std::string(cs))];
}
+ (ObjcQPDFObjectHandle*)newArray
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newArray()];
}
+ (ObjcQPDFObjectHandle*)newArrayWithArray:(NSArray<ObjcQPDFObjectHandle*>*)array
{
	// std::vector<QPDFObjectHandle> const& items);

	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newArray()];
}
+ (ObjcQPDFObjectHandle*)newArrayWithRectangle:(CGRect)rect
{
	return [ObjcQPDFObjectHandle newArrayWithArray:@[]];
}
+ (ObjcQPDFObjectHandle*)newArrayWithMatrix:(id)matrix
{
	return [ObjcQPDFObjectHandle newArrayWithArray:@[]];
}
+ (ObjcQPDFObjectHandle*)newDictionary
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newDictionary()];
}
+ (ObjcQPDFObjectHandle*)newDictionaryWithDictionary:(NSDictionary<NSString*,ObjcQPDFObjectHandle*>*)dict
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newDictionary()];
}

+ (ObjcQPDFObjectHandle*)newStreamForQPDF:(ObjcQPDF*)oQpdf
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newStream([oQpdf qpdf])];
}
+ (ObjcQPDFObjectHandle*)newStreamForQPDF:(ObjcQPDF*)oQpdf withData:(NSData*)data
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newStream([oQpdf qpdf])];
}
+ (ObjcQPDFObjectHandle*)newStreamForQPDF:(ObjcQPDF*)oQpdf withString:(NSString*)data
{
	return [[ObjcQPDFObjectHandle alloc] initWithObject:QPDFObjectHandle::newStream([oQpdf qpdf])];
}


@end
