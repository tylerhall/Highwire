
#import <Cocoa/Cocoa.h>

@class ASIHTTPRequest;

@interface HighwireAPI : NSObject {
	id delegate;

	NSString * email;
	NSString * password;
	
	NSString * errorMessage;

	NSOperationQueue * queue;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSString * errorMessage;

- (void)login;
- (void)loginSucceeded_Callback:(ASIHTTPRequest *)request;
- (void)loginFailed_Callback:(ASIHTTPRequest *)request;

- (void)registerWithEmail:(NSString *)anEmail andPassword:(NSString *)aPassword;
- (void)registerSucceeded_Callback:(ASIHTTPRequest *)request;
- (void)registerFailed_Callback:(ASIHTTPRequest *)request;

- (void)refreshListOfMachines;
- (void)refreshListOfMachinesSucceeded_Callback:(ASIHTTPRequest *)request;
- (void)refreshListOfMachinesFailed_Callback:(ASIHTTPRequest *)request;

- (void)addThisMachineWithPort:(int)port;
- (void)addThisMachineSucceeded_Callback:(ASIHTTPRequest *)request;
- (void)addThisMachineFailed_Callback:(ASIHTTPRequest *)request;

- (void)removeThisMachine;
- (void)removeThisMachine_Callback:(ASIHTTPRequest *)request;

- (void)addService:(NSNetService *)service;

- (void)removeService:(NSNetService *)service;

- (void)listAllServicesForHost:(NSString *)hostname;
- (void)listAllServicesSucceeded_Callback:(ASIHTTPRequest *)request;
- (void)listAllServicesFailed_Callback:(ASIHTTPRequest *)request;

@end
