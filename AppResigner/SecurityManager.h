//
//  CertificateManager.h
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/9/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSecurityManagerNotificationKey @"notificationDictKey"
#define kSecurityManagerNotificationEvent @"SecurityManagerNotificationEvent"
#define kSecurityManagerNotificationEventOutput @"SecurityManagerNotificationEventOutput"
#define kSecurityManagerSubjectNameUTF8CStr "iPhone Developer:"

typedef NSString SMNotificationType;

@interface SecurityManager : NSObject
+ (SecurityManager *) defaultManager;
- (NSArray *)getDistributionCertificatesList;
- (void)signAppWithIdenity:(NSString *)identity appPath:(NSURL *)appPathURL outputPath:(NSURL *)outputPathURL;
@end
