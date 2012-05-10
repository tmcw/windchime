//
//  WCAppDelegate.m
//  windchime
//
//  Created by Tom MacWright on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WCAppDelegate.h"

@implementation WCAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{     
    NSSound *c = [NSSound soundNamed:@"cb"];
    NSSound *g = [NSSound soundNamed:@"g"];
    NSSound *a = [NSSound soundNamed:@"a"];
    NSSound *e = [NSSound soundNamed:@"e"];
    NSSound *d = [NSSound soundNamed:@"d"];
    //NSLog([[NSBundle mainBundle] resourcePath]);
    NSLog(@"hi");
    [NSEvent
     addGlobalMonitorForEventsMatchingMask:NSKeyDownMask
     handler:^ (NSEvent *event) {
         if ([[event characters] isEqualToString:@"c"]) {
             [c play];
         }
         if ([[event characters] isEqualToString:@"g"]) {
             [g play];
         }
         if ([[event characters] isEqualToString:@"a"]) {
             [a play];
         }
         if ([[event characters] isEqualToString:@"e"]) {
             [e play];
         }
         if ([[event characters] isEqualToString:@"d"]) {
             [d play];
         }
     }];
}

@end