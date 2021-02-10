
#import "OutlinePDFObj.hh"

@implementation OutlinePDFObj

- (instancetype)initWithPDF:(QPDF)pdf
{
	std::string fn = pdf.getFilename();
	std::string vr = pdf.getPDFVersion();
	NSLog(@"OutlinePDFObj initWithPDF: %s_%s",fn.c_str(),vr.c_str());
	self = [super init];
	if (self != nil)
	{
		qpDocument = pdf;
	//	QPDFObjectHandle* rootCatalog = new QPDFObjectHandle(pdf->getRoot());
	//	catalog = [[QPDFNode alloc] initWithParent:nil Named:@"" Handle:rootCatalog];

		objTable= qpDocument.getAllObjects();


		//CGPDFDocumentRetain(myDocument);
		// pdfObjectCache = [[NSMutableDictionary alloc] initWithCapacity:3];
		//o pdfNull = [NSValue valueWithPointer:nil];

//    QPDFObjectHandle getObjectByID(int objid, int generation);

		
	}
	return self;
}



- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
//	NSLog(@"outlineView:isItemExpandable: %@",item);
	if (item == nil) // NULL means Root node
	{
		return YES;
	}
	return NO;
	
}
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
//	NSLog(@"OutlinePDFObj Number of children");
	
//	NSLog(@"Object table: %d",objTable.size());
	
	if (item == nil)
		return objTable.size();
	return 0;
}
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	// NSLog(@"- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item");
	if (item == nil)
	{
		return @"Document";
	} else {
		// block cyclic tree branches here?
		
		QPDFNode* node = (QPDFNode*)item;
		QPDFObjectHandle pdfitem = [node object];

		NSString *rs;
		
		if ([[tableColumn identifier] isEqualToString:@"objref"])
			rs = [node name];
		else
			if (pdfitem.isDictionary())
			{
				QPDFObjectHandle type = pdfitem.getKey("/Type");
				if (type.isNull()) {
					rs = @"dictionary";
				} else {
					std::string typeName = type.getName();
					rs = [NSString stringWithFormat:@"dictionary %s",typeName.c_str()];
				}
			} else {
				rs = [NSString stringWithFormat:@"%s",pdfitem.getTypeName()];
			}
		return rs;
		
	}
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
// NSLog(@"child: %ld ofItem:",index);
//	QPDFObjectHandle* pdfitem;
//	QPDFObjectHandle pdfitemAddr;
	
	if (item == nil)
	{
		QPDFObjectHandle pdfitem = objTable[index];
		NSString* lindex = [NSString stringWithFormat:@"%d 0 R",(int)index+1];

		QPDFNode* sindex =[QPDFNode nodeWithParent:item Named:lindex Handle:pdfitem];
		return sindex;
	}
	
	return nil;
}

+ (NSOutlineView*)view
{
	NSTableColumn* pdfObjectObjRef = [[NSTableColumn alloc] initWithIdentifier:@"objref"];
	NSTableColumn* pdfObjectObjRefType = [[NSTableColumn alloc] initWithIdentifier:@"type"];
	
	NSOutlineView* ooView = [[QPDFOutlineView alloc] init];
	[ooView setIndentationPerLevel:16.0];
	[ooView setIndentationMarkerFollowsCell:YES];
	[ooView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
	[ooView setHeaderView:nil];
	[ooView addTableColumn:pdfObjectObjRef];
	[ooView addTableColumn:pdfObjectObjRefType];
	[ooView setOutlineTableColumn:pdfObjectObjRef];
	[ooView setUsesAlternatingRowBackgroundColors:YES];
	
	return ooView;
}

@end
