
#import "OutlineQPDF.hh"

@implementation OutlineQPDF

- (instancetype)initWithPDF:(QPDF)pdf
{
	std::string fn = pdf.getFilename();
	std::string vr = pdf.getPDFVersion();
	std::stringstream buffer;

	// buffer << pdf;
	
	NSLog(@"OutlineQPDF initWithPDF: %s_%s",fn.c_str(),vr.c_str());
	
	self = [super init];
	if (self)
	{
		qpDocument = pdf;
		QPDFObjectHandle rootCatalog = pdf.getRoot();
		NSLog(@"make catalog");
		catalog = [[QPDFNode alloc] initWithParent:nil Named:@"" Handle:rootCatalog];
		
		//CGPDFDocumentRetain(myDocument);
		// pdfObjectCache = [[NSMutableDictionary alloc] initWithCapacity:3];
		// pdfNull = [NSValue valueWithPointer:nil];
		NSLog(@"return self");
	}
	return self;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
//	NSLog(@"outlineView:isItemExpandable: %@",item);
	if (item == nil) // NULL means Root node
		return YES;
	
	QPDFObjectHandle pdfitem = [(QPDFNode*)item object];
	
	return (pdfitem.isArray() || pdfitem.isDictionary());
	
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	NSLog(@"OutlineQPDF Number of children");
	
	if (item == nil)
		item = catalog;

	QPDFObjectHandle  pdfitem  = [(QPDFNode*)item object];
	
	if (pdfitem.isArray())
	{
		int itemCount = pdfitem.getArrayNItems();
		NSLog(@"pdfitem array length: %d",itemCount);
		return itemCount;
	}
	if (pdfitem.isDictionary())
	{
		long count = pdfitem.getKeys().size();
		NSLog(@"pdfitem dictionary length: %ld",count);

		return count;
	}
	return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	//NSLog(@"- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item");
	if (item == nil)
	{
		return @"Document";
	} else {
		// block cyclic tree branches here?
		
		QPDFNode* node = (QPDFNode*)item;
		QPDFObjectHandle pdfitem = [node object];

		NSString *rs;
		
		if ([[tableColumn identifier] isEqualToString:@"Name"])
			rs = [node name];
		else if ([[tableColumn identifier] isEqualToString:@"Type"])
			rs = [NSString stringWithFormat:@"%s",pdfitem.getTypeName()];
		else
			rs= [NSString stringWithFormat:@"%s",pdfitem.unparse().c_str()];

		return rs;
		
	}
}

