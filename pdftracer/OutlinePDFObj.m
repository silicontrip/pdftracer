
#import "OutlinePDFObj.h"

@implementation OutlinePDFObj

- (instancetype)initWithPDF:(ObjcQPDF*)pdf
{
	NSString* fn = [pdf filename];
	NSString* vr = [pdf version];
	NSLog(@"OutlinePDFObj initWithPDF: %@_%@",fn,vr);
	
	self = [super init];
	if (self != nil)
	{
		qpDocument = pdf;
		objTable= [[qpDocument objects] retain];
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
		return [objTable count];
	
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
		ObjcQPDFObjectHandle* pdfitem = [node object];

		NSString *rs;
		
		if ([[tableColumn identifier] isEqualToString:@"objref"])
			rs = [node name];
		else
			if ([pdfitem isDictionary])
			{
				ObjcQPDFObjectHandle* type = [pdfitem objectForKey:@"/Type"];
				if ([type isNull]) {
					rs = @"dictionary";
				} else {
					rs = [type name];
				//	std::string typeName = type.getName();
				//rs = [NSString stringWithFormat:@"dictionary %s",typeName.c_str()];
				}
			} else {
				rs = [pdfitem typeName];
				//[NSString stringWithFormat:@"%s",pdfitem.getTypeName()];
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
		ObjcQPDFObjectHandle* pdfitem = [objTable objectAtIndex:index];
		NSString* lindex = [NSString stringWithFormat:@"%d 0 R",(int)index+1];

		QPDFNode* sindex =[QPDFNode nodeWithParent:item Named:lindex Handle:pdfitem];
		return sindex;
	}
	
	return nil;
}

+ (NSOutlineView*)newView
{
	NSTableColumn* pdfObjectObjRef = [[[NSTableColumn alloc] initWithIdentifier:@"objref"] autorelease];
	NSTableColumn* pdfObjectObjRefType = [[[NSTableColumn alloc] initWithIdentifier:@"type"] autorelease];
	
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
