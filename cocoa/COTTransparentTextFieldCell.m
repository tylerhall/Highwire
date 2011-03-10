//
//  BWTransparentTextFieldCell.m
//  BWToolkit
//
//  Created by Brandon Walkin (www.brandonwalkin.com)
//  All code is provided under the New BSD license.
//

#import "COTTransparentTextFieldCell.h"

static NSShadow *textShadow;

@interface NSCell (BWTTFCPrivate)
- (NSDictionary *)_textAttributes;
@end

@implementation COTTransparentTextFieldCell

+ (void)initialize
{
	textShadow = [[NSShadow alloc] init];
	[textShadow setShadowOffset:NSMakeSize(0,-1)];	
	[textShadow setShadowColor:[NSColor colorWithCalibratedRed:0.6 green:0.6 blue:0.6 alpha:1.0]];
}

- (NSDictionary *)_textAttributes
{
	NSMutableDictionary *attributes = [[[NSMutableDictionary alloc] init] autorelease];
	[attributes addEntriesFromDictionary:[super _textAttributes]];
	[attributes setObject:[NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:1.0] forKey:NSForegroundColorAttributeName];

	[attributes setObject:[NSFont boldSystemFontOfSize:18] forKey:NSFontAttributeName];
		
	[attributes setObject:textShadow forKey:NSShadowAttributeName];
	
	return attributes;
}

@end
