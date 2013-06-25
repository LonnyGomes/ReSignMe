//
//  CertificateManager.m
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

#import "SecurityManager.h"
#import "CertificateModel.h"
#import <Security/Security.h>

#define kCmdDefaultPathCodeSign @"/usr/bin/codesign"
#define kCmdDefaultPathCodeSignAlloc @"/usr/bin/codesign_alloc"
#define kCmdZip @"/usr/bin/zip"
#define kCmdUnzip @"/usr/bin/unzip"
#define kCmdMkTemp @"/usr/bin/mktemp"

#define kSecurityManagerBaseCdmCodeSign @"codesign"
#define kSecurityManagerBaseCdmCodeSignAllocate @"codesign_allocate"
#define kCmdDefaultPathXcodeSubDir @"/Contents/Developer/usr/bin/"

#define kSecurityManagerTmpFileTemplate @"/tmp/app-resign-XXXXXXXXXXXXXXXX"
#define kSecurityManagerWorkingSubDir @"dump"
#define kSecurityManagerPayloadDir @"Payload"
#define kSecurityManagerResourcesPlistDir @"ResourceRules.plist"
#define kSecurityManagerRenameStr @"_reSigned"

@interface SecurityManager()
@property (nonatomic, strong) NSString *pathForCodesign;
@property (nonatomic, strong) NSString *pathForCodesignAlloc;
- (NSArray *)getDistributionCertificatesListWithDevCerts:(BOOL)willShowDevCerts;
- (NSURL *)genTempPath;
- (BOOL)purgeTempFolderAtPath:(NSURL *)tmpPathURL;
- (BOOL)copyIpaBundleWithSrcURL:(NSURL *)srcUrl destinationURL:(NSURL *)destUrl;
- (NSString *)cleanPath:(NSURL *)path;
- (void)postNotifcation:(SMNotificationType *)type withMessage:(NSString *)message;
@end

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
        //if we can set up
        if (![self setupDependencies]) {
            return nil;
        }
        
    }
    return self;
}

- (BOOL)setupDependencies {
    NSString* xCodePath = [ [ NSWorkspace sharedWorkspace ]
                           absolutePathForAppBundleWithIdentifier: kSecurityManagerXcodeBundleName ];
    
    //first check for codesign and codesign_alloc binaries
    if ([[NSFileManager defaultManager] fileExistsAtPath:kCmdDefaultPathCodeSign]) {
        self.pathForCodesign = kCmdDefaultPathCodeSign;
    } else if (xCodePath) {
        //if codesign isn't found in it's default location, check for xcode
        NSString *altPath = [xCodePath stringByAppendingPathComponent:[kCmdDefaultPathXcodeSubDir stringByAppendingString:kSecurityManagerBaseCdmCodeSign]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:altPath]) {
            self.pathForCodesign = altPath;
        }
    }

    
    if ([[NSFileManager defaultManager] fileExistsAtPath:kCmdDefaultPathCodeSignAlloc]) {
        self.pathForCodesignAlloc = kCmdDefaultPathCodeSignAlloc;
    } else  if (xCodePath) {
        //if not found at the default location but Xcode is installed
        //lets get the path from there
        NSString *altPath = [xCodePath stringByAppendingPathComponent:[kCmdDefaultPathXcodeSubDir stringByAppendingString:kSecurityManagerBaseCdmCodeSignAllocate]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:altPath]) {
            self.pathForCodesignAlloc = altPath;
        }
    }
    
    return (self.pathForCodesign && self.pathForCodesignAlloc);
}

- (NSArray *)getDistributionAndDevCertificatesList {
    return  [self getDistributionCertificatesListWithDevCerts:YES];
}

- (NSArray *)getDistributionCertificatesList {
    return [self getDistributionCertificatesListWithDevCerts:NO];
}

