//
//  MultiAppInfoViewController.h
//  AppResigner
//
//  Created by Mass Defect on 6/22/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kMultiAppInfoTableCellFilename @"AppInfoCellFilename"
#define kMultiAppInfoTableCellDate @"AppInfoCellDate"
#define kMultiAppInfoTableCellFileSize @"AppInfoCellFileSize"
#define kMultiAppInfoTableCellStatus @"AppInfoCellStatus"

@interface MultiAppInfoViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

- (void)loadIpaFilesList:(NSArray *)ipaFileURLs;
- (void)reset;

@property (weak) IBOutlet NSTableView *ipaTableView;

@end
