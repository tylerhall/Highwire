
#import <Cocoa/Cocoa.h>
#import <BWToolkitFramework/BWToolkitFramework.h>
#import <TCMPortMapper/TCMPortMapper.h>
#import "NetServiceBrowserDelegate.h"
#import "SSHTunnelManager.h"

@class HighwireAPI;

@interface MainWindowController : NSWindowController {
	IBOutlet NSArrayController *machines;
	IBOutlet BWSheetController *sheetShutdown;
	IBOutlet NSProgressIndicator *piShutdown;
	IBOutlet NSButton *btnStartSharing;
	IBOutlet NSTextField *txtSharingStatus;
	IBOutlet NSProgressIndicator *piStartSharing;
	IBOutlet BWSheetController *sheetRemoteLogin;
	IBOutlet NSTextField *txtRemoteUsername;
	IBOutlet NSTextField *txtRemotePassword;
	IBOutlet NSProgressIndicator *piRemoteLogin;
	IBOutlet NSButton *btnConnect;
	IBOutlet NSButton *btnRemoteLogin;
	IBOutlet NSButton *btnRemoteLoginCancel;
	IBOutlet NSTableView *tblMachines;
	IBOutlet BWSheetController *sheetManualConnect;
	IBOutlet NSTextField *txtManualIP;
	IBOutlet NSTextField *txtManualPort;
	IBOutlet NSWindow *windowRemoteLogin;

	NSStatusItem *statusItem;
	NSImage *statusImage;
	IBOutlet NSMenu *statusMenu;
	IBOutlet NSMenuItem *statusMenuItem_StartSharing;
	IBOutlet NSMenu *statusMenuList;
	
	HighwireAPI * api;
	
	int randomPort;
	
	NSTimer *timerRegistration;

	// Client
	NetServiceBrowserDelegate *remoteNSB;
	NSMutableArray *remoteServicesToPublish;

	// Server
	NSConnection *nsbConnection;
	NSMutableArray *nsBrowsers;
}

- (void)refreshListOfMachinesSucceeded:(NSArray *)cpus;
- (void)showShutdownSheet;
- (IBAction)turnOnSharing:(id)sender;
- (IBAction)stopSharing:(id)sender;

- (IBAction)manualConnect:(id)sender;
- (IBAction)manualConnect_Callback:(id)sender;

- (IBAction)connectButtonWasClicked:(id)sender;

- (IBAction)connectToRemoteMachine:(id)sender;
- (IBAction)connectToRemoteMachine_Callback:(id)sender;

- (void)registerWithHighwireService;
- (void)registerDidSucceed;
- (void)registerDidFail;

- (void)openRouterPort:(int)portNumber;
- (void)portMapperDidFinishWork:(NSNotification *)aNotification;

- (void)publishBonjourServicesUsingDO;

- (IBAction)purchase:(id)sender;
- (void)registrationDisconnect;
- (void)registrationDisconnect_Callback:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

- (IBAction)toggleStatusItem:(id)sender;

- (IBAction)showConnections:(id)sender;
- (IBAction)connectToRemoteMachineWasClicked:(id)sender;
@end
