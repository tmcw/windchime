//
//  WCController.h
//  windchime
//
//  Created by Tom MacWright on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCController : NSObject {
}

// UI
@property (strong) NSStatusItem *statusItem;
@property (strong) NSMenu *menu;
@property (strong) NSMenuItem *quitMI;
@property (strong) NSMenuItem *aboutMI;
@property (strong) NSMenuItem *exportMI;
@property (strong) NSImage *tiny;

@property (strong) NSArray *instruments;
@property (strong) NSMenuItem *instrumentMI;
@property (strong) NSMenu *instrumentMenu;

@end
