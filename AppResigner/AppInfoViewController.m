//
//  AppInfoViewController.m
//  ReSignMe
//
//  Created by Carpe Lucem Media Group on 2/13/13.
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

#import "AppInfoViewController.h"
#import "AppInfoModel.h"

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

- (void)loadIpaFileList:(NSArray *)ipaFileURLList {
    
}

- (void)populateFields:(NSURL *)url {
    AppInfoModel *model = [[AppInfoModel alloc] initWithURL:url];
    [self.fileNameTextField setStringValue:model.filename];

    self.fileOwnerTextField.stringValue = model.owner;
    self.fileModificationTextField.stringValue = model.modificationDate;
    self.fileCreationTextField.stringValue = model.creationDate;;
    self.fileSizeTextField.stringValue = model.fileSize;
}

- (void)reset {
    [self.view setHidden:YES];
    
    [self.fileNameTextField setStringValue:@""];
    [self.fileSizeTextField setStringValue:@""];
    [self.fileModificationTextField setStringValue:@""];
}

@end
