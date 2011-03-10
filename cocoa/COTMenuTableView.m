#import "COTMenuTableView.h"


@implementation COTMenuTableView

- (NSMenu *) menuForEvent:(NSEvent *) event {
	NSPoint where;
	int row = -1, col = -1;
	
	where = [self convertPoint:[event locationInWindow] fromView:nil];
	row = [self rowAtPoint:where];
	col = [self columnAtPoint:where];
	
	if([self numberOfRows] > 0 && [self selectedRow] != NSNotFound) {
		[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
		return [self menu];
	}
	else
		return nil;
}

@end
