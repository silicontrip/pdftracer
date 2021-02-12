#import "Arguments.h"
@implementation Arguments

+ (instancetype)argumentsWithCount:(int)argc values:(char*const*)argv
{
	return [[[Arguments alloc] initWithArgOptions:@"" Count:argc Values:argv] autorelease];
}

+ (instancetype)argumentsWithOptions:(NSString*)opt count:(int)argc values:(char*const*)argv
{
	return [[[Arguments alloc] initWithArgOptions:opt Count:argc Values:argv] autorelease];
}

+ (id)argumentsWithArgOptions:(NSString*)arg Count:(int)argc Values:(char*const*)argv
{
	return [[[Arguments alloc] initWithArgOptions:arg Count:argc Values:argv] autorelease];
}

-(id) initWithArgOptions:(NSString *)arg Count:(int)argc Values:(char*const*)argv
{
	self = [super init];
	if (self) {
		NSMutableDictionary* toptions = [NSMutableDictionary dictionaryWithCapacity:3];
		NSMutableArray *targuments = [NSMutableArray arrayWithCapacity:3];
		if (argc > 0)
		{
			int k;

			while ((k=getopt(argc,argv,[arg UTF8String])) != -1)
			{

			NSString* strarg = [NSString stringWithFormat:@"%c",k];

				if (optarg==NULL)
				{

					[toptions setObject:@"" forKey:strarg];
				} else {

					NSString* stropt = [NSString stringWithUTF8String:optarg];
					[toptions setObject:stropt forKey:strarg];
				}
				// the rest are positional arguments
			}

			argc -= optind;
			argv += optind;
			for (int i=0; i < argc; ++i)
				[targuments addObject:[NSString stringWithUTF8String:argv[i]]];
			options = [NSDictionary dictionaryWithDictionary:toptions];
			arguments = [NSArray arrayWithArray:targuments];
		}
	}
	return self;
}

-(NSUInteger)countOptions
{
	return [options count];
}
-(NSUInteger)countArguments
{
	return [arguments count];
}
-(NSUInteger)countPositionalArguments
{
	return [arguments count];
}

-(NSString*)argumentAt:(NSUInteger)i
{
	return [arguments objectAtIndex:i];
}

-(NSString*)positionalArgumentAt:(NSUInteger)i
{
	return [arguments objectAtIndex:i];
}

-(NSString*)stringFor:(NSString *)arg
{
	return [options objectForKey:arg];
}
-(BOOL)hasOption:(NSString*)opt
{
	return ([options objectForKey:opt] != nil);
}

- (NSUInteger)count { return [self countOptions] + [self countPositionalArguments]; }


@end
