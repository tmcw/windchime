//
//  WCController.h
//  windchime
//
//  Created by Tom MacWright on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AudioUnit/AudioUnit.h>

@interface WCController : NSObject {
    AudioUnit synthUnit;
    int volume;
    NSString *currentScale;
    NSArray *currentNotes;
}

// UI
@property (strong) NSStatusItem *statusItem;
@property (strong) NSMenu *menu;
@property (strong) NSMenuItem *quitMI;
@property (strong) NSMenuItem *aboutMI;
@property (strong) NSMenuItem *exportMI;
@property (strong) NSMenuItem *scaleMI;
@property (strong) NSMenuItem *volumeMI;
@property (strong) NSImage *tiny;
@property (strong) NSArray *instruments;
@property (strong) NSDictionary *scales;
@property (strong) NSMenuItem *instrumentMI;
@property (strong) NSMenu *instrumentMenu;
@property (strong) NSMenu *scaleMenu;
@property (strong) NSMenu *volumeMenu;

@end
