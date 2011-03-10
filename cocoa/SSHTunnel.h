
#import <Cocoa/Cocoa.h>


@interface SSHTunnel : NSObject {
	NSTask *theTask;
	NSPipe *thePipe;
	
	id userInfo;
	int theLocalPort;
	BOOL isConnected;
	BOOL canRelaunch;
}

- (void)createTunnelToHost:(NSString *)host
			 fromLocalPort:(int)localPort 
			 toForeignPort:(int)foreignPort 
			   throughPort:(int)port
			  withUsername:(NSString *)username
			   andPassword:(NSString *)password
				  userInfo:(NSDictionary *)theUserInfo;

- (void)relaunchTask;

- (void)monitorStdOut:(NSNotification *) aNotification;
- (void)terminate;
- (void)reconnect;

- (void)tunnelDidDie;

- (void)success;
- (void)failure;

- (id)userInfo;
- (int)port;
- (BOOL)isConnected;

@end
