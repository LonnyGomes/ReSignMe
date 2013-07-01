//
//  MultiAppInfoViewController.m
//  AppResigner
//
//  Created by Lonny Gomes on 6/22/13.
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

#import "MultiAppInfoViewController.h"
#import "AppInfoModel.h"

@interface MultiAppInfoViewController ()

- (NSArray *) genModelsWithURLs:(NSArray *)urlsList;
- (id)retrieveTableDataForTableColumn:(NSTableColumn *)col withModel:(AppInfoModel *)model;
@property (nonatomic, strong) NSArray *urlModels;
@end

@implementation MultiAppInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}

- (void)loadIpaFilesList:(NSArray *)ipaFileURLs {
    [self.view setHidden:NO];
    
    [self.ipaTableView setDataSource:self];
    [self.ipaTableView setDelegate:self];
    
    //reset data source every time we load the list
    self.urlModels = nil;
    self.urlModels = [self genModelsWithURLs:ipaFileURLs];
    
    [self.ipaTableView reloadData];
}

- (NSArray *) genModelsWithURLs:(NSArray *)urlsList {
    NSMutableArray *list = [NSMutableArray array];
    
    AppInfoModel *curModel;
    for (NSURL *curIpaURL in urlsList) {
        curModel = [[AppInfoModel alloc] initWithURL:curIpaURL];
        [list addObject:curModel];
    }
    
    return [NSArray arrayWithArray:list];
}

- (id)retrieveTableDataForTableColumn:(NSTableColumn *)col withModel:(AppInfoModel *)model {
    NSString *colValue;
    NSString *colIdentifier = col.identifier;
    
    if ([colIdentifier isEqualToString:kMultiAppInfoTableCellFilename]){
        colValue = [model.ipaURL lastPathComponent];
    } else if ([colIdentifier isEqualToString:kMultiAppInfoTableCellDate]){
        colValue = model.modificationDate;
    } else if ([colIdentifier isEqualToString:kMultiAppInfoTableCellFileSize]){
        colValue = model.fileSize;
    } else if ([colIdentifier isEqualToString:kMultiAppInfoTableCellStatus]){
        colValue = model.status;
    }
    
    return colValue;
}

- (void)reset {
    [self.view setHidden:YES];
    self.urlModels = nil;
}

#pragma mark - NSTable datasource implementation
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.urlModels.count;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    //NSLog(@"Table col:%@", tableColumn);
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    AppInfoModel *curModel = [self.urlModels objectAtIndex:row];
    
    
    return [self retrieveTableDataForTableColumn:tableColumn withModel:curModel];
}

#pragma mark - NSTable delegate implementation


@end
