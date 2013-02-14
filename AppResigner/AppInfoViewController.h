//
//  AppInfoViewController.h
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/13/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppInfoViewController : NSViewController
- (void)loadIpaFile:(NSURL *)ipaFileURL;
- (void)reset;

@property (weak) IBOutlet NSTextField *fileNameTextField;
@property (weak) IBOutlet NSTextField *fileModificationTextField;
@property (weak) IBOutlet NSTextField *fileSizeTextField;
@property (weak) IBOutlet NSTextField *fileCreationTextField;

@end
