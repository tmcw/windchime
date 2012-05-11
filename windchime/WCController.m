//
//  WCController.m
//  windchime
//
//  Created by Tom MacWright on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WCController.h"

@implementation WCController
- (id)init
{
    self = [super init];
    if (self)
    {
        NSString* tinyName = [[NSBundle mainBundle]
                              pathForResource:@"windchime"
                              ofType:@"png"];
        
        tiny = [[NSImage alloc] initWithContentsOfFile:tinyName];
        menu = [[NSMenu alloc] init];
        
        // Set up my status item
        statusItem = [[NSStatusBar systemStatusBar]
                       statusItemWithLength:NSVariableStatusItemLength];
        
        [statusItem setMenu:menu];
        [statusItem setToolTip:@"all keys"];
        [statusItem setImage:tiny];
        [statusItem setHighlightMode:YES];
        // Set up the menu
        quitMI = [[NSMenuItem alloc]
                   initWithTitle:NSLocalizedString(@"Quit",@"") 
                   action:@selector(terminate:) 
                  keyEquivalent:@""];
        
        [menu addItem:quitMI];
    }
    NSSound *c4 = [NSSound soundNamed:@"1st-violins-stc-rr1-c#4"];
    NSSound *e4 = [NSSound soundNamed:@"1st-violins-stc-rr1-e4"];
    NSSound *a3 = [NSSound soundNamed:@"1st-violins-stc-rr1-a#3"];
    NSSound *a4 = [NSSound soundNamed:@"1st-violins-stc-rr1-a#4"];
    NSSound *a5 = [NSSound soundNamed:@"1st-violins-stc-rr1-a#5"];
    [NSEvent
     addGlobalMonitorForEventsMatchingMask:NSKeyDownMask
     handler:^ (NSEvent *event) {
         if ([[event characters] isEqualToString:@"["] ||
             [[event characters] isEqualToString:@"{"]) {
             [c4 play];
         }
         else if ([[event characters] isEqualToString:@"]"] ||
                  [[event characters] isEqualToString:@"}"]) {
             [a3 play];
         }
         else if ([[event characters] isEqualToString:@";"] ||
                  [[event characters] isEqualToString:@","]) {
             [e4 play];
         }
     }];
    return self;
}
@end
