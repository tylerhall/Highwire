
#import "MainWindowController.h"
#import "HWMachine.h"
#import "HighwireAPI.h"
#import "COTImageRow.h"
#import "HighwireAppDelegate.h"
#import "NSData+Base64.h"

#import "sys/socket.h"
#import "netinet/in.h"

@implementation MainWindowController

- (void)awakeFromNib
{
	SSHTunnelManager *tm = [SSHTunnelManager sharedObject];
	tm.delegate = self;
	
	remoteServicesToPublish = [[NSMutableArray alloc] init];
	nsBrowsers = [[NSMutableArray alloc] init];
	
	api = [[HighwireAPI alloc] init];
	api.delegate = self;
	[api refreshListOfMachines];

	if([[[NSUserDefaults standardUserDefaults] valueForKey:@"shareOnStartup"] boolValue])
		[self turnOnSharing:self];
	
	[[self window] makeFirstResponder:tblMachines];
	
	[self toggleStatusItem:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSControlTextDidChangeNotification object:txtRemoteUsername];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSControlTextDidChangeNotification object:txtRemotePassword];
	
	[windowRemoteLogin setAutorecalculatesContentBorderThickness:YES forEdge:NSMinYEdge];
	[windowRemoteLogin setContentBorderThickness: 32.0 forEdge: NSMinYEdge];
}

- (void)refreshListOfMachinesSucceeded:(NSArray *)cpus
{
	for(HWMachine *cpu in cpus) {
		[machines addObject:cpu];
	}
}

- (void)showShutdownSheet
{
	[sheetShutdown openSheet:self];
	[piShutdown startAnimation:self];
}

- (IBAction)turnOnSharing:(id)sender
{
	if([[btnStartSharing title] isEqualToString:@"Stop Sharing"])
	{
		[self stopSharing:self];
		return;
	}
	
	// Test if SSH is running...
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:@"/sbin/service"];
	[task setArguments:[NSArray arrayWithObjects:@"--test-if-configured-on", @"ssh", nil]];
	[task launch];
	[task waitUntilExit];	
	if([task terminationStatus] == 1)
	{
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"Ok"];
		[alert setMessageText:@"Remote Login Not Enabled"];
		[alert setInformativeText:@"Highwire was unable to share this machine because Remote Login is not enabled. Please enable it via System Preferences → Sharing."];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
		return;
	}

	[piStartSharing startAnimation:self];
	[btnStartSharing setEnabled:NO];
	[statusMenuItem_StartSharing setState:NSOnState];

	if([[[NSUserDefaults standardUserDefaults] valueForKey:@"useRandomPort"] boolValue]) {
		srand([[NSDate date] timeIntervalSince1970]);
		randomPort = (rand() % 300) + 62100;
		NSLog(@"Using random port %d", randomPort);
		[self openRouterPort:randomPort];		
	}
	else {
		randomPort = [[[NSUserDefaults standardUserDefaults] valueForKey:@"sharePort"] intValue];
		NSLog(@"Using static port %d", randomPort);
		[self registerWithHighwireService];
		[self publishBonjourServicesUsingDO];
	}
}

- (IBAction)stopSharing:(id)sender
{
	statusImage = [NSImage imageNamed:@"MenubarDisabled"];
	[statusItem setImage:statusImage];
	
	TCMPortMapper *pm = [TCMPortMapper sharedInstance];
	[pm stopBlocking];
	
	[nsbConnection invalidate];
	[nsBrowsers removeAllObjects];
	
	[txtSharingStatus setStringValue:@"Your Mac will be securely shared to other computers running Highwire."];
	[btnStartSharing setTitle:@"Turn on Sharing"];
	[btnStartSharing setEnabled:YES];
	
	[statusMenuItem_StartSharing setState:NSOffState];
}

- (IBAction)manualConnect:(id)sender
{
	[sheetManualConnect openSheet:self];
}

