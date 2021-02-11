
#import "OutlinePDFPage.h"

@implementation OutlinePDFPage

+ (NSOutlineView*)view
{
	NSTableColumn* pdfObjectName = [[NSTableColumn alloc] initWithIdentifier:@"Name"];
	NSTableColumn* pdfObjectType = [[NSTableColumn alloc] initWithIdentifier:@"Type"];
//	NSTableColumn* pdfObjectContents = [[NSTableColumn alloc] initWithIdentifier:@"Value"];
	
	NSOutlineView* oView=[[QPDFOutlineView alloc] init];
	// All the settings .plist
	[oView setIndentationPerLevel:16.0];
	[oView setIndentationMarkerFollowsCell:YES];
	[oView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
	[oView setHeaderView:nil];
	[oView addTableColumn:pdfObjectName];
	[oView addTableColumn:pdfObjectType];
	[oView setOutlineTableColumn:pdfObjectName];
	[oView setUsesAlternatingRowBackgroundColors:YES];
	
	return oView;
}

- (instancetype)initWithPDF:(QPDFObjc*)pdf
{
	NSLog(@"OutlinePDFPage initWithPDF: %@_%@",[pdf filename],[pdf PDFVersion]);
	self = [super init];
	if (self != nil)
	{
//		NSLog(@"OutlinePDFPage %@ set qpdf",self);
		qpDocument = pdf;
//		NSLog(@"OutlinePDFPage %@ getAllPages",self);

		pageArray = [pdf pages];
		
//		NSLog(@"Page array len: %ld",pageArray.capacity());
		
		QPDFObjectHandle p1 = pageArray[0];
		
//		NSLog(@"page Array %s",p1.unparse().c_str());

		
		//pageArray = [[QPDFNode alloc] initWithParent:nil Named:@"" Handle:root];
	}
//	NSLog(@"returning self");
	return self;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	//	NSLog(@"outlineView:isItemExpandable: %@",item);
	if (item == nil) // NULL means Root node
	{
		return YES;
	}
	
	return [[(QPDFNode*)item object] isExpandable];
	
}
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
//	NSLog(@"OutlinePDFPage Number of children");
	
	if (item == nil)
		return [pageArray count];
	
	return [[(QPDFNode*)item object] count];
	
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
		QPDFObjectHandleObjc* pdfitem = [node object];
		
		NSString *rs;
		
		if ([[tableColumn identifier] isEqualToString:@"Name"])
			rs = [node name];
		else if ([[tableColumn identifier] isEqualToString:@"Type"])
			rs = [pdfitem typename]; // [NSString stringWithFormat:@"%s",pdfitem.getTypeName()];
		else
			rs = [pdfitem unparse]; // rs= [NSString stringWithFormat:@"%s",pdfitem.unparse().c_str()];
		
		return rs;
		
	}
	// we shouldn't get here (but it is possible if I missed something in the if's above.
	//	return @"Internal Error";
}



- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	
	if (item == nil)
	{
		QPDFObjectHandleObjc* pdfitem = [pageArray objectAtIndex:index];
		//QPDFObjectHandle pdfitem =  QPDFObjectHandle(pageArray[index]);
		NSString* lindex = [NSString stringWithFormat:@"Page %d",(int)index+1];

		QPDFNode* sindex =[QPDFNode nodeWithParent:item Named:lindex Handle:pdfitem];
		return sindex;
	}
	QPDFObjectHandleObjc* pdfitem = [(QPDFNode*)item object];
	
	if ([pdfitem isArray])
	{
		
		//QPDFObjectHandle thisObject =  QPDFObjectHandle( pdfitem.getArrayItem((int)index));
		QPDFObjectHandle* thisObject =  [pdfitem objectAtIndex:index];
		NSString* lindex = [NSString stringWithFormat:@"%d",(int)index];
		QPDFNode* sindex = [QPDFNode nodeWithParent:item Named:lindex Handle:thisObject];
		
		return sindex;
		
	} else if ([pdfitem isDictionary]) {
		// NSLog(@"obj is dictionary. child:ofItem:");

		NSString* keyIndex = [[pdfitem keys] objectForIndex:index];
		QPDFNode* nKey = [QPDFNode nodeWithParent:item Named:keyIndex Handle:thisObject];
		return nKey;
		/*
		std::set<std::string> keys = pdfitem.getKeys();  // I need this to be order preserving.
		std::vector<std::string> ord(keys.begin(), keys.end());
		std::set<std::string>::iterator iterKey;
		int loopindex=0;
		for(iterKey = keys.begin(); iterKey != keys.end(); ++iterKey)
		{
			if (loopindex == index)
			{
				QPDFObjectHandle thisObject =  QPDFObjectHandle(pdfitem.getKey(*iterKey));
				NSString* sKey = [NSString stringWithUTF8String:iterKey->c_str()];
				QPDFNode* nKey = [QPDFNode nodeWithParent:item Named:sKey Handle:thisObject];
				return nKey;
			}
			++loopindex;
		}
	*/	
		
	}
	return nil;
}

@end
