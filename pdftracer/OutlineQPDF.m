
#import "OutlineQPDF.h"

@implementation OutlineQPDF

- (instancetype)initWithPDF:(ObjcQPDF*)pdf
{
	self = [super init];
	if (self)
	{
		qpDocument = pdf;
		ObjcQPDFObjectHandle* rootCatalog = [[qpDocument copyRootCatalog] autorelease];
		catalog = [[QPDFNode alloc] initWithParent:nil Named:@"CATALOG" Handle:rootCatalog];
	}
	return self;
}

- (void)invalidate
{
	[catalog release];
	ObjcQPDFObjectHandle* rootCatalog = [[qpDocument copyRootCatalog] autorelease];
	catalog = [[QPDFNode alloc] initWithParent:nil Named:@"CATALOG" Handle:rootCatalog];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	if (item == nil) // NULL means Root node
		return YES;
	
	return [[(QPDFNode*)item object] isExpandable];
}

- (NSUInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (item == nil)
		item = catalog;

	ObjcQPDFObjectHandle*  pdfitem  = [(QPDFNode*)item object];
	
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
		
		QPDFNode* node = (QPDFNode*)item;
		ObjcQPDFObjectHandle* pdfitem = [node object];

		NSString *rs;
		
		if ([[tableColumn identifier] isEqualToString:@"Name"])
		{
			rs = [node name];
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
	
	ObjcQPDFObjectHandle* pdfitem = [(QPDFNode*)item object];
	
	if ([pdfitem isArray])
	{
		ObjcQPDFObjectHandle* thisObject = [pdfitem objectAtIndex:index];
		
		NSString* lindex = [NSString stringWithFormat:@"%d",(int)index];
		QPDFNode* sindex =[QPDFNode nodeWithParent:item Named:lindex Handle:thisObject];
		
		return sindex;
	} else if ([pdfitem isDictionary]) {

		int loopindex=0;
		for(NSString* iterKey in [pdfitem keys])
		{
			if (loopindex == index)
			{
				ObjcQPDFObjectHandle* thisObject = [pdfitem objectForKey:iterKey];
				QPDFNode* nKey = [QPDFNode nodeWithParent:item Named:iterKey Handle:thisObject];
				return nKey;
			}
			++loopindex;
		}
	
	}
	return nil;
}

/*  Most of this functionality is implemented in the textDidEndEditing 
- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	
	NSLog(@"OutlineQPDF: setObjectValue");
	QPDFNode* node = (QPDFNode*)item;  // node item for selected row
	
	ObjcQPDFObjectHandle* parent = [node parent]; // parent object
	NSString* col = [tableColumn identifier]; // which column was edited.
	NSString* name = [node name];  // dictionary key or array index value
	NSString* newValue = (NSString*)object;  // name, (type), value
	
	if ([col isEqualToString:@"Name"])
	{
			// this only makes sense if it's a dictionary
			// keep old object,
			// rs = object;
		if ([parent isDictionary])
		{
			[parent removeObjectForKey:name];
				[parent replaceObject:[node object] forKey:newValue];
		} else {
			NSLog(@"Not CHANGING");
		}
	}
	else if ([col isEqualToString:@"Type"])
	{
			// can't do much about changing the type
	}
	else
	{
		ObjcQPDFObjectHandle* newobj = [[ObjcQPDFObjectHandle alloc] initWithString:newValue];
		if (newobj) {
			if ([parent isArray])
			{
				[parent replaceObjectAtIndex:[name integerValue] withObject:newobj];
			} else if ([parent isDictionary]) {
				[parent replaceObject:newobj forKey:name];
			} else {
				// who's your daddy?
				NSLog(@"parent is not dictionary or array");  // so wtf is it?
			}
			[newobj autorelease];
		}
	}
}
*/

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
