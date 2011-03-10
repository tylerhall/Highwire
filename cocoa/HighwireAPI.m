
#import "HighwireAPI.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "HWMachine.h"
#import "NSData+Base64.h"

@implementation HighwireAPI

@synthesize delegate;
@synthesize errorMessage;

- (id)init
{
	[super init];
	queue = [[NSOperationQueue alloc] init];
	return self;
}

#pragma mark -
#pragma mark Login
#pragma mark -

- (void)login
{
	email = [[NSUserDefaults standardUserDefaults] valueForKey:@"hwEmail"];
	password = [[NSUserDefaults standardUserDefaults] valueForKey:@"hwPassword"];

	NSString *urlStr = [NSString stringWithFormat:@"http://api.highwireapp.com?method=login&email=%@&password=%@", email, password];
	NSURL *url = [NSURL URLWithString:urlStr];

	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(loginSucceeded_Callback:)];
	[request setDidFailSelector:@selector(loginFailed_Callback:)];
	[queue addOperation:request];
}

- (void)loginSucceeded_Callback:(ASIHTTPRequest *)request
{
	SBJSON *json = [[SBJSON alloc] init];
	NSDictionary *dict = [json objectWithString:[request responseString]];

	if([dict valueForKey:@"success"])
		[self.delegate performSelector:@selector(loginWasSuccessful)];
	else
	{
		self.errorMessage = [dict valueForKey:@"error"];
		[self.delegate performSelector:@selector(loginWasUnsuccessful)];
	}
}

- (void)loginFailed_Callback:(ASIHTTPRequest *)request
{
	self.errorMessage = @"An unknown error occurred. Please try again.";
	[self.delegate performSelector:@selector(loginWasUnuccessful)];
}

#pragma mark -
#pragma mark Registration
#pragma mark -

- (void)registerWithEmail:(NSString *)anEmail andPassword:(NSString *)aPassword
{
	NSString *urlStr = [NSString stringWithFormat:@"http://api.highwireapp.com?method=createAccount&email=%@&password=%@", anEmail, aPassword];
	NSURL *url = [NSURL URLWithString:urlStr];
	NSLog(@"URL: %@", urlStr);
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(registerSucceeded_Callback:)];
	[request setDidFailSelector:@selector(registerFailed_Callback:)];
	[queue addOperation:request];	
}

- (void)registerSucceeded_Callback:(ASIHTTPRequest *)request
{
	SBJSON *json = [[SBJSON alloc] init];
	NSDictionary *dict = [json objectWithString:[request responseString]];
	
	if([dict valueForKey:@"success"])
		[self.delegate performSelector:@selector(registrationWasSuccessful)];
	else
	{
		self.errorMessage = [dict valueForKey:@"error"];
		[self.delegate performSelector:@selector(registrationWasUnsuccessful)];
	}
}

- (void)registerFailed_Callback:(ASIHTTPRequest *)request
{
	self.errorMessage = @"An unknown error occurred. Please try again.";
	[self.delegate performSelector:@selector(registrationWasUnsuccessful)];
}

#pragma mark -
#pragma mark Refresh List of Machines
#pragma mark -

- (void)refreshListOfMachines
{
	email = [[NSUserDefaults standardUserDefaults] valueForKey:@"hwEmail"];
	password = [[NSUserDefaults standardUserDefaults] valueForKey:@"hwPassword"];
	
	NSString *urlStr = [NSString stringWithFormat:@"http://api.highwireapp.com?method=listAllMachines&email=%@&password=%@", email, password];
	NSURL *url = [NSURL URLWithString:urlStr];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(refreshListOfMachinesSucceeded_Callback:)];
	[request setDidFailSelector:@selector(refreshListOfMachinesFailed_Callback:)];
	[queue addOperation:request];	
}

- (void)refreshListOfMachinesSucceeded_Callback:(ASIHTTPRequest *)request
{
	SBJSON *json = [[SBJSON alloc] init];
	NSDictionary *dict = [json objectWithString:[request responseString]];
	
	NSMutableArray *cpus = [[NSMutableArray alloc] init];
	for(NSDictionary *cpuDict in [dict objectForKey:@"cpus"]) {
		HWMachine *cpu = [[HWMachine alloc] init];
		cpu.guid = [cpuDict objectForKey:@"guid"];
		cpu.hostname = [cpuDict objectForKey:@"hostname"];
		cpu.ip = [cpuDict objectForKey:@"ip"];
		cpu.port = [cpuDict objectForKey:@"port"];
		[cpus addObject:cpu];
	}
	
	[self.delegate performSelector:@selector(refreshListOfMachinesSucceeded:) withObject:cpus];
}

- (void)refreshListOfMachinesFailed_Callback:(ASIHTTPRequest *)request
{
	
}

#pragma mark -
#pragma mark Add Machine
#pragma mark -

