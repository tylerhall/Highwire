
#import "SupportedServicesController.h"


@implementation SupportedServicesController

- (id)init
{
	[super init];
	services = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Services" ofType:@"plist"]];
	return self;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [services count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSDictionary *service = [services objectAtIndex:rowIndex];
	
	if([[aTableColumn identifier] isEqualToString:@"name"])
		return [service valueForKey:@"Name"];
	else
		return [service valueForKey:@"Service"];
}

@end
