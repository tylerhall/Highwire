
#import "HighwireAppDelegate.h"
#import "HighwireAPI.h"

@implementation HighwireAppDelegate

- (void)awakeFromNib
{
	// First run stuff...
	if(![[NSUserDefaults standardUserDefaults] valueForKey:@"firstRun"])
	{
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstRun"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useRandomPort"];
		[[NSUserDefaults standardUserDefaults] setValue:@"64000" forKey:@"sharePort"];
	}
	
	loginController = [[LoginWindowController alloc] initWithWindowNibName:@"LoginWindow"];
	[loginController showWindow:self];	
}

- (void)showMainWindow
{
	mainController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindow"];
	[mainController showWindow:self];
}

- (IBAction)showConnectionsWindow:(id)sender
{
	NSWindow *w = [mainController window];
	
	if(w)
	{
		NSRect newPosition = [w frame];
		newPosition.size = [windowConnections frame].size;
		newPosition.origin.x = [w frame].origin.x + [w frame].size.width + 20;
		newPosition.origin.y = [w frame].origin.y + ([w frame].size.height - newPosition.size.height);	
		[windowConnections setFrame:newPosition display:YES];
	}

	[windowConnections makeKeyAndOrderFront:self];
}

- (IBAction)reopenMainWindow:(id)sender
{
	if(mainController)
		[mainController showWindow:self];
	else
		[loginController showWindow:self];
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication
{
	[self reopenMainWindow:self];
	return NO;
}

- (IBAction)manualConnect:(id)sender
{
	if(mainController)
	{
		[mainController manualConnect:self];
	}
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	if(mainController)
	{
		[mainController showShutdownSheet];

		[[TCMPortMapper sharedInstance] stopBlocking];
		
		HighwireAPI *api = [[HighwireAPI alloc] init];
		api.delegate = self;
		[api removeThisMachine];

		return NSTerminateLater;
	}
	
	return NSTerminateNow;
}

#pragma mark -
#pragma mark Misc
#pragma mark -

- (IBAction)signOut:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"hwEmail"];
	[[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"hwPassword"];

	if(mainController)
	{
		[[mainController window] performClose:self];
		mainController = nil;
	}

	[loginController showWindow:self];
}

- (IBAction)toggleStatusItem:(id)sender
{
	if(mainController)
		[mainController toggleStatusItem:sender];
}

@end
