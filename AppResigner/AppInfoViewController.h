//
//  AppInfoViewController.h
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/13/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//
//  This file is part of EzAppResigner.
//
//  Foobar is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Foobar is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.


#import <Cocoa/Cocoa.h>

@interface AppInfoViewController : NSViewController
- (void)loadIpaFile:(NSURL *)ipaFileURL;
- (void)reset;

@property (weak) IBOutlet NSTextField *fileNameTextField;
@property (weak) IBOutlet NSTextField *fileModificationTextField;
@property (weak) IBOutlet NSTextField *fileSizeTextField;
@property (weak) IBOutlet NSTextField *fileCreationTextField;
@property (weak) IBOutlet NSTextField *fileOwnerTextField;

@end
