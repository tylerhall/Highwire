
#import <Cocoa/Cocoa.h>

@class HighwireAPI;

@interface LoginWindowController : NSWindowController {
	// Login
	IBOutlet NSProgressIndicator * piLoginSpinner;
	IBOutlet NSButton * btnLogin;
	IBOutlet NSButton * btnRegister;
	IBOutlet NSTextField * txtEmail;
	IBOutlet NSTextField * txtPassword;
	
	// Registration
	IBOutlet NSProgressIndicator * piRegSpinner;
	IBOutlet NSButton * btnRegRegister;
	IBOutlet NSButton * btnRegCancel;
	IBOutlet NSTextField * txtRegEmail;
	IBOutlet NSTextField * txtRegPassword;
	IBOutlet NSTextField * txtRegPassword2;
	
	HighwireAPI * api;
	
	// View swapping
	IBOutlet NSBox * theBox;
	IBOutlet NSView * viewOne;
	IBOutlet NSView * viewTwo;	
	IBOutlet id viewOneFocus;
	IBOutlet id viewTwoFocus;
}

// Login / Registration Logic
- (IBAction)loginWasClicked:(id)sender;
- (void)loginWasSuccessful;
- (void)loginWasUnsuccessful;

- (IBAction)registerWasClicked:(id)sender;
- (void)registrationWasSuccessful;
- (void)registrationWasUnsuccessful;

- (void)displayErrorSheetWithMessage:(NSString *)message;

// View swapping
- (void)showViewOne:(id)sender;
- (void)showViewTwo:(id)sender;
- (void)swapViews:(id)sender;

@end