- (IBAction)manualConnect_Callback:(id)sender
{
	[sheetManualConnect closeSheet:self];

	HWMachine *cpu = [[HWMachine alloc] init];
	cpu.ip = [txtManualIP stringValue];
	cpu.port = [txtManualPort stringValue];
	cpu.hostname = @"Manual Connection";
	[machines addObject:cpu];
	
	[self connectToRemoteMachine:self];
}

- (IBAction)connectButtonWasClicked:(id)sender
{
	[self connectToRemoteMachine:sender];
}

- (IBAction)connectToRemoteMachine:(id)sender
{
	[btnRemoteLogin setEnabled:NO];
	[btnRemoteLoginCancel setEnabled:YES];
	[txtRemoteUsername setEnabled:YES];
	[txtRemotePassword setEnabled:YES];
	[txtRemoteUsername setStringValue:@""];
	[txtRemotePassword setStringValue:@""];
	[piRemoteLogin stopAnimation:self];
	
	[sheetRemoteLogin openSheet:self];
	[sheetRemoteLogin.sheet makeFirstResponder:txtRemoteUsername];
}

- (IBAction)connectToRemoteMachine_Callback:(id)sender
{
	[[self window] makeFirstResponder:nil];
	[[self window] endEditingFor:txtRemotePassword];
	
	HWMachine *cpu = [[machines arrangedObjects] objectAtIndex:[machines selectionIndex]];
	
	[btnRemoteLogin setEnabled:NO];
	[btnRemoteLoginCancel setEnabled:NO];
	[txtRemoteUsername setEnabled:NO];
	[txtRemotePassword setEnabled:NO];
	[piRemoteLogin startAnimation:self];
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self, @"object", 
							  @selector(initialConnectionSucceeded), @"success",
							  @selector(initialConnectionFailed), @"failure",
							  [NSNumber numberWithBool:NO], @"shouldReconnect", nil];
	
	// Create an ssh tunnel to our distributed object through our random port
	SSHTunnelManager *tm = [SSHTunnelManager sharedObject];
	[tm createTunnelToHost:cpu.ip
			 fromLocalPort:[cpu.port intValue] + 1
			 toForeignPort:[cpu.port intValue] + 1
			   throughPort:[cpu.port intValue]
			  withUsername:[txtRemoteUsername stringValue]
			   andPassword:[txtRemotePassword stringValue]
				  userInfo:userInfo];
}

- (void)initialConnectionSucceeded
{
	HWMachine *cpu = [[machines arrangedObjects] objectAtIndex:[machines selectionIndex]];
	cpu.isConnected = [NSNumber numberWithBool:YES];
	[tblMachines setNeedsDisplay];
	//[tblMachines deselectAll:self];
	
	[sheetRemoteLogin closeSheet:self];

	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"Ok"];
	[alert setMessageText:@"Success!"];
	[alert setInformativeText:[NSString stringWithFormat:@"You are now connected to %@!", cpu.hostname]];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];

	[api listAllServicesForHost:cpu.hostname];
}

- (void)listAllServicesSucceeded:(NSArray *)services
{	
	HWMachine *cpu = [[machines arrangedObjects] objectAtIndex:[machines selectionIndex]];

	int p = [cpu.port intValue] + 2;
	
	// Re-publish each service locally
	for(NSDictionary *service in services)
	{
		NSString *name = [[NSString alloc] initWithData:[NSData dataFromBase64String:[service valueForKey:@"name"]] encoding:NSUTF8StringEncoding];
		NSString *type = [[NSString alloc] initWithData:[NSData dataFromBase64String:[service valueForKey:@"type"]] encoding:NSUTF8StringEncoding];
		int foreignPort = [[service valueForKey:@"port"] intValue];
		NSLog(@"SERVICE: %@, %@, %d", name, type, foreignPort);
		
		NSNetService *aService = [[NSNetService alloc] initWithDomain:@"" type:type name:[NSString stringWithFormat:@"%@ (Highwire)", name] port:p];
		[aService setTXTRecordData:[NSData dataFromBase64String:[service valueForKey:@"txt_record"]]];
		[aService setDelegate:self];
		[aService publish];
		[remoteServicesToPublish addObject:aService];
		
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:aService, @"service", nil];
		
		// Create an ssh tunnel for each service
		SSHTunnelManager *tm = [SSHTunnelManager sharedObject];
		[tm createTunnelToHost:cpu.ip
				 fromLocalPort:p
				 toForeignPort:foreignPort
				   throughPort:[cpu.port intValue]
				  withUsername:[txtRemoteUsername stringValue]
				   andPassword:[txtRemotePassword stringValue]
					  userInfo:userInfo];
		
		p++;
	}	

	// Connect to our nsb object and retrieve list of available services
	// NSSocketPort *port = [[NSSocketPort alloc] initRemoteWithTCPPort:([cpu.port intValue] + 1) host:@"127.0.0.1"];
	// NSConnection *connection = [NSConnection connectionWithReceivePort:nil sendPort:port];
	// remoteNSB = (NetServiceBrowserDelegate *)[connection rootProxy];
}

