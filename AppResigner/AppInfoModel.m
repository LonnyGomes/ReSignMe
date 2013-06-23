//
//  AppInfoModel.h
//  ReSignMe
//
//  Created by Lonny Gomes on 6/23/13.
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


#import "AppInfoModel.h"

@interface AppInfoModel()
- (void)prepareModelForIPA:(NSURL *)ipaURL;
- (NSString *)getFilenameFormIPA:(NSURL *)ipaURL;
- (NSString *)getCreationDateForIPA:(NSURL *)ipaURL;
- (NSString *)getModificationDateForIPA:(NSURL *)ipaURL;
- (NSString *)getFilesizeForIPA:(NSURL *)ipaURL;
- (NSString *)getOwnerForIPA:(NSURL *)ipaURL;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong)  NSDictionary *fileAttribs;
@end

@implementation AppInfoModel

- (id)initWithURL:(NSURL *)ipaURL {
    
    self = [self init];
    
    if (self) {
        [self prepareModelForIPA:ipaURL];
        self.ipaURL = ipaURL;
        self.filename = [self getFilenameFormIPA:ipaURL];
        self.creationDate = [self getCreationDateForIPA:ipaURL];
        self.modificationDate = [self getModificationDateForIPA:ipaURL];
        self.owner = [self getOwnerForIPA:ipaURL];
        self.fileSize = [self getFilesizeForIPA:ipaURL];
        self.status = @"Not started";
    }
    
    return self;
}

- (void)prepareModelForIPA:(NSURL *)ipaURL {
    NSError *error;
    self.fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:ipaURL.path error:&error];
    
    self.dateFormatter = [[NSDateFormatter alloc] init ];
    [self.dateFormatter setDateFormat:kAppInfoDateFormat];
}

#pragma mark - helper methods for working with IPAs
- (NSString *)getFilenameFormIPA:(NSURL *)ipaURL {
    return [ipaURL lastPathComponent];
}

- (NSString *)getCreationDateForIPA:(NSURL *)ipaURL {
    return [self.dateFormatter stringFromDate:[self.fileAttribs fileCreationDate]];
}

- (NSString *)getModificationDateForIPA:(NSURL *)ipaURL {
    return [self.dateFormatter stringFromDate:[self.fileAttribs fileModificationDate]];
}

- (NSString *)getFilesizeForIPA:(NSURL *)ipaURL {
    unsigned long long fileSize = [self.fileAttribs fileSize];
    float fileSizeMB = fileSize/pow(1024.0, 2);
    return [NSString stringWithFormat:@"%.2f MB", fileSizeMB];
}

- (NSString *)getOwnerForIPA:(NSURL *)ipaURL {
    return [self.fileAttribs fileOwnerAccountName];
}

@end
