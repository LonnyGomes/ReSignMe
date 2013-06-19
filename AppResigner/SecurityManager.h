//
//  CertificateManager.h
//  ReSignMe
//
//  Created by Carpe Lucem Media Group on 2/9/13.
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

#define kSecurityManagerNotificationKey @"notificationDictKey"
#define kSecurityManagerNotificationEvent @"SecurityManagerNotificationEvent"
#define kSecurityManagerNotificationEventOutput @"SecurityManagerNotificationEventOutput"
#define kSecurityManagerNotificationEventComplete @"SecurityManagerNotificationEventComplete"
#define kSecurityManagerNotificationEventError @"SecurityManagerNotificationEventError"
#define kSecurityManageriPhoneSubjectNameUTF8CStr "iPhone D"
#define kSecurityManageriPhoneDistribSubjectNameUTF8CStr "iPhone Distribution:"
#define kSecurityManagerXcodeBundleName @"com.apple.dt.Xcode"

//options used for security manager
#define kSecurityManagerOptionsVerboseOutput 1

#define OPTION_IS_VERBOSE(flags) (flags & 1)

typedef NSString SMNotificationType;

@interface SecurityManager : NSObject
+ (SecurityManager *) defaultManager;
- (BOOL)setupDependencies;
- (NSArray *)getDistributionCertificatesList;
- (NSArray *)getDistributionAndDevCertificatesList;
- (NSURL *)signAppWithIdenity:(NSString *)identity appPath:(NSURL *)appPathURL outputPath:(NSURL *)outputPathURL;
- (NSURL *)signAppWithIdenity:(NSString *)identity appPath:(NSURL *)appPathURL outputPath:(NSURL *)outputPathURL options:(NSInteger)optionFlags;
@end
