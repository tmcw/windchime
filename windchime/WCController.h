//
//  WCController.h
//  windchime
//
//  Created by Tom MacWright on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCController : NSObject {
// UI
    NSStatusItem *statusItem;
    NSMenu *menu;
    NSMenuItem *quitMI;
    NSMenuItem *aboutMI;
    NSImage *tiny;
}
@end