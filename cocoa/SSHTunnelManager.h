
#import <Foundation/Foundation.h>
#import "SSHTunnel.h"

@interface SSHTunnelManager : NSObject {
	NSMutableArray *tunnels;
	id delegate;
}

@property (nonatomic, retain) id delegate;

+ (SSHTunnelManager *)sharedObject;

- (void)createTunnelToHost:(NSString *)host
			 fromLocalPort:(int)localPort 
			 toForeignPort:(int)foreignPort 
			   throughPort:(int)port
			  withUsername:(NSString *)username
			   andPassword:(NSString *)password
				  userInfo:(NSDictionary *)theUserInfo;

- (void)closeAllTunnels;
- (NSArray *)tunnels;

@end