void getStream(QPDFObjectHandle qpdf) {
	if (qpdf.isStream()) {
		PointerHolder<Buffer> bufRef = qpdf.getStreamData();
		Buffer* buf = bufRef.getPointer();
		size_t sz = buf->getSize();
		unsigned char * bb = buf->getBuffer();
		
		NSLog(@"buffer size: %ld addr: %x",sz,bb);
			
		for (int i=0; i<sz;++i)
		{
			printf("%d ",*(bb+i));
		}
			
			// NSError* writeError;
			// NSData* dd = [[NSData alloc] initWithBytes:bb length:sz];
		NSString* objText= [[[NSString alloc] initWithBytes:bb length:sz encoding:NSMacOSRomanStringEncoding ] autorelease];
			
		NSLog(@"=======: %@",objText);
	}
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
// NSLog(@"child: %ld ofItem:",index);
//	QPDFObjectHandle* pdfitem;
//	QPDFObjectHandle pdfitemAddr;
	
	if (item == nil)
		item = catalog;
	
	QPDFObjectHandle pdfitem = [(QPDFNode*)item object];
	
	if (pdfitem.isArray())
	{
		QPDFObjectHandle thisObject = pdfitem.getArrayItem((int)index);
		
		getStream(thisObject);

		NSString* lindex = [NSString stringWithFormat:@"%d",(int)index];
		QPDFNode* sindex =[QPDFNode nodeWithParent:item Named:lindex Handle:thisObject];
		
		return sindex;
		
	} else if (pdfitem.isDictionary()) {
		// NSLog(@"obj is dictionary. child:ofItem:");
		
		std::set<std::string> keys = pdfitem.getKeys();  // I need this to be order preserving.
		std::vector<std::string> ord(keys.begin(), keys.end());
		std::set<std::string>::iterator iterKey;
		int loopindex=0;
		for(iterKey = keys.begin(); iterKey != keys.end(); ++iterKey)
		{
			if (loopindex == index)
			{
				QPDFObjectHandle thisObject = pdfitem.getKey(*iterKey);
				getStream(thisObject);

				NSString* sKey = [NSString stringWithUTF8String:iterKey->c_str()];
				QPDFNode* nKey = [QPDFNode nodeWithParent:item Named:sKey Handle:thisObject];
				return nKey;
			}
			++loopindex;
		}

	
	}
	return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	// NSLog(@"setObjectValue");
	// NSLog(@"Column: %@ item: %@ value %@",tableColumn, item, object);
	
	QPDFNode* node = (QPDFNode*)item;  // node item for selected row
	
	QPDFObjectHandle parent = [node parent]; // parent object
//	if ([tableColumn isKindOfClass:[NSOutlineView class ]])
//	{
		NSString* col = [tableColumn identifier]; // which column was edited.
		NSString* name = [node name];  // dictionary key or array index value
		NSString* newValue = (NSString*)object;  // name, (type), value
	
		std::string *qpdfValue = new std::string([newValue UTF8String]);
		
	//	NSLog(@"name in parent: %@",name);
		
		if ([col isEqualToString:@"Name"])
		{
			// this only makes sense if it's a dictionary
			// keep old object,
			// rs = object;
			if (parent.isDictionary()) {
				parent.removeKey([name UTF8String]);
				parent.replaceKey(*qpdfValue, [node object]);
			} else {
				NSLog(@"Not CHANGING");
			}
		}
		else if ([col isEqualToString:@"Type"])
		{
			// rs = [NSString stringWithFormat:@"%s",pdfitem->getTypeName()];
			// can't do much about changing the type
		}
		else
		{// if (pdfitem->isScalar())
			// rs= [NSString stringWithFormat:@"%s",pdfitem->unparse().c_str()];
			try {
				QPDFObjectHandle newobj = QPDFObjectHandle::parse(*qpdfValue);
			
				if (parent.isArray())
				{
				//	NSLog(@"index name: %@",name);
					int index = (int)[name integerValue];
					parent.setArrayItem(index, newobj);
					
				} else if (parent.isDictionary()) {
					
			//		NSLog(@"REPLACING dictionary key %@",name);
					std::string key([name UTF8String]);
					parent.replaceKey(key, newobj);

					//parent->removeKey([name UTF8String]);
					//parent->
					
				} else {
					// who's your daddy?
					NSLog(@"parent is not dictionary or array");  // so wtf is it?
				}
			} catch (const std::exception& e) {
					NSLog(@"error parsing");
			}
		}
//	}
	
}

+ (NSOutlineView*)view
{
	NSTableColumn* pdfObjectName = [[NSTableColumn alloc] initWithIdentifier:@"Name"];
	NSTableColumn* pdfObjectType = [[NSTableColumn alloc] initWithIdentifier:@"Type"];
	NSTableColumn* pdfObjectContents = [[NSTableColumn alloc] initWithIdentifier:@"Value"];
	
	NSOutlineView* oView=[[NSOutlineView alloc] init];
	// All the settings .plist
	[oView setIndentationPerLevel:16.0];
	[oView setIndentationMarkerFollowsCell:YES];
	[oView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
	[oView setHeaderView:nil];
	[oView addTableColumn:pdfObjectName];
	[oView addTableColumn:pdfObjectType];
	[oView addTableColumn:pdfObjectContents];
	[oView setOutlineTableColumn:pdfObjectName];
	[oView setUsesAlternatingRowBackgroundColors:YES];
	return oView;
}


@end