- (NSArray *)getDistributionCertificatesListWithDevCerts:(BOOL)willShowDevCerts {
    NSMutableArray *certList = [NSMutableArray array];
    CFTypeRef searchResultsRef;
    //filter on subject name
    //show either just distribution certs or dev certs as well
    const char *subjectName =
        willShowDevCerts ? kSecurityManageriPhoneSubjectNameUTF8CStr :
            kSecurityManageriPhoneDistribSubjectNameUTF8CStr;
    CFStringRef subjectNameRef = CFStringCreateWithCString(NULL, subjectName,CFStringGetSystemEncoding());
    CFIndex valCount = 5;
    
    const void *searchKeys[] = {
        kSecClass, //type of keychain item to search for
        kSecMatchSubjectStartsWith,//search on subject
        kSecReturnAttributes,//return dictionary of properties
        kSecMatchValidOnDate, //valid for current date
        kSecMatchLimit//search limit
    };
    
    const void *searchVals[] = {
        kSecClassCertificate,
        subjectNameRef,
        kCFBooleanTrue,
        kCFNull,
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

- (void)postNotifcation:(SMNotificationType *)type withMessage:(NSString *)message {
    [[NSNotificationCenter defaultCenter] postNotificationName:type object:self userInfo:[NSDictionary dictionaryWithObject:message forKey:kSecurityManagerNotificationKey]];
}

- (NSURL *)genTempPath {
    NSFileHandle *file;
    NSPipe *pipe = [NSPipe pipe];
    
    NSTask *mktmpTask = [[NSTask alloc] init];
    [mktmpTask setLaunchPath:kCmdMkTemp];
    [mktmpTask setArguments:@[@"-d", kSecurityManagerTmpFileTemplate]];
    
    [mktmpTask setStandardOutput:pipe];
    file = [pipe fileHandleForReading];
    
    [mktmpTask launch];
    [mktmpTask waitUntilExit];

    NSString *tmpPath = [[[NSString alloc] initWithData: [file readDataToEndOfFile] encoding: NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\n"  withString:@""];
    
    return [NSURL URLWithString:tmpPath];
}

- (BOOL)purgeTempFolderAtPath:(NSURL *)tmpPathURL {
    
    [self postNotifcation:kSecurityManagerNotificationEvent withMessage:@"Purging temporary path ...." ];
    
    dispatch_group_t group_queue = dispatch_group_create();
    
    __block BOOL wasSuccess = YES;
    dispatch_group_async(group_queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSError *err;
        NSString *tmpPath = [tmpPathURL path];
        [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:&err];
        
        if (err) {
            [self postNotifcation:kSecurityManagerNotificationEventError
                      withMessage:[NSString stringWithFormat:@"Failed to purge temporary path because of following reason: %@", err.localizedDescription]];
            wasSuccess = NO;
        }
    });
    
    dispatch_group_wait(group_queue, DISPATCH_TIME_FOREVER);
    
    dispatch_release(group_queue);
    
    return wasSuccess;
}

- (BOOL)copyIpaBundleWithSrcURL:(NSURL *)srcUrl destinationURL:(NSURL *)destUrl {
    BOOL wasSuccess = YES;
    
    NSError *copyError;
    [[NSFileManager defaultManager] copyItemAtPath:srcUrl.path toPath:destUrl.path error:&copyError];
    
    if (copyError) {
        [self postNotifcation:kSecurityManagerNotificationEventError
                  withMessage:[NSString stringWithFormat:@"Copy error: %@!\n", [copyError localizedDescription]]];
        wasSuccess = NO;
    }
    
    return wasSuccess;
}

- (NSString *)cleanPath:(NSURL *)pathURL {
    //NSString *str = [[pathURL path] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    NSString *str = [NSString stringWithFormat:@"\"%@\"", pathURL.path];
    return str;
}

- (void) signMultipleAppWithIdenity:(NSString *)identity appPaths:(NSArray *)appPathsURL outputPath:(NSURL *)outputPathURL options:(NSInteger)optionFlags {
    //add the multiple files mode flag in as an option
    optionFlags |= kSecurityManagerOptionsMultiFileMode;
    
    NSURL *reSignedURL;
    for (NSURL *curAppPath in appPathsURL) {
        reSignedURL = [self signAppWithIdenity:identity appPath:curAppPath outputPath:outputPathURL options:optionFlags];
    }
}

- (NSURL *)signAppWithIdenity:(NSString *)identity appPath:(NSURL *)appPathURL outputPath:(NSURL *)outputPathURL {
    return [self signAppWithIdenity:identity appPath:appPathURL outputPath:outputPathURL options:0];
}

- (NSURL *)signAppWithIdenity:(NSString *)identity appPath:(NSURL *)appPathURL outputPath:(NSURL *)outputPathURL options:(NSInteger)optionFlags {
    NSFileHandle *file;
    NSPipe *pipe = [NSPipe pipe];
    
    //parse option flags
    BOOL isVerboseOutput = OPTION_IS_VERBOSE(optionFlags);
    BOOL isMultiFileMode = OPTION_IS_MULTI_FILE(optionFlags);
    
    //retrieve the ipa name
    NSString *ipaName = [appPathURL lastPathComponent];
    
    //create temp folder to perform work
    [self postNotifcation:kSecurityManagerNotificationEvent
              withMessage:@"Initializing re-signing process ..."];
    
    
    NSURL *tmpPathURL = [self genTempPath];
    
    if (isVerboseOutput) {
        [self postNotifcation:kSecurityManagerNotificationEvent
              withMessage:[NSString stringWithFormat:@"Created temp directory: %@", [tmpPathURL path]]];
    
        //copy the ipa over to the temp folder
        [self postNotifcation:kSecurityManagerNotificationEvent
              withMessage:[NSString stringWithFormat:@"Copying %@ to %@", ipaName, [tmpPathURL path]]];
    }
    
    //TODO:add group queue!
    if (![self copyIpaBundleWithSrcURL:appPathURL destinationURL:[tmpPathURL URLByAppendingPathComponent:ipaName]]) {
        [self purgeTempFolderAtPath:tmpPathURL];
        return nil;
    }
    
    
    //set location of the copied IPA so we can unzip it
    NSURL *tempIpaSrcPath = [tmpPathURL URLByAppendingPathComponent:ipaName];
    NSURL *tempIpaDstPath = [tmpPathURL URLByAppendingPathComponent:kSecurityManagerWorkingSubDir];
    
    if (isVerboseOutput) {
        [self postNotifcation:kSecurityManagerNotificationEvent
              withMessage:[NSString stringWithFormat:@"Uncompressing %@ to %@ ...", ipaName, [tmpPathURL path]]];
    } else {
        [self postNotifcation:kSecurityManagerNotificationEvent
                  withMessage:[NSString stringWithFormat:@"Uncompressing %@ ...", ipaName]];
        
    }
    
    //now unzip the contents of the ipa to prepare for resigning
    NSTask *unzipTask = [[NSTask alloc] init];
    pipe = [NSPipe pipe];
    file = [pipe fileHandleForReading];
    
    if (isVerboseOutput) {
        [unzipTask setStandardOutput:pipe];
    }
    [unzipTask setStandardError:pipe];
    
    [unzipTask setLaunchPath:kCmdUnzip];
    [unzipTask setArguments:@[[tempIpaSrcPath path], @"-d", [tempIpaDstPath path]]];
    [unzipTask launch];
    [unzipTask waitUntilExit];
    
    //TODO: read this in asynchononusly
    NSString *unzipOutput = [[NSString alloc] initWithData: [file readDataToEndOfFile] encoding: NSUTF8StringEncoding];
    
    [self postNotifcation:kSecurityManagerNotificationEventOutput withMessage:unzipOutput];
    
    NSError *payloadError;
    
    NSURL *payloadPathURL = [tempIpaDstPath URLByAppendingPathComponent:kSecurityManagerPayloadDir];
    NSArray *payloadPathContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[payloadPathURL path] error:&payloadError];
    
    if (payloadError) {
        NSLog(@"Could not open: %@", [payloadPathURL path]);
        
        NSString *unzipErrorStr = [NSString stringWithFormat:@"unzip: failed to unzip %@ to %@!", tempIpaSrcPath, tempIpaDstPath];
        NSString *notificationStr = ERROR_EVENT(isMultiFileMode);
        [self postNotifcation:notificationStr withMessage:unzipErrorStr];
        
        [self purgeTempFolderAtPath:tmpPathURL];
        return nil;
    } else if (payloadPathContents.count != 1) {
        NSString *notificationStr = ERROR_EVENT(isMultiFileMode);
        [self postNotifcation:notificationStr
                  withMessage:@"Unexpected output in Payloads directory of the IPA!"];
        
        [self purgeTempFolderAtPath:tmpPathURL];
        return nil;
    }
    
    //setup paths for codesign
    NSURL *appContentsURL = [payloadPathURL URLByAppendingPathComponent:[payloadPathContents objectAtIndex:0]];
    NSURL *resourcesPathURL = [appContentsURL URLByAppendingPathComponent:kSecurityManagerResourcesPlistDir];
    
    NSArray *codesignArgs = @[ @"--force",
                               @"--sign",
                               identity,
                               @"--resource-rules",
                               [resourcesPathURL path],
                               [appContentsURL path]];
    
    //TODO:check into codesign_allocate
    //TODO:do we need to insert the mobile provisioning profile?
    //sign the app
    [self postNotifcation:kSecurityManagerNotificationEvent
              withMessage:[NSString stringWithFormat:@"Re-signing %@", ipaName]];
    NSTask *codeSignTask = [[NSTask alloc] init];
    [codeSignTask setLaunchPath:self.pathForCodesign];
    [codeSignTask setEnvironment:[NSDictionary dictionaryWithObject:self.pathForCodesignAlloc forKey:@"CODESIGN_ALLOCATE"]];
    [codeSignTask setArguments:codesignArgs];
    
    pipe = [NSPipe pipe];
    file = [pipe fileHandleForReading];
    
    [codeSignTask setStandardOutput:pipe];
    [codeSignTask setStandardError:pipe];
    [codeSignTask launch];
    [codeSignTask waitUntilExit];
    
    NSString *codesignOutput = [[NSString alloc] initWithData:[file readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    
    NSInteger codeSignReturnCode = [codeSignTask terminationStatus];
    if (codeSignReturnCode) {
        [self postNotifcation:kSecurityManagerNotificationEventError
                  withMessage:[NSString stringWithFormat:@"FAILURE: %@", codesignOutput]];
        
        [self purgeTempFolderAtPath:tmpPathURL];
        return nil;
    }
    
    [self postNotifcation:kSecurityManagerNotificationEventOutput
              withMessage:codesignOutput];
    
    //Repackage app
    NSString *resignedAppName = [[ipaName stringByDeletingPathExtension] stringByAppendingFormat:@"%@.ipa",kSecurityManagerRenameStr];
    NSString *zipOutputPath = [[outputPathURL URLByAppendingPathComponent:resignedAppName] path];
    NSURL *zipOutputPathURL = [NSURL fileURLWithPath:zipOutputPath];//This must be a file URL as it will be returned in the method
    
    [self postNotifcation:kSecurityManagerNotificationEvent
              withMessage:[NSString stringWithFormat:@"Saving re-signed app '%@' to output directory: %@ ...", resignedAppName, [outputPathURL path]]];
    NSTask *zipTask = [[NSTask alloc] init];
    [zipTask setLaunchPath:kCmdZip];
    [zipTask setCurrentDirectoryPath:[tempIpaDstPath path]];
    [zipTask setArguments:@[@"-q", @"-r", zipOutputPath, kSecurityManagerPayloadDir]];
    
    [zipTask launch];
    [zipTask waitUntilExit];
    
    NSInteger zipReturnCode = [zipTask terminationStatus];
    if (zipReturnCode) {
        [self postNotifcation:kSecurityManagerNotificationEventError
                  withMessage:[NSString stringWithFormat:@"zip failed to package %@", zipOutputPath]];
        
        [self purgeTempFolderAtPath:tmpPathURL];
        return nil;
    }
    
    if ([self purgeTempFolderAtPath:tmpPathURL]) {
        [self postNotifcation:kSecurityManagerNotificationEvent withMessage:@"App re-sign process successfully completed!"];
        [self postNotifcation:kSecurityManagerNotificationEventComplete withMessage:[NSString stringWithFormat:@"The ipa has been successuflly re-signed and is named '%@'", resignedAppName]];
    }
    
    return zipOutputPathURL;
}

@end
