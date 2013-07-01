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



#import <Foundation/Foundation.h>

#define kAppInfoModelDateFormat @"dd MMM yyyy HH:mm:ss"

#define kAppInfoModelStatusNotStarted @"Not Started"
#define kAppInfoModelStatusStarted @"Started"
#define kAppInfoModelStatusCompleted @"Completed"
#define kAppInfoModelStatusFailed @"Failed"

@interface AppInfoModel : NSObject
- (id)initWithURL:(NSURL *)ipaURL;
@property (nonatomic, strong) NSURL *ipaURL;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *creationDate;
@property (nonatomic, strong) NSString *modificationDate;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSString *fileSize;
@property (nonatomic, strong) NSString *status;

@end
