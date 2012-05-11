//
//  WCAppDelegate.m
//  windchime
//
//  Created by Tom MacWright on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WCAppDelegate.h"
#import "WCController.h"

@implementation WCAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{     
    WCController *wc = [WCController alloc];
    [wc init];
}

@end