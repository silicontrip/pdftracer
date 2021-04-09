//
//  QPDFDocument.m
//  pdftracer
//
//  Created by Mark Heath on 28/1/21.
//  Copyright © 2021 silicontrip. All rights reserved.
//

#import "QPDFDocument.h"

#import "OutlineQPDF.h"
#import "OutlineQPDFPage.h"
#import "OutlineQPDFObj.h"
#import "QPDFWindowController.h"
#import "ObjcQPDF.h"

@implementation QPDFDocument

-(instancetype)init
{
	NSLog(@"QPDFD init");
	self=[super init];
	if (self) {
		pDoc = nil;
		[self setFileURL:nil];
		qDocument = [[ObjcQPDF alloc] init];
	}
	return self;
}

// - (instancetype)initWithType:(NSString *)typeName error:(NSError * _Nullable *)outError

- (instancetype)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError
{
	NSLog(@"QPDFD initWithContentsOfURL");

	return [self initForURL:url withContentsOfURL:url ofType:@"PDF" error:outError];
}

- (nullable instancetype)initForURL:(nullable NSURL *)urlOrNil withContentsOfURL:(NSURL *)contentsURL ofType:(NSString *)typeName error:(NSError **)outError
{
	NSLog(@"QPDFD initForURL: %@ %@",urlOrNil,contentsURL);

	self = [super init];
	if (self) {
		[self setFileURL:urlOrNil];
		[self setDisplayName:[urlOrNil description]];

		pDoc = nil;
		qDocument = [[ObjcQPDF alloc] initWithURL:contentsURL];
	}
	return self;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError
{
	NSLog(@"QPDFD readFromURL");

	[self setFileURL:url];
	qDocument = [[ObjcQPDF alloc] initWithURL:url];
	[self setDisplayName:[url description]];
	return YES;
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError
{
	return [[qDocument data] writeToURL:url atomically:YES];
}
 
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error if you return nil.
    // Alternatively, you could remove this method and override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
	if ([typeName isEqualToString:@"QDF"])
		return [qDocument qdf];
	
	return [qDocument data];
	
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error if you return NO.
    // Alternatively, you could remove this method and override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you do, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
	
	qDocument = [[ObjcQPDF alloc] initWithData:data];
	
	return YES;

}

- (void)saveDocument:(nullable id)sender
{
	for (NSWindowController* wc in [self windowControllers])
		[wc setDocumentEdited:NO];
	
	NSError *theError;
	NSURL * fn = [NSURL fileURLWithPath:[qDocument filename]];

	[self writeToURL:fn ofType:@"PDF" error:&theError];
	[self updateChangeCount:NSChangeCleared];
	[[[self windowControllers] firstObject] setDocumentEdited:NO];

}

- (void)saveDocumentAs:(nullable id)sender
{
	NSString * fn = [self displayName];
	
	NSWindow* w = [[[self windowControllers] firstObject] window];

	NSSavePanel* p = [NSSavePanel savePanel];
	[p retain];
	[p setNameFieldStringValue:fn];
	[p beginSheetModalForWindow:w completionHandler:^(NSInteger result){
		if (result == NSModalResponseOK)
		{
			NSURL*  theFile = [p URL];
			NSError *theError;
		//	[self renameDocument:theFile];
			[self writeToURL:theFile ofType:@"PDF" error:&theError];
			// Write the contents in the new format.
			[[[self windowControllers] firstObject] setDocumentEdited:NO];
		}
		[p release];
		//p=nil;
	}];
	if(p)
		[p autorelease];
	[self updateChangeCount:NSChangeCleared];
}

+ (BOOL)autosavesInPlace {
    return NO;
}

- (NSString*)pdfString
{
	return [[[NSString alloc] initWithData:[qDocument data] encoding:NSMacOSRomanStringEncoding] autorelease];
}

- (PDFDocument*)pdfdocument
{
	return [qDocument document];
}

-(void)makeWindowControllers
{
	NSLog(@"QPDFD makeWindowControllers");
	
	NSRect rr = NSMakeRect(10, 10, 1440, 480);  // want better defaults
	NSUInteger windowStyle =  NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable;
	QPDFWindow* w = [[QPDFWindow alloc] initWithContentRect:rr styleMask:windowStyle backing:NSBackingStoreBuffered];
	QPDFWindowController* nwc = [[[QPDFWindowController alloc] initWithWindow:w] autorelease];

	// [w makeKeyAndOrderFront:self];
	[self addWindowController:nwc];
	[nwc initDataSource];

}

- (ObjcQPDF*)doc
{
	return qDocument;
}

- (NSString*)displayName
{
	NSString * fn = [qDocument filename];
	if ([fn isEqualToString:@"empty PDF"])
		return @"Untitled";
	
	return [fn lastPathComponent];
}

- (ObjcQPDFObjectHandle*)replaceIndirect:(ObjcQPDFObjectHandle*)search
{
	
	if ([search isArray])
	{
		for (int w = 0 ; w < [search count]; w++)
		{
			ObjcQPDFObjectHandle* thisObj = [search objectAtIndex:w];
			NSLog(@"%d . %@",w,[thisObj typeName]);
		}
		return nil;

	} else if ([search isDictionary]) {
		int w = 0;
		for (NSString* kk in [search keys])
		{
			ObjcQPDFObjectHandle* thisObj = [search objectForKey:kk];
			NSLog(@"%d . %@",++w,[thisObj typeName]);
		}
		return nil;
	}
	return nil;

}

// this is purely document changing code

- (void)replaceQPDFNode:(QPDFNode*)node withString:(NSString*)editor
{
	// NSLog(@"when does replaceQPDFNode get called?");  // looks like when the textview changes during live editing.
	ObjcQPDFObjectHandle* qpdf = [node object];
	
	if ([editor length]>0)
	{
		if([qpdf isStream])
		{
			[qpdf replaceStreamData:editor];
		}
		else
		{
			NSLog(@"when does replaceQPDFNode get called, other than texteditview changes?");
			NSError* err = NULL;
			NSRegularExpression *indirectRegex = [NSRegularExpression regularExpressionWithPattern:@"\\d+ \\d+ R"
																						   options:0
																							 error:&err];
			NSRange editRange = NSMakeRange(0, [editor length]);
			NSUInteger indirects = [indirectRegex numberOfMatchesInString:editor
																  options:0
																	range:editRange];
			
			// NSLog(@"number of indirects: %lu",indirects);
			
			ObjcQPDFObjectHandle* rePDFObj;
			if (indirects == 0) {
				rePDFObj = [[[ObjcQPDFObjectHandle alloc] initWithString:editor] autorelease];
			} else {
				// safe init
				// turn all indirects into strings
				/*  SO - 9661690
				 NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"&[^;]*;" options:NSRegularExpressionCaseInsensitive error:&error];
				 NSString *modifiedString = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@""];
				*/
				NSString* safeUnparse = [indirectRegex stringByReplacingMatchesInString:editor options:0 range:editRange withTemplate:@"($0)"];
				// rePDFObj = [[[ObjcQPDFObjectHandle alloc] initWithString:safeUnparse] autorelease];
				//NSLog(@"indirect Replace ##########");
				//NSLog(@"%@",safeUnparse);
				
				rePDFObj = [[[ObjcQPDFObjectHandle alloc] initWithString:safeUnparse] autorelease];
				// walk the object and turn back into indirects
				//NSLog(@"type %@",[rePDFObj typeName]);
				[self replaceIndirect:rePDFObj];
				/*
				 QPDFObjectHandle font = doSomethingToGetFont();
				 auto resources = QPDFObjectHandle::parse("<< /Font << >> >>");
				 resources.getKey("/Font").replaceKey("/F1", font);
				 */
				
			}
			// work out if rePDFObj is valid
			
			if ([qpdf isIndirect]) {
				
				NSString* ogi = [qpdf objectGenerationID];
				NSLog(@"Indirect OBJECT at: %@",ogi);
				NSLog(@"With obj: %@ -- %@",rePDFObj,[rePDFObj unparse]);

				[qDocument replaceID:ogi with:rePDFObj];
				
	//			[(QPDFWindowController*)[[self windowControllers] firstObject] invalidateAll];
				
				NSArray<ObjcQPDFObjectHandle*>* objTable= [qDocument objects];
				for (ObjcQPDFObjectHandle* obj in objTable)
					NSLog(@"Object: %@: %@",[obj name],[obj unparse]);
			} else {
				ObjcQPDFObjectHandle* parent = [node parent];

				if ([parent isArray])
				{
					[parent replaceObjectAtIndex:[[node name] integerValue] withObject:rePDFObj];
				} else if ([parent isDictionary]) {
					[parent replaceObject:rePDFObj forKey:[node name]];
				} else  {
					// oh no the dreaded child of neither a dictionary or array and isn't an indirect object either
					NSLog(@"case on: %@",parent);
					NSLog(@"where are we?");
				}
			}
		}
	}
}

- (void)deleteNode:(QPDFNode*)nd
{
	QPDFNode* paNode = [nd parentNode];
	
	//NSLog(@"deletenode:\n %@\nfrom %@",nd,paNode);
	
	if (paNode != nil)
	{
		ObjcQPDFObjectHandle* parent = [paNode object];
		
	//	NSLog(@"delete from type:: %@",[parent typeName]);

	//	NSLog(@"isArray: %d",[parent isArray]);
	//	NSLog(@"isDictionary: %d",[parent isDictionary]);

		// delet from parent
		if ([parent isArray])
		{
			NSLog(@"delete from Array");
			NSLog(@"node name: %@",[nd name]);

			int element = [[nd name] intValue];
			[parent removeObjectAtIndex:element];
			[self updateChangeCount:NSChangeDone];
			[[[self windowControllers] firstObject] setDocumentEdited:YES];

			// delete from array
		} else if ([parent isDictionary]) {
			NSLog(@"delete from Dictionary");

			NSLog(@"node name: %@",[nd name]);
			[parent removeObjectForKey:[nd name]];

			[self updateChangeCount:NSChangeDone];
			// delete from Dictionary
		} else {
			// yet another unknown parent type
			NSLog(@"delete from wha-?");

			NSLog(@"I didn't expect to get here: %@",[parent typeName]);
		}
	} else {
		// top level item.
		ObjcQPDFObjectHandle* tn = [nd object];
		if ([tn isIndirect]) {
			NSString* gen = [tn objectGenerationID];
			[qDocument removeID:gen];
			[self updateChangeCount:NSChangeDone];

		}

	}
}

/*
- (BOOL)respondsToSelector:(SEL)aSelector
{
	NSString* selstr =NSStringFromSelector(aSelector);
	if (![selstr isEqualToString:@"validModesForFontPanel:"])
	{
		NSLog(@"DOC EVENT -> %@",NSStringFromSelector(aSelector));
		if( [NSWindowController instancesRespondToSelector:aSelector] ) {
			// invoke the inherited method
			return YES;
		}
	}
	return NO;
}
*/

@end
