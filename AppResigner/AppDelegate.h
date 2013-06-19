//
//  AppDelegate.h
//  ReSignMe
//
//  Created by Carpe Lucem Media Group on 2/9/13.
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
#import "AppDropView.h"
#import "AppDropDelegate.h"
#import "AppInfoViewController.h"

#define kAppResignerDefaultOutputURL [NSURL URLWithString:@"~/Desktop"]

typedef enum {
    DragStateInital, //inital state when app opens
    DragStateAppSelected, //state when an app is selected to resign
    DragStateReSign, //state when app is getting resigned
    DragStateReSignComplete,
    DragStateRecoverableError, //the user still can recover from this state
    DragStateFatalError //there is no recovering from this state
} DragState;

@interface AppDelegate : NSObject <NSApplicationDelegate, AppDropDelegate>

- (BOOL)populateCertPopDown:(NSArray *)certModels;
- (void)setupDragState:(DragState)isDragState;
- (void)initTextFields;
- (void)registerForNotifications;
- (void)loadUserDefaults;

//Secuirty manager notifcation selectors
- (void)processSecuirtyManagerEvent:(NSNotification *)notification;

//Properties
@property (nonatomic, strong) NSURL *outputPathURL;

//Interface builder actions
- (IBAction)browseBtnPressed:(id)sender;
- (IBAction)reSignBtnPressed:(id)sender;
- (IBAction)doneBtnPressed:(id)sender;
- (IBAction)openMenuItemInvoked:(id)sender;
- (IBAction)verboseOptionMenuItemInvoked:(id)sender;
- (IBAction)showDevCertsMenuItemInvoked:(id)sender;


//Interface builder properties
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *pathTextField;
@property (weak) IBOutlet NSPopUpButton *certPopDownBtn;
@property (weak) IBOutlet NSScrollView *statusScrollView;
@property (strong) IBOutlet NSTextView *statusTextView;
@property (weak) IBOutlet AppDropView *dropView;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSTextField *dragMessageTextField;
@property (weak) IBOutlet NSBox *boxOutline;
@property (weak) IBOutlet NSButton *reSignBtn;
@property (unsafe_unretained) IBOutlet AppInfoViewController *appInfoVC;
@property (weak) IBOutlet NSButton *doneBtn;
@property (weak) IBOutlet NSButton *browseBtn;
@property (weak) IBOutlet NSMenuItem *showDevCertsMenuItem;
@property (weak) IBOutlet NSMenuItem *verboseOutputMenuItem;



@end
