
#import "OutlineQPDFObj.h"

@implementation OutlineQPDFObj

- (instancetype)initWithPDF:(ObjcQPDF*)pdf
{

	self = [super init];
	if (self != nil)
	{
		qpDocument = pdf;
		objTable= [[qpDocument objects] retain];
	}
	return self;
}

- (void)invalidate
{
	// this is needed if an indirect object is replaced
	[objTable release];
	objTable= [[qpDocument objects] retain];
	NSLog(@"Invalidate object table -- %ld",[objTable count]);

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
	//NSLog(@"- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item");
	
	//NSLog(@"Object outline looking for: %@",[tableColumn identifier]);
	
	if (item == nil)
	{
		return @"Document";
	} else {
		// block cyclic tree branches here?
		
		QPDFNode* node = (QPDFNode*)item;
		ObjcQPDFObjectHandle* pdfitem = [node object];

		NSString *rs;
		
		NSString* colid = [tableColumn identifier];
		
		if ([colid isEqualToString:@"objref"]) {
			rs = [node name];
		} else if ([colid isEqualToString:@"type"]) {
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
		} else {
			rs = [pdfitem unparseResolved];
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
	/*
	NSStackView* ovc = [[NSStackView alloc] init];
	
	NSRect segRect = NSMakeRect(0,64,480,23);
	NSSegmentedControl* modify = [[NSSegmentedControl alloc] initWithFrame:segRect];
	[modify setSegmentStyle:NSSegmentStyleSmallSquare];
	[modify setSegmentCount:2];
	[modify setImage:[NSImage imageNamed:NSImageNameAddTemplate] forSegment:0];
	[modify setImage:[NSImage imageNamed:NSImageNameRemoveTemplate] forSegment:1];
	[modify setTrackingMode:NSSegmentSwitchTrackingMomentary];
	[modify setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];

	
	[[[modify subviews] objectAtIndex:0] setAutoresizingMask:NSViewNotSizable];
	[[[modify subviews] objectAtIndex:1] setAutoresizingMask:NSViewNotSizable];
*/
	
	NSTableColumn* pdfObjectObjRef = [[[NSTableColumn alloc] initWithIdentifier:@"objref"] autorelease];
	[pdfObjectObjRef setTitle:@"Object ID"];
	NSTableColumn* pdfObjectObjRefType = [[[NSTableColumn alloc] initWithIdentifier:@"type"] autorelease];
	[pdfObjectObjRefType setTitle:@"Type"];

	NSTableColumn* pdfObjectObjRefVal = [[[NSTableColumn alloc] initWithIdentifier:@"value"] autorelease];
	[pdfObjectObjRefVal setTitle:@"Value"];

	
	NSOutlineView* ooView = [[QPDFOutlineView alloc] init];
	[ooView setIndentationPerLevel:16.0];
	[ooView setIndentationMarkerFollowsCell:YES];
	[ooView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
	//[ooView setHeaderView:nil];
	[ooView addTableColumn:pdfObjectObjRef];
	[ooView addTableColumn:pdfObjectObjRefType];
	[ooView addTableColumn:pdfObjectObjRefVal];
	[ooView setOutlineTableColumn:pdfObjectObjRef];
	[ooView setUsesAlternatingRowBackgroundColors:YES];
	
//	[ovc addView:ooView inGravity:NSStackViewGravityTop];
//	[ovc addView:modify inGravity:NSStackViewGravityBottom];

	//[ooView addSubview:modify];
	
	return ooView;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"OutlineQPDFObj: %@",[super description]];
}

@end
