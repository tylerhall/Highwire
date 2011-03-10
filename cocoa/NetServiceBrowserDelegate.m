
#import "NetServiceBrowserDelegate.h"
#import "HighwireAPI.h"
#import <sys/socket.h>
#import <netinet/in.h>

@implementation NetServiceBrowserDelegate

static NetServiceBrowserDelegate *_sharedObject = nil;

- (id)init
{
    self = [super init];
    services = [[NSMutableArray alloc] init];
    pendingServices = [[NSMutableArray alloc] init];
    searching = NO;
    return self;
}

+ (NetServiceBrowserDelegate *)sharedObject
{
    if(!_sharedObject)
        _sharedObject = [[self alloc] init];
    return _sharedObject;
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    searching = YES;	
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    searching = NO;	
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict
{
    searching = NO;	
    [self handleError:[errorDict objectForKey:NSNetServicesErrorCode]];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	// Ignore UDP services
	NSRange range = [[aNetService type] rangeOfString:@"_udp."];
	if(range.location != NSNotFound) return;
	
	[aNetService setDelegate:self];
	[aNetService resolveWithTimeout:10.0];
	[pendingServices addObject:aNetService];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    [services removeObject:aNetService];
}

- (NSMutableArray *)services
{
	return services;
}

- (void)handleError:(NSNumber *)error
{

}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
	BOOL isLocal = NO;
	for(NSData *addr in [sender addresses])
	{
		for(NSString *addr2 in [[NSHost currentHost] addresses])
		{
			if([[addr host] isEqualToString:addr2])
			{
				isLocal = YES;
			}
		}
	}
	
	if(!isLocal) return;

	NSLog(@"ADDING HW SERVICE: (%@) (%@)", [sender hostName], [sender type]);
	
	[services addObject:sender];
	HighwireAPI *api = [[HighwireAPI alloc] init];
	[api addService:sender];
}

@end

// From: http://stackoverflow.com/questions/882802/get-ip-address-of-arriving-data-package
@implementation NSData (Additions)

- (int)port
{
    int port;
    struct sockaddr *addr;
	
    addr = (struct sockaddr *)[self bytes];
    if(addr->sa_family == AF_INET)
        // IPv4 family
        port = ntohs(((struct sockaddr_in *)addr)->sin_port);
    else if(addr->sa_family == AF_INET6)
        // IPv6 family
        port = ntohs(((struct sockaddr_in6 *)addr)->sin6_port);
    else
        // The family is neither IPv4 nor IPv6. Can't handle.
        port = 0;
	
    return port;
}


- (NSString *)host
{
    struct sockaddr *addr = (struct sockaddr *)[self bytes];
    if(addr->sa_family == AF_INET) {
        char *address = inet_ntoa(((struct sockaddr_in *)addr)->sin_addr);
        if(address)
            return [NSString stringWithUTF8String:address];
    }
    else if(addr->sa_family == AF_INET6) {
        struct sockaddr_in6 *addr6 = (struct sockaddr_in6 *)addr;
        char straddr[INET6_ADDRSTRLEN];
        inet_ntop(AF_INET6, &(addr6->sin6_addr), straddr, sizeof(straddr));
        return [NSString stringWithUTF8String:straddr];
    }
    return nil;
}

@end