- (void)initialConnectionFailed
{
	HWMachine *cpu = [[machines arrangedObjects] objectAtIndex:[machines selectionIndex]];
	cpu.isConnected = [NSNumber numberWithBool:NO];
	[tblMachines setNeedsDisplay];
	
	[sheetRemoteLogin closeSheet:self];

	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"Ok"];
	[alert setMessageText:@"Login Failed"];
	[alert setInformativeText:@"Highwire was unable to login to the remote machine. This could be because of an incorrect login or possibly a network error. Please try again."];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
	return;	
}																								   



#pragma mark -
#pragma mark Distributed Objects Stuff
#pragma mark -

- (void)publishBonjourServicesUsingDO
{
	NetServiceBrowserDelegate *nsb = [NetServiceBrowserDelegate sharedObject];

	// Load our list of known Bonjour services
	NSArray *plist = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Services" ofType:@"plist"]];
	for(NSDictionary *service in plist)
	{
		NSNetServiceBrowser *nsBrowser = [[NSNetServiceBrowser alloc] init];
		[nsBrowser setDelegate:nsb];
		[nsBrowser searchForServicesOfType:[service objectForKey:@"Service"] inDomain:@""];
		[nsBrowsers addObject:nsBrowser];
	}
}

#pragma mark -
#pragma mark HW Registration
#pragma mark -

- (void)registerWithHighwireService
{
	[txtSharingStatus setStringValue:@"Registering with Highwire service..."];
	[api addThisMachineWithPort:randomPort];
}

- (void)registerDidSucceed
{
	[txtSharingStatus setStringValue:@"Your machine is being securely shared."];
	[piStartSharing stopAnimation:self];	
}

- (void)registerDidFail
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"Ok"];
	[alert setMessageText:@"Registration Failed"];
	[alert setInformativeText:@"Highwire was unable to connect to the Highwire web service. Please try again or contact Support for further help."];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
	[txtSharingStatus setStringValue:@""];
	[piStartSharing stopAnimation:self];
	[btnStartSharing setEnabled:YES];
}

#pragma mark -
#pragma mark Port Mapping
#pragma mark -

- (void)openRouterPort:(int)portNumber
{
	[txtSharingStatus setStringValue:@"Opening router port..."];
	
	TCMPortMapper *pm = [TCMPortMapper sharedInstance];
	[pm addPortMapping:[TCMPortMapping portMappingWithLocalPort:22
											desiredExternalPort:portNumber
											  transportProtocol:TCMPortMappingTransportProtocolTCP
													   userInfo:nil]];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(portMapperDidFinishWork:) 
												 name:TCMPortMapperDidFinishWorkNotification 
											   object:pm];

	[pm start];
}

