
#import <Cocoa/Cocoa.h>
#import "LoginWindowController.h"
#import "MainWindowController.h"
#import <CommonCrypto/CommonDigest.h>

@interface HighwireAppDelegate : NSObject {
	LoginWindowController *loginController;
	MainWindowController *mainController;

	IBOutlet NSWindow *windowConnections;
}

- (void)showMainWindow;
- (IBAction)showConnectionsWindow:(id)sender;
- (IBAction)reopenMainWindow:(id)sender;

- (IBAction)manualConnect:(id)sender;

- (IBAction)signOut:(id)sender;
- (IBAction)toggleStatusItem:(id)sender;

@end
