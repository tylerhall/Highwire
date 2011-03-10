
#import "LoginWindowController.h"
#import "HighwireAPI.h"
#import "HighwireAppDelegate.h"

@implementation LoginWindowController

- (void)awakeFromNib
{
	[self showViewOne:self];

	api = [[HighwireAPI alloc] init];
	api.delegate = self;

	// This prevents a crash in case the values are nil
	NSString *email = [[NSUserDefaults standardUserDefaults] valueForKey:@"hwEmail"] ? [[NSUserDefaults standardUserDefaults] valueForKey:@"hwEmail"] : @"";
	NSString *pw = [[NSUserDefaults standardUserDefaults] valueForKey:@"hwPassword"] ? [[NSUserDefaults standardUserDefaults] valueForKey:@"hwPassword"] : @"";	
	[txtEmail setStringValue:email];
	[txtPassword setStringValue:pw];
	
	if([email length] > 0 && [pw length] > 0)
		[self loginWasClicked:self];
}

#pragma mark -
#pragma mark Login / Registration Logic
#pragma mark -

- (IBAction)loginWasClicked:(id)sender
{
	[[self window] makeFirstResponder:[self window]];
	
	[piLoginSpinner startAnimation:self];
	[btnLogin setEnabled:NO];
	[btnRegister setEnabled:NO];
	[txtEmail setEnabled:NO];
	[txtPassword setEnabled:NO];
	
	[[NSUserDefaults standardUserDefaults] setValue:[txtEmail stringValue] forKey:@"hwEmail"];
	[[NSUserDefaults standardUserDefaults] setValue:[txtPassword stringValue] forKey:@"hwPassword"];
	
	[api login];
}

- (void)loginWasSuccessful
{
	[piLoginSpinner stopAnimation:self];
	[btnLogin setEnabled:YES];
	[btnRegister setEnabled:YES];
	[txtEmail setEnabled:YES];
	[txtPassword setEnabled:YES];
	
	[[self window] performClose:self];
	[[NSApp delegate] showMainWindow];
}

- (void)loginWasUnsuccessful
{
	[piLoginSpinner stopAnimation:self];
	[btnLogin setEnabled:YES];
	[btnRegister setEnabled:YES];
	[txtEmail setEnabled:YES];
	[txtPassword setEnabled:YES];
	[self displayErrorSheetWithMessage:api.errorMessage];
	[[self window] makeFirstResponder:txtEmail];
}

- (IBAction)registerWasClicked:(id)sender
{
	[[self window] makeFirstResponder:[self window]];

	// Make sure username is not empty
	if([[txtRegEmail stringValue] compare:@""] == NSOrderedSame)
	{
		[self displayErrorSheetWithMessage:@"Please enter an email address."];
		[[self window] makeFirstResponder:txtRegEmail];
		return;
	}
	
	// Make sure passwords match
	if([[txtRegPassword stringValue] compare:[txtRegPassword2 stringValue]] != NSOrderedSame)
	{
		[self displayErrorSheetWithMessage:@"Passwords do not match."];
		[txtRegPassword setStringValue:@""];
		[txtRegPassword2 setStringValue:@""];
		[[self window] makeFirstResponder:txtRegPassword];
		return;
	}

	// Make sure password is not empty
	if([[txtRegPassword stringValue] length] == 0)
	{
		[self displayErrorSheetWithMessage:@"Please enter a password."];
		[[self window] makeFirstResponder:txtRegPassword];
		return;
	}	
	
	[piRegSpinner startAnimation:self];
	[btnRegRegister setEnabled:NO];
	[btnRegCancel setEnabled:NO];
	[txtRegEmail setEnabled:NO];
	[txtRegPassword setEnabled:NO];
	[txtRegPassword2 setEnabled:NO];
	
	[api registerWithEmail:[txtRegEmail stringValue] andPassword:[txtRegPassword stringValue]];
}

- (void)registrationWasSuccessful
{
	[piRegSpinner stopAnimation:self];
	[btnRegRegister setEnabled:YES];
	[btnRegCancel setEnabled:YES];
	[txtRegEmail setEnabled:YES];
	[txtRegPassword setEnabled:YES];	
	[txtRegPassword2 setEnabled:YES];

	[[self window] performClose:self];
	[[NSApp delegate] showMainWindow];
}

- (void)registrationWasUnsuccessful
{
	[piRegSpinner stopAnimation:self];
	[btnRegRegister setEnabled:YES];
	[btnRegCancel setEnabled:YES];
	[txtRegEmail setEnabled:YES];
	[txtRegPassword setEnabled:YES];	
	[txtRegPassword2 setEnabled:YES];
	[self displayErrorSheetWithMessage:api.errorMessage];
}

- (void)displayErrorSheetWithMessage:(NSString *)message
{
	NSAlert *alert = [NSAlert alertWithMessageText:message
									 defaultButton:@"Ok" 
								   alternateButton:nil
									   otherButton:nil
						 informativeTextWithFormat:@""];
	
	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:nil
					 didEndSelector:nil
						contextInfo:nil];	
}

#pragma mark -
#pragma mark View Swapping
#pragma mark -

- (void)showViewOne:(id)sender
{
	[[self window] makeFirstResponder:[self window]];
	[theBox setContentView:viewOne];
	[[self window] makeFirstResponder:viewOneFocus];
}

- (void)showViewTwo:(id)sender
{
	[[self window] makeFirstResponder:[self window]];
	[theBox setContentView:viewTwo];
	[[self window] makeFirstResponder:viewTwoFocus];
}

- (void)swapViews:(id)sender
{
	if([theBox contentView] == viewOne)
		[self showViewTwo:sender];
	else
		[self showViewTwo:sender];
}

@end
