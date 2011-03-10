
#import <Cocoa/Cocoa.h>
#import "SSHTunnelManager.h"
#import "SSHTunnel.h"
#import "COTImageRow.h"

@interface TunnelStatusController : NSObject {
	IBOutlet NSTableView *theTable;
	NSMutableDictionary *services;
	
	IBOutlet NSMenuItem *menuItemConnect;
	IBOutlet NSMenuItem *menuItemDisconnect;
}

- (IBAction)connectSelectedTunnel:(id)sender;
- (IBAction)disconnectSelectedTunnel:(id)sender;

@end
