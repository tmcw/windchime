//
//  WCAppDelegate.h
//  windchime
//
//  Created by Tom MacWright on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/MusicPlayer.h>
#import "WCController.h"

@interface WCAppDelegate : NSObject <NSApplicationDelegate>
@property (strong) WCController *wc;
@property (unsafe_unretained) IBOutlet NSWindow *window;

@end
