
#import "TunnelStatusController.h"


@implementation TunnelStatusController

- (id)init
{
	[super init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tunnelStatusDidChange) name:@"TUNNEL_STATUS_DID_CHANGE" object:nil];

	services = [[NSMutableDictionary alloc] init];
	NSArray *plist = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Services" ofType:@"plist"]];
	for(NSDictionary *dict in plist)
		[services setValue:[dict valueForKey:@"Name"] forKey:[dict valueForKey:@"Service"]];
	
	return self;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	SSHTunnelManager *tm = [SSHTunnelManager sharedObject];
	return [[tm tunnels] count] - 1;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	SSHTunnelManager *tm = [SSHTunnelManager sharedObject];
	NSDictionary *info = [[[tm tunnels] objectAtIndex:rowIndex + 1] userInfo];

	NSNetService *service = [info valueForKey:@"service"];

	if([[aTableColumn identifier] isEqualToString:@"destination"])
	{
		return [service name];
	}
	else if([[aTableColumn identifier] isEqualToString:@"type"])
	{
		return [service type];
	}
	else if([[aTableColumn identifier] isEqualToString:@"port"])
	{
		return [NSString stringWithFormat:@"%d", [service port]];
	}
	
	return @"";
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if([aCell isKindOfClass:[COTImageRow class]])
	{
		SSHTunnelManager *tm = [SSHTunnelManager sharedObject];
		
		if([[[tm tunnels] objectAtIndex:rowIndex] isConnected])
			[(COTImageRow *)aCell setImageName:@"green"];
		else
			[(COTImageRow *)aCell setImageName:@"red"];
	}
}

- (void)menuNeedsUpdate:(NSMenu *)menu
{
	SSHTunnelManager *tm = [SSHTunnelManager sharedObject];

	if([[[tm tunnels] objectAtIndex:[theTable selectedRow]] isConnected])
	{
		[menuItemConnect setHidden:YES];
		[menuItemDisconnect setHidden:NO];
	}
	else
	{
		[menuItemConnect setHidden:NO];
		[menuItemDisconnect setHidden:YES];
	}
}

- (void)tunnelStatusDidChange
{
	[theTable reloadData];
}

- (IBAction)connectSelectedTunnel:(id)sender
{
	SSHTunnelManager *tm = [SSHTunnelManager sharedObject];
	SSHTunnel *tunnel = [[tm tunnels] objectAtIndex:[theTable selectedRow]];
	[tunnel reconnect];
}

- (IBAction)disconnectSelectedTunnel:(id)sender
{
	SSHTunnelManager *tm = [SSHTunnelManager sharedObject];
	SSHTunnel *tunnel = [[tm tunnels] objectAtIndex:[theTable selectedRow]];
	[tunnel terminate];
}

@end
