//
//  AppDelegate.h
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/9/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDropView.h"
#import "AppDropDelegate.h"
#import "AppInfoViewController.h"

#define kAppResignerDefaultOutputURL [NSURL URLWithString:@"~/Desktop"]

typedef enum {
    DragStateInital, //inital state when app opens
    DragStateAppSelected, //state when an app is selected to resign
    DragStateReSign, //state when app is getting resigned
    DragStateReSignComplete
} DragState;

@interface AppDelegate : NSObject <NSApplicationDelegate, AppDropDelegate>

- (void)populateCertPopDown:(NSArray *)certModels;
- (void)setupDragState:(DragState)isDragState;
- (void)initTextFields;
- (void)registerForNotifications;

//Secuirty manager notifcation selectors
- (void)processSecuirtyManagerEvent:(NSNotification *)notification;

//Properties
@property (nonatomic, strong) NSURL *outputPathURL;

//Interface builder actions
- (IBAction)browseBtnPressed:(id)sender;
- (IBAction)reSignBtnPressed:(id)sender;
- (IBAction)clearBtnPressed:(id)sender;

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
@property (weak) IBOutlet NSView *appInfoPlaceholderView;
@property (weak) IBOutlet NSButton *clearBtn;


@end
