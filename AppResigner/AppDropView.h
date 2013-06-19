//
//  AppDropView.h
//  ReSignMe
//
//  Created by Carpe Lucem Media Group on 2/10/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//
//  This file is part of ReSignMe.
//
//  ReSignMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ReSignMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ReSignMe.  If not, see <http://www.gnu.org/licenses/>.


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
