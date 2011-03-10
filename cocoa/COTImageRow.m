
#import "COTImageRow.h"

@implementation COTImageRow

@synthesize imageName;

- (BOOL)isOpaque
{
	return YES;
}

- (void)drawInteriorWithFrame:(NSRect)aRect inView:(NSView *)controlView
{
	NSRect txtRect = aRect;
	txtRect.origin.x += 20;

	[super drawInteriorWithFrame:txtRect inView:controlView];

	NSImage *img = [NSImage imageNamed:self.imageName];
	[img setFlipped:YES];

	NSRect imgRect = aRect;
	imgRect.size.width = 16;
	imgRect.size.height = 16;
	imgRect.origin.x += 2;
	imgRect.origin.y += 2;
	[img drawInRect:imgRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

@end
