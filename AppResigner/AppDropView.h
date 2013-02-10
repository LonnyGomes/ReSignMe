//
//  AppDropView.h
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/10/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDropView : NSView <NSDraggingDestination>
- (void)activateDragCursor;
- (void)deactivetDragCursor;
@property (nonatomic, strong) NSString *selectedIPA;
@end
