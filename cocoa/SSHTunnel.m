
#import "SSHTunnel.h"

@implementation SSHTunnel

- (void)createTunnelToHost:(NSString *)host
			 fromLocalPort:(int)localPort 
			 toForeignPort:(int)foreignPort 
			   throughPort:(int)port
			  withUsername:(NSString *)username
			   andPassword:(NSString *)password
				  userInfo:(NSDictionary *)theUserInfo;
{
	userInfo = theUserInfo;
	theLocalPort = localPort;
	isConnected = NO;
	canRelaunch = YES;

	// This is to prevent the primary distributed objects tunnel from relaunching and causing a "You are now connected" prompt to appear a second time.
	// We don't actually care if the main one goes down anyway.
	if([theUserInfo valueForKey:@"shouldReconnect"] && [[theUserInfo valueForKey:@"shouldReconnect"] boolValue] == NO)
		canRelaunch = NO;
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"TUNNEL_STATUS_DID_CHANGE" object:nil]];
	
	NSString *cmd = [NSString stringWithFormat:@"ssh %@ -L *:%i:127.0.0.1:%i -l %@ -p %i", host, localPort, foreignPort, username, port];
	
	theTask = [[NSTask alloc] init];
	thePipe = [[NSPipe alloc] init];
	
	[theTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"ssh" ofType:@"sh"]];
	[theTask setArguments:[NSArray arrayWithObjects:cmd, password, nil]];
	[theTask setStandardOutput:thePipe];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(monitorStdOut:)
												 name:NSFileHandleReadCompletionNotification
											   object:[[theTask standardOutput] fileHandleForReading]];

	[[[theTask standardOutput] fileHandleForReading] readInBackgroundAndNotify];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(tunnelDidDie)
												 name:@"NSTaskDidTerminateNotification" 
											   object:theTask];

	[theTask launch];
}

- (void)relaunchTask
{
	NSString *launchPath = [theTask launchPath];
	NSArray *args = [theTask arguments];
	
	theTask = nil;
	thePipe = nil;

	theTask = [[NSTask alloc] init];
	thePipe = [[NSPipe alloc] init];
	
	[theTask setLaunchPath:launchPath];
	[theTask setArguments:args];
	[theTask setStandardOutput:thePipe];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(monitorStdOut:)
												 name:NSFileHandleReadCompletionNotification
											   object:[[theTask standardOutput] fileHandleForReading]];
	
	[[[theTask standardOutput] fileHandleForReading] readInBackgroundAndNotify];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(tunnelDidDie)
												 name:@"NSTaskDidTerminateNotification" 
											   object:theTask];
	
	[theTask launch];
}

- (void)monitorStdOut:(NSNotification *)aNotification
{
	NSData *data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
	NSString *strData =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSPredicate *checkError	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'HW_ERROR'"];
	NSPredicate *checkWrongPass	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'HW_WRONG'"];
	NSPredicate *checkConnected	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'HW_OK'"];
	NSPredicate *checkRefused	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'HW_REFUSED'"];
	
	// NSLog(@"monitorStdOut");
	if([data length])
	{
		if([checkError evaluateWithObject:strData] == YES)
		{
			NSLog(@"Unknown error");
			canRelaunch = NO;
			[self failure];
		}
		else if([checkWrongPass evaluateWithObject:strData] == YES)
		{
			NSLog(@"Bad password");
			canRelaunch = NO;
			[self failure];
		}
		else if([checkRefused evaluateWithObject:strData] == YES)
		{
			NSLog(@"Refused");
			canRelaunch = NO;
			[self failure];
		}
		else if([checkConnected evaluateWithObject:strData] == YES)
		{
			NSLog(@"Connected");
			[self success];
		}
		else
		{
			[[thePipe fileHandleForReading] readInBackgroundAndNotify];
			// NSLog(@"read in background");
		}

		data = nil;
		strData = nil;
		checkError = nil;
		checkWrongPass = nil;
		checkConnected = nil;
		checkRefused = nil;
	}
}

- (void)success
{
	isConnected = YES;
	if(userInfo) {
		id obj = [userInfo valueForKey:@"object"];
		[obj performSelector:(SEL)[userInfo valueForKey:@"success"]];
	}

	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"TUNNEL_STATUS_DID_CHANGE" object:nil]];
}

- (void)failure
{
	isConnected = NO;
	if(userInfo) {
		id obj = [userInfo valueForKey:@"object"];
		[obj performSelector:(SEL)[userInfo valueForKey:@"failure"]];
	}	

	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"TUNNEL_STATUS_DID_CHANGE" object:nil]];
}

- (void)tunnelDidDie
{
	isConnected = NO;
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"TUNNEL_STATUS_DID_CHANGE" object:nil]];
	
	if(canRelaunch)
		[self relaunchTask];
}

- (void)reconnect
{
	canRelaunch = YES;
	[self relaunchTask];
	NSNetService *aService = [userInfo valueForKey:@"service"];
	if(aService) [aService publish];
}

- (void)terminate
{
	canRelaunch = NO;
	[theTask terminate];

	NSNetService *aService = [userInfo valueForKey:@"service"];
	if(aService) [aService stop];
}

- (id)userInfo
{
	return userInfo;
}

- (int)port
{
	return theLocalPort;
}

- (BOOL)isConnected
{
	return isConnected;
}

@end