- (void)portMapperDidFinishWork:(NSNotification *)aNotification
{
    TCMPortMapper *pm = [TCMPortMapper sharedInstance];
    TCMPortMapping *mapping = [[pm portMappings] anyObject];

    if([mapping mappingStatus] == TCMPortMappingStatusMapped)
	{
		[self registerWithHighwireService];
		[self publishBonjourServicesUsingDO];
		[btnStartSharing setTitle:@"Stop Sharing"];
		[btnStartSharing setEnabled:YES];
		statusImage = [NSImage imageNamed:@"Menubar"];
		[statusItem setImage:statusImage];
    }
	else
	{
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"Ok"];
		[alert setMessageText:@"Could Not Map Port"];
		[alert setInformativeText:@"Highwire was unable to open a port in your router. Please try again or contact Support for further help."];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
		[txtSharingStatus setStringValue:@""];
		[piStartSharing stopAnimation:self];
		[btnStartSharing setEnabled:YES];
		[statusMenuItem_StartSharing setState:NSOffState];
    }
}

#pragma mark -
#pragma mark -

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if([aCell isKindOfClass:[COTImageRow class]])
	{
		HWMachine *cpu = [[machines arrangedObjects] objectAtIndex:rowIndex];
		
		if([cpu.isConnected boolValue])
			[(COTImageRow *)aCell setImageName:@"green"];
		else
			[(COTImageRow *)aCell setImageName:@"red"];
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	if([notification object] == tblMachines)
	{
		if([machines selectionIndex] != NSNotFound)
		{
			HWMachine *cpu = [[machines arrangedObjects] objectAtIndex:[machines selectionIndex]];
			if([cpu.isConnected boolValue])
				[btnConnect setEnabled:NO];
			else
				[btnConnect setEnabled:YES];
		}
	}
}

- (IBAction)purchase:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://clickontyler.com/highwire/purchase/"]];
}

- (void)registrationDisconnect
{
	[[SSHTunnelManager sharedObject] closeAllTunnels];
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"Purchase..."];
	[alert addButtonWithTitle:@"Quit"];
	[alert setMessageText:@"Please Purchase"];
	[alert setInformativeText:@"Thanks for trying Highwire! To stay connected for more than 10 minutes at a time, please purchase a license. Your support will ensure that Highwire can grow and become better over time."];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(registrationDisconnect_Callback:returnCode:contextInfo:) contextInfo:nil];
}

- (void)registrationDisconnect_Callback:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	if(returnCode == NSAlertFirstButtonReturn)
	{
		[self purchase:self];
	}

	[NSApp terminate:self];
}

- (void)textDidChange:(NSNotification *)aNotification
{
	if([[txtRemoteUsername stringValue] length] > 0 && [[txtRemotePassword stringValue] length] > 0)
		[btnRemoteLogin setEnabled:YES];
	else
		[btnRemoteLogin setEnabled:NO];
}

- (IBAction)toggleStatusItem:(id)sender
{
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"showStatusIcon"])
	{
		statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
		statusImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MenubarDisabled" ofType:@"png"]];
		[statusItem setImage:statusImage];
		[statusItem setAction:@selector(toggleMainWindow:)];
		[statusItem setHighlightMode:YES];
		[statusItem setMenu:statusMenu];
	}
	else if(statusItem)
	{
		[[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
		statusItem = nil;
	}
}

- (IBAction)showConnections:(id)sender
{
	[[NSApp delegate] showConnectionsWindow:self];
}

- (void)menuNeedsUpdate:(NSMenu *)menu
{
	for(NSMenuItem *item in [menu itemArray])
		[menu removeItem:item];
	
	
	for(int i = 0; i < [tblMachines numberOfRows]; i++)
	{
		HWMachine *cpu = [[machines arrangedObjects] objectAtIndex:i];		
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:cpu.hostname action:@selector(connectToRemoteMachineWasClicked:) keyEquivalent:@""];
		[item setTag:i];
		[statusMenuList addItem:item];
	}
}

- (IBAction)connectToRemoteMachineWasClicked:(id)sender
{
	[tblMachines selectRow:[sender tag] byExtendingSelection:NO];
	[self connectToRemoteMachine:self];
}

@end
