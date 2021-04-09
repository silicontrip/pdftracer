
#import "OutlineQPDFPage.h"

@implementation OutlineQPDFPage

+ (QPDFOutlineView*)newView
{
	NSTableColumn* pdfObjectName = [[[NSTableColumn alloc] initWithIdentifier:@"Name"] autorelease];
	NSTableColumn* pdfObjectType = [[[NSTableColumn alloc] initWithIdentifier:@"Type"] autorelease];
	NSTableColumn* pdfObjectContents = [[[NSTableColumn alloc] initWithIdentifier:@"Value"] autorelease];
	
	
	//Autoresize
	QPDFOutlineView* oView=[[QPDFOutlineView alloc] init];
	// [oView setTranslatesAutoresizingMaskIntoConstraints:NO];
	
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

- (instancetype)initWithPDF:(ObjcQPDF*)pdf
{
	// NSLog(@"OutlinePDFPage initWithPDF: %@_%@",[pdf filename],[pdf version]);
	self = [super init];
	if (self != nil)
	{
		qpDocument = pdf;
	//	pageArray = [[qpDocument pages] retain];
	}
//	NSLog(@"returning self");
	return self;
}

/*
-(void)invalidate
{
	[pageArray release];
	pageArray = [[qpDocument pages] retain];
}
*/
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	if (item == nil) // NULL means Root node
		return YES;
	
	return [[(QPDFNode*)item object] isExpandable];
	
}
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
//	NSLog(@"OutlinePDFPage Number of children");
	
	if (item == nil)
		return [qpDocument countPages];
		//return [pageArray count];
	
	return [[(QPDFNode*)item object] count];
	
}
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	//NSLog(@"- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item");
	if (item == nil)
	{
		return @"Document";
	} else {
		QPDFNode* node = (QPDFNode*)item;
		ObjcQPDFObjectHandle* pdfitem = [node object];
		
		NSString *rs;
		
		if ([[tableColumn identifier] isEqualToString:@"Name"])
			rs = [node name];
		else if ([[tableColumn identifier] isEqualToString:@"Type"])
			rs = [pdfitem typeName];
		else
			rs = [pdfitem unparse];
		
		return rs;
	}
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	
	if (item == nil)
	{
		//ObjcQPDFObjectHandle* pdfitem = [pageArray objectAtIndex:index];
		ObjcQPDFObjectHandle* pdfitem = [qpDocument pageAtIndex:index];
		//QPDFObjectHandle pdfitem =  QPDFObjectHandle(pageArray[index]);
		NSString* lindex = [NSString stringWithFormat:@"Page %d",(int)index+1];

		QPDFNode* sindex =[QPDFNode nodeWithParent:item Named:lindex Handle:pdfitem];
		return sindex;
	}
	ObjcQPDFObjectHandle* pdfitem = [(QPDFNode*)item object];
	
	if ([pdfitem isArray])
	{
		
		//QPDFObjectHandle thisObject =  QPDFObjectHandle( pdfitem.getArrayItem((int)index));
		ObjcQPDFObjectHandle* thisObject =  [pdfitem objectAtIndex:index];
		NSString* lindex = [NSString stringWithFormat:@"%d",(int)index];
		QPDFNode* sindex = [QPDFNode nodeWithParent:item Named:lindex Handle:thisObject];
		
		return sindex;
		
	} else if ([pdfitem isDictionary]) {
		// NSLog(@"obj is dictionary. child:ofItem:");

		NSString* keyIndex = [[pdfitem keys] objectAtIndex:index];
		QPDFNode* nKey = [QPDFNode nodeWithParent:item Named:keyIndex Handle:[pdfitem objectForKey:keyIndex]];
		return nKey;

	}
	return nil;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"OutlineQPDFPage: %@",[super description]];
}

@end
