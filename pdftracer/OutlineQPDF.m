
#import "OutlineQPDF.h"

@implementation OutlineQPDF

- (instancetype)initWithPDF:(ObjcQPDF*)pdf
{
	self = [super init];
	if (self)
	{
		qpDocument = pdf;
		catalog = [qpDocument copyRootCatalog];
		 // catalog = [[QPDFNode alloc] initWithParent:nil Named:@"CATALOG" Handle:rootCatalog];
	}
	return self;
}

- (void)invalidate
{
	[catalog release];
	catalog = [qpDocument copyRootCatalog];

}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	if (item == nil) // NULL means Root node
		return YES;
	
	return [(ObjcQPDFObjectHandle*)item isExpandable];
}

- (NSUInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (item == nil)
		item = catalog;

	ObjcQPDFObjectHandle*  pdfitem  = (ObjcQPDFObjectHandle*)item;
	
	if ([pdfitem isArray])
	{
		NSUInteger itemCount = [pdfitem count];
		return itemCount;
	}
	if ([pdfitem isDictionary])
	{
		long count = [pdfitem count];
		return count;
	}
	return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	if (item == nil)
	{
		return @"Document";
	} else {
		// block cyclic tree branches here?
		
		// QPDFNode* node = (QPDFNode*)item;
		ObjcQPDFObjectHandle* pdfitem = (ObjcQPDFObjectHandle*)item;

		NSString *rs;
		
		if ([[tableColumn identifier] isEqualToString:@"Name"])
		{
			rs = [pdfitem elementName];
		}
		else if ([[tableColumn identifier] isEqualToString:@"Type"]) {
			rs = [pdfitem typeName];
		} else {
			if ([pdfitem isStream])
			{
				ObjcQPDFObjectHandle* streamDict = [pdfitem streamDictionary];
				rs = [streamDict unparse];
			} else {
				rs = [pdfitem unparse];
			}
		}
		return rs;
		
	}
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	
	if (item == nil)
		item = catalog;
	
	ObjcQPDFObjectHandle* pdfitem = (ObjcQPDFObjectHandle*)item;
	
	if ([pdfitem isArray])
	{
		ObjcQPDFObjectHandle* thisObject = [pdfitem objectAtIndex:index];
		
		NSString* lindex = [NSString stringWithFormat:@"%d",(int)index];
		[thisObject setElementName:lindex];
		[thisObject setParent:pdfitem];
		//QPDFNode* sindex =[QPDFNode nodeWithParent:item Named:lindex Handle:thisObject];
		
		return thisObject;
	} else if ([pdfitem isDictionary]) {

		int loopindex=0;
		for(NSString* iterKey in [pdfitem keys])
		{
			if (loopindex == index)
			{
				ObjcQPDFObjectHandle* thisObject = [pdfitem objectForKey:iterKey];
				[thisObject setElementName:iterKey];
				[thisObject setParent:pdfitem];
				// QPDFNode* nKey = [QPDFNode nodeWithParent:item Named:iterKey Handle:thisObject];
				return thisObject;
			}
			++loopindex;
		}
	
	}
	return nil;
}

+ (QPDFOutlineView*)newView
{
	NSTableColumn* pdfObjectName = [[[NSTableColumn alloc] initWithIdentifier:@"Name"] autorelease];
	[pdfObjectName setTitle:@"Name"];
	NSTableColumn* pdfObjectType = [[[NSTableColumn alloc] initWithIdentifier:@"Type"] autorelease];
	[pdfObjectType setTitle:@"Type"];
	NSTableColumn* pdfObjectContents = [[[NSTableColumn alloc] initWithIdentifier:@"Value"] autorelease];
	[pdfObjectContents setTitle:@"Value"];

	// Autoresize
	QPDFOutlineView* oView=[[QPDFOutlineView alloc] init];
	//[oView setTranslatesAutoresizingMaskIntoConstraints:NO];
	
	// All the settings .plist
	[oView setIndentationPerLevel:16.0];
	[oView setIndentationMarkerFollowsCell:YES];
	[oView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
	// [oView setHeaderView:nil];
	[oView addTableColumn:pdfObjectName];
	[oView addTableColumn:pdfObjectType];
	[oView addTableColumn:pdfObjectContents];
	[oView setOutlineTableColumn:pdfObjectName];
	[oView setUsesAlternatingRowBackgroundColors:YES];
	return oView;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"OutlineQPDF: %@",[super description]];
}

@end
