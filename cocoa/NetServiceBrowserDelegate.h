
#import <Cocoa/Cocoa.h>

@interface NetServiceBrowserDelegate : NSObject {
    // Keeps track of available services	
    NSMutableArray *services;
	NSMutableArray *pendingServices;

    // Keeps track of search status
    BOOL searching;
}

+ (NetServiceBrowserDelegate *)sharedObject;

// NSNetServiceBrowser delegate methods for service browsing
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser;
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser;
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict;
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;

- (NSMutableArray *)services;

// Other methods
- (void)handleError:(NSNumber *)error;
@end
