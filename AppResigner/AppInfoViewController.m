//
//  AppInfoViewController.m
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/13/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import "AppInfoViewController.h"

@interface AppInfoViewController ()
- (void)populateFields:(NSURL *)url;
@property (nonatomic, strong) NSURL *ipaFileURL;
@end

@implementation AppInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)loadIpaFile:(NSURL *)ipaFileURL {
    [self.view setHidden:NO];
    self.ipaFileURL = ipaFileURL;
    
    [self populateFields:ipaFileURL];
}

- (void)populateFields:(NSURL *)url {
    [self.fileNameTextField setStringValue:[url lastPathComponent]];
    NSError *error;
    
    NSDictionary *fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:url.path error:&error];
   
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init ];
    [dateFormatter setDateFormat:@"dd MMM yyyy HH:mm:ss"];

    self.fileModificationTextField.stringValue =
        [dateFormatter stringFromDate:[fileAttribs fileModificationDate]];
    
    self.fileCreationTextField.stringValue =
        [dateFormatter stringFromDate:[fileAttribs fileCreationDate]];
    
    unsigned long long fileSize = [fileAttribs fileSize];
    float fileSizeMB = fileSize/pow(1024.0, 2);
    self.fileSizeTextField.stringValue = [NSString stringWithFormat:@"%.2f MB", fileSizeMB];
}

- (void)reset {
    [self.view setHidden:YES];
    
    [self.fileNameTextField setStringValue:@""];
    [self.fileSizeTextField setStringValue:@""];
    [self.fileModificationTextField setStringValue:@""];
}

@end
