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
#define kSecurityManagerNotificationHeaderFormatKey @"notificationDictIsHeaderKey"
#define kSecurityManagerNotificationEvent @"SecurityManagerNotificationEvent"
#define kSecurityManagerNotificationEventOutput @"SecurityManagerNotificationEventOutput"
#define kSecurityManagerNotificationEventComplete @"SecurityManagerNotificationEventComplete"
#define kSecurityManagerNotificationMultiFileEventComplete @"SecurityManagerNotificationMultiFileEventComplete"
#define kSecurityManagerNotificationEventError @"SecurityManagerNotificationEventError"
#define kSecurityManagerNotificationMultiFileEventError @"SecurityManagerNotificationMultiFileEventError"
#define kSecurityManageriPhoneSubjectNameUTF8CStr "iPhone D"
#define kSecurityManageriPhoneDistribSubjectNameUTF8CStr "iPhone Distribution:"
#define kSecurityManagerXcodeBundleName @"com.apple.dt.Xcode"

//options used for security manager
#define kSecurityManagerOptionsVerboseOutput    1
#define kSecurityManagerOptionsMultiFileMode    2
#define kSecurityManagerOptionsRenameApps       4

typedef enum {
    SecurityManagerErrorXcodeNotFound = 1 << 8,
    SecurityManagerErrorCodesignNotFound = 2 << 8,
    SecurityManagerErrorCodesignAllocNotFound = 4 << 8
} SecurityManagerError;

#define OPTION_IS_VERBOSE(flags) (flags & kSecurityManagerOptionsVerboseOutput)
#define OPTION_IS_MULTI_FILE(flags) ((flags & kSecurityManagerOptionsMultiFileMode) >> 1)
#define OPTION_SHOULD_RENAME_APPS(flags) ((flags & kSecurityManagerOptionsRenameApps) >> 2)

#define SEC_MAN_ERROR_XCODE(flags) (SecurityManagerErrorXcodeNotFound == (SecurityManagerErrorXcodeNotFound & flags))
#define SEC_MAN_ERROR_CODESIGN(flags) (SecurityManagerErrorCodesignNotFound == (SecurityManagerErrorCodesignNotFound & flags))
#define SEC_MAN_ERROR_CODESIGN_ALLOC(flags) (SecurityManagerErrorCodesignAllocNotFound == (SecurityManagerErrorCodesignAllocNotFound & flags))

#define ERROR_EVENT(isMulti) (isMulti ? kSecurityManagerNotificationMultiFileEventError : kSecurityManagerNotificationEventError)

typedef NSString SMNotificationType;

@interface SecurityManager : NSObject
+ (SecurityManager *) defaultManager;
- (SecurityManagerError)checkDepenencies;
- (NSArray *)getDistributionCertificatesList;
- (NSArray *)getDistributionAndDevCertificatesList;
- (NSURL *)signAppWithIdenity:(NSString *)identity appPath:(NSURL *)appPathURL outputPath:(NSURL *)outputPathURL;
- (NSURL *)signAppWithIdenity:(NSString *)identity appPath:(NSURL *)appPathURL outputPath:(NSURL *)outputPathURL options:(NSInteger)optionFlags;
- (NSArray *) signMultipleAppWithIdenity:(NSString *)identity appPaths:(NSArray *)appPathsURL outputPath:(NSURL *)outputPathURL options:(NSInteger)optionFlags;
@end
