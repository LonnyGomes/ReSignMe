//
//  AppDelegate.h
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/9/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDropView.h"

#define kAppResignerDefaultOutputURL [NSURL URLWithString:@"~/Desktop"]
@interface AppDelegate : NSObject <NSApplicationDelegate>

- (void)populateCertPopDown:(NSArray *)certModels;
//Properties
@property (nonatomic, strong) NSURL *outputPathURL;

//Interface builder actions
- (IBAction)browseBtnPressed:(id)sender;
- (IBAction)reSignBtnPressed:(id)sender;

//Interface builder properties
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *pathTextField;
@property (weak) IBOutlet NSPopUpButton *certPopDownBtn;
@property (weak) IBOutlet NSScrollView *statusTextView;
@property (weak) IBOutlet AppDropView *dropView;

@end
