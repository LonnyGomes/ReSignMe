//
//  AppDropView.h
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/10/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "AppDropDelegate.h"

#define HOVER_CLR_VALID [NSColor colorWithDeviceRed:81.0/255.0 green:143/255.0 blue:212/255.0 alpha:.25]
#define HOVER_CLR_INVALID [NSColor colorWithDeviceRed:227.0/255.0 green:36/255.0 blue:36/255.0 alpha:.25]

@interface AppDropView : NSView <NSDraggingDestination>
- (void)activateDragCursor;
- (void)deactivetDragCursor;
@property (nonatomic, strong) NSString *selectedIPA;
@property (nonatomic, assign) BOOL isInDragState;
@property (nonatomic, assign) id<AppDropDelegate> delegate;
@end
