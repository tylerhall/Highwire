#import <Cocoa/Cocoa.h>


@interface HWMachine : NSObject {
	NSString *guid;
	NSString *hostname;
	NSString *ip;
	NSString *port;
	NSNumber *isConnected;
}

@property (nonatomic, retain) NSString *guid;
@property (nonatomic, retain) NSString *hostname;
@property (nonatomic, retain) NSString *ip;
@property (nonatomic, retain) NSString *port;
@property (nonatomic, retain) NSNumber *isConnected;

@end
