//
//  CertificateManager.m
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/9/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import "SecurityManager.h"
#import "CertificateModel.h"
#import <Security/Security.h>

#define kCmdCodeSign @"/usr/bin/codesign"
#define kCmdZip @"/usr/bin/zip"
#define kCmdUnzip @"/usr/bin/unzip"
#define kCmdMkTemp @"/usr/bin/mktemp"
#define kCmdCp @"/bin/cp"
#define kCmdRm @"/bin/rm"

#define kSecurityManagerTmpFileTemplate @"/tmp/app-resign-XXXXXXXXXXXXXXXX"
#define kSecurityManagerWorkingSubDir @"dump"

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

- (NSArray *)getDistributionCertificatesList {
    NSMutableArray *certList = [NSMutableArray array];
    CFTypeRef searchResultsRef;
    const char *subjectName = kSecurityManagerSubjectNameUTF8CStr;
    CFStringRef subjectNameRef = CFStringCreateWithCString(NULL, subjectName,CFStringGetSystemEncoding());
    CFIndex valCount = 4;
    
    const void *searchKeys[] = {
        kSecClass, //type of keychain item to search for
        kSecMatchSubjectStartsWith,//search on subject
        kSecReturnAttributes,//return propery
        kSecMatchLimit//search limit
    };
    
    const void *searchVals[] = {
        kSecClassCertificate,
        subjectNameRef,
        kCFBooleanTrue,
        kSecMatchLimitAll
    };
    
    CFDictionaryRef dictRef=
        CFDictionaryCreate(kCFAllocatorDefault,
                           searchKeys,
                           searchVals,
                           valCount,
                           &kCFTypeDictionaryKeyCallBacks,
                           &kCFTypeDictionaryValueCallBacks);
    
    
    //if the status is OK, lets put the results
    //into the NSArray
    OSStatus status = SecItemCopyMatching(dictRef, &searchResultsRef);
    if (status) {
        
        NSLog(@"Failed the query: %@!", SecCopyErrorMessageString(status, NULL));
    } else {
        NSArray *searchResults = [NSMutableArray arrayWithArray: (__bridge NSArray *) searchResultsRef];
        
        CertificateModel *curModel;
        for (NSDictionary *curDict in searchResults) {
            curModel = [[CertificateModel alloc] initWithCertificateData:curDict];
            [certList addObject:curModel];
        }
    }
    
    if (dictRef) CFRelease(dictRef);
    
    return [NSArray arrayWithArray:certList];
}

- (void)signAppWithIdenity:(NSString *)identity appPath:(NSURL *)appPathURL outputPath:(NSURL *)outputPathURL {
    NSFileHandle *file;
    NSPipe *pipe = [NSPipe pipe];
    
    //create temp folder to perform work
    NSTask *mktmpTask = [[NSTask alloc] init];
    [mktmpTask setLaunchPath:kCmdMkTemp];
    [mktmpTask setArguments:@[@"-d", kSecurityManagerTmpFileTemplate]];

    [mktmpTask setStandardOutput:pipe];
    file = [pipe fileHandleForReading];
    
    [mktmpTask launch];
    [mktmpTask waitUntilExit];
    
    NSString *tmpPath = [[[NSString alloc] initWithData: [file readDataToEndOfFile] encoding: NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\n"  withString:@""];
    NSURL *tmpPathURL = [NSURL URLWithString:tmpPath];
    //copy the ipa over to the temp folder
    NSTask *cpAppTask = [[NSTask alloc] init];
    [cpAppTask setLaunchPath:kCmdCp];
    NSString *cleanAppPath = [NSString stringWithFormat:@"%@", [appPathURL path]];
    NSString *cleanTmpPath = [NSString stringWithFormat:@"%@", [tmpPathURL path]];
    [cpAppTask setArguments:@[cleanAppPath, cleanTmpPath]];
    
    [cpAppTask launch];
    [cpAppTask waitUntilExit];
    
    //NSLog (@"%@ %@ %@",kCmdCp,cleanAppPath, cleanTmpPath  );
    int status;
    if ( (status = [cpAppTask terminationStatus]) != 0) {
        //TODO:HANDLE BETTER
        NSLog(@"Could not copy ipa over!");
        return;
    }
    
    //set location of the copied IPA so we can unzip it
    NSURL *tempIpaSrcPath = [tmpPathURL URLByAppendingPathComponent:[appPathURL lastPathComponent]];
    NSURL *tempIpaDstPath = [tmpPathURL URLByAppendingPathComponent:kSecurityManagerWorkingSubDir];
    
    //now unzip the contents of the ipa to prepare for resigning
    NSTask *unzipTask = [[NSTask alloc] init];
    [unzipTask setLaunchPath:kCmdUnzip];
    [unzipTask setArguments:@[[tempIpaSrcPath path], @"-d", [tempIpaDstPath path]]];
    [unzipTask launch];
    [unzipTask waitUntilExit];
    
    
    //NSTask *codeSignTask = [[NSTask alloc] init];
    
    
}

@end