- (void)addThisMachineWithPort:(int)port
{
	email = [[NSUserDefaults standardUserDefaults] valueForKey:@"hwEmail"];
	password = [[NSUserDefaults standardUserDefaults] valueForKey:@"hwPassword"];
	
	NSString *urlStr = [NSString stringWithFormat:@"http://api.highwireapp.com?method=addMachine&email=%@&password=%@&hostname=%@&port=%d", email, password, [[NSHost currentHost] name], port];
	NSURL *url = [NSURL URLWithString:urlStr];

	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(addThisMachineSucceeded_Callback:)];
	[request setDidFailSelector:@selector(addThisMachineFailed_Callback:)];
	[queue addOperation:request];
}

- (void)addThisMachineSucceeded_Callback:(ASIHTTPRequest *)request
{
	[self.delegate performSelector:@selector(registerDidSucceed)];
}

- (void)addThisMachineFailed_Callback:(ASIHTTPRequest *)request
{
	[self.delegate performSelector:@selector(registerDidFail)];	
}

#pragma mark -
#pragma mark Remove Machine
#pragma mark -

- (void)removeThisMachine
{
	email = [[NSUserDefaults standardUserDefaults] valueForKey:@"hwEmail"];
	password = [[NSUserDefaults standardUserDefaults] valueForKey:@"hwPassword"];
	
	NSString *urlStr = [NSString stringWithFormat:@"http://api.highwireapp.com?method=removeMachine&email=%@&password=%@&hostname=%@", email, password, [[NSHost currentHost] name]];
	NSURL *url = [NSURL URLWithString:urlStr];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(removeThisMachine_Callback:)];
	[request setDidFailSelector:@selector(removeThisMachine_Callback:)];
	[queue addOperation:request];
}

- (void)removeThisMachine_Callback:(ASIHTTPRequest *)request
{
	[NSApp replyToApplicationShouldTerminate:YES];
}

#pragma mark -
#pragma mark Add Service
#pragma mark -

- (void)addService:(NSNetService *)service
{
	email = [[NSUserDefaults standardUserDefaults] valueForKey:@"hwEmail"];
	password = [[NSUserDefaults standardUserDefaults] valueForKey:@"hwPassword"];
	
	NSString *urlStr = [NSString stringWithFormat:@"http://api.highwireapp.com?method=addService&email=%@&password=%@", email, password];
	NSURL *url = [NSURL URLWithString:urlStr];
	
	NSLog(@"Adding service: %@ %@ %d", [service type], [service name], [service port]);

	NSHost *currentHost = [NSHost currentHost];
	if(currentHost)
	{
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
		[request setPostValue:[currentHost name] forKey:@"hostname"];
		[request setPostValue:[[[service type] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString] forKey:@"type"];
		[request setPostValue:[[[service name] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString] forKey:@"name"];
		[request setPostValue:[[service TXTRecordData] base64EncodedString] forKey:@"txt_record"];
		[request setPostValue:[NSString stringWithFormat:@"%d", [service port]] forKey:@"port"];
		
		[request setDelegate:self];
		[queue addOperation:request];
	}
}

#pragma mark -
#pragma mark Remove Service
#pragma mark -

- (void)removeService:(NSNetService *)service
{
	email = [[NSUserDefaults standardUserDefaults] valueForKey:@"hwEmail"];
	password = [[NSUserDefaults standardUserDefaults] valueForKey:@"hwPassword"];

	NSString *urlStr = [NSString stringWithFormat:@"http://api.highwireapp.com?method=removeService&email=%@&password=%@", email, password];
	NSURL *url = [NSURL URLWithString:urlStr];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:[[NSHost currentHost] name] forKey:@"hostname"];
	[request setPostValue:[[[service type] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString] forKey:@"type"];
	[request setPostValue:[[[service name] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString] forKey:@"name"];

	[request setDelegate:self];
	[queue addOperation:request];
}

#pragma mark -
#pragma mark List All Services
#pragma mark -

- (void)listAllServicesForHost:(NSString *)hostname
{
	email = [[NSUserDefaults standardUserDefaults] valueForKey:@"hwEmail"];
	password = [[NSUserDefaults standardUserDefaults] valueForKey:@"hwPassword"];

	NSString *urlStr = [NSString stringWithFormat:@"http://api.highwireapp.com?method=listAllServices&email=%@&password=%@&hostname=%@", email, password, hostname];
	NSURL *url = [NSURL URLWithString:urlStr];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(listAllServicesSucceeded_Callback:)];
	[request setDidFailSelector:@selector(listAllServicesFailed_Callback:)];
	[queue addOperation:request];	
}

- (void)listAllServicesSucceeded_Callback:(ASIHTTPRequest *)request
{
	SBJSON *json = [[SBJSON alloc] init];
	NSDictionary *dict = [json objectWithString:[request responseString]];

	[self.delegate performSelector:@selector(listAllServicesSucceeded:) withObject:[dict objectForKey:@"services"]];
}

- (void)listAllServicesFailed_Callback:(ASIHTTPRequest *)request
{
	
}

@end
