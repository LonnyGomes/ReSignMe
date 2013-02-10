//
//  CertificateManager.m
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/9/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import "SecurityManager.h"
#import <Security/Security.h>

@implementation SecurityManager
static SecurityManager *_certManager = nil;
+ (SecurityManager *) defaultManager {
    if (_certManager == nil) {
        _certManager = [[SecurityManager alloc] init];
    }
    return _certManager;
}

- (id)init {
    self = [super init];
    if (self) {
        UInt32 versionNum;
        SecKeychainGetVersion(&versionNum);
        
    }
    return self;
}
- (NSArray *)getCertificatesList {
    NSMutableArray *certList;
    
    return certList;
}
@end
