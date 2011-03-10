
#import "SSHTunnelManager.h"


@implementation SSHTunnelManager

@synthesize delegate;

static SSHTunnelManager *_sharedObject = nil;

- (id)init
{
	[super init];
	tunnels = [[NSMutableArray alloc] init];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAllTunnels)
												 name:NSApplicationWillTerminateNotification object:nil];
	return self;
}

+ (SSHTunnelManager *)sharedObject
{
    if(!_sharedObject)
        _sharedObject = [[self alloc] init];
    return _sharedObject;
}

- (void)createTunnelToHost:(NSString *)host
			 fromLocalPort:(int)localPort
			 toForeignPort:(int)foreignPort
			   throughPort:(int)port 
			  withUsername:(NSString *)username 
			   andPassword:(NSString *)password
				  userInfo:(NSDictionary *)theUserInfo
{
	SSHTunnel *tunnel = [[SSHTunnel alloc] init];
	[tunnel createTunnelToHost:host fromLocalPort:localPort toForeignPort:foreignPort throughPort:port withUsername:username andPassword:password userInfo:theUserInfo];
	[tunnels addObject:tunnel];
	[tunnel autorelease];
}

- (void)closeAllTunnels
{
	for(SSHTunnel *tunnel in tunnels) {
		[tunnel terminate];
	}
}

- (NSArray *)tunnels
{
	return tunnels;
}

@end
