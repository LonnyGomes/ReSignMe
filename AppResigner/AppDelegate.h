//
//  AppDelegate.h
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/9/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

//Properties
@property (nonatomic, strong) NSURL *outputPathURL;

//Interface builder actions
- (IBAction)browseBtnPressed:(id)sender;

//Interface builder properties
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *pathTextField;

@end
