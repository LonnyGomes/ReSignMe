//
//  CertificateManager.m
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/9/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//
//  This file is part of EzAppResigner.
//
//  Foobar is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Foobar is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

#import "SecurityManager.h"
#import "CertificateModel.h"
#import <Security/Security.h>

#define kCmdDefaultPathCodeSign @"/usr/bin/codesign"
#define kCmdDefaultPathCodeSignAlloc @"/usr/bin/codesign_alloc"
#define kCmdZip @"/usr/bin/zip"
#define kCmdUnzip @"/usr/bin/unzip"
#define kCmdMkTemp @"/usr/bin/mktemp"
#define kCmdCp @"/bin/cp"
#define kCmdRm @"/bin/rm"

#define kSecurityManagerBaseCdmCodeSign @"codesign"
#define kSecurityManagerBaseCdmCodeSignAllocate @"codesign_allocate"
#define kCmdDefaultPathXcodeSubDir @"/Contents/Developer/usr/bin/"

#define kSecurityManagerTmpFileTemplate @"/tmp/app-resign-XXXXXXXXXXXXXXXX"
#define kSecurityManagerWorkingSubDir @"dump"
#define kSecurityManagerPayloadDir @"Payload"
#define kSecurityManagerResourcesPlistDir @"ResourceRules.plist"
#define kSecurityManagerRenameStr @"_renamed"

@interface SecurityManager()
@property (nonatomic, strong) NSString *pathForCodesign;
@property (nonatomic, strong) NSString *pathForCodesignAlloc;
- (NSURL *)genTempPath;
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

- (NSArray *)getDistributionCertificatesList {
    NSMutableArray *certList = [NSMutableArray array];
    CFTypeRef searchResultsRef;
    const char *subjectName = kSecurityManagerSubjectNameUTF8CStr;
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

- (void)signAppWithIdenity:(NSString *)identity appPath:(NSURL *)appPathURL outputPath:(NSURL *)outputPathURL {
    NSFileHandle *file;
    NSPipe *pipe = [NSPipe pipe];
    
    //retrieve the ipa name
    NSString *ipaName = [appPathURL lastPathComponent];
    
    //create temp folder to perform work
    [self postNotifcation:kSecurityManagerNotificationEvent
              withMessage:@"Initializing re-signing process ..."];
    
    
    NSURL *tmpPathURL = [self genTempPath];
    
    [self postNotifcation:kSecurityManagerNotificationEvent
              withMessage:[NSString stringWithFormat:@"Created temp directory: %@", [tmpPathURL path]]];
    
    //copy the ipa over to the temp folder
    [self postNotifcation:kSecurityManagerNotificationEvent
              withMessage:[NSString stringWithFormat:@"Copying %@ to %@", ipaName, [tmpPathURL path]]];
    
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
    NSURL *tempIpaSrcPath = [tmpPathURL URLByAppendingPathComponent:ipaName];
    NSURL *tempIpaDstPath = [tmpPathURL URLByAppendingPathComponent:kSecurityManagerWorkingSubDir];
    
    [self postNotifcation:kSecurityManagerNotificationEvent
              withMessage:[NSString stringWithFormat:@"Unziping %@ to %@ ...", ipaName, [tmpPathURL path]]];
    //now unzip the contents of the ipa to prepare for resigning
    NSTask *unzipTask = [[NSTask alloc] init];
    pipe = [NSPipe pipe];
    file = [pipe fileHandleForReading];
    
    [unzipTask setStandardOutput:pipe];
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
        //TODO: Handle errors
        return;
    } else if (payloadPathContents.count != 1) {
        NSLog(@"Unexpected output in Payloads directory of the IPA!");
        //TODO: handle errors
        return;
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
        return;
    }
    
    [self postNotifcation:kSecurityManagerNotificationEventOutput
              withMessage:codesignOutput];
    
    //Repackage app
    NSString *resignedAppName = [[ipaName stringByDeletingPathExtension] stringByAppendingFormat:@"%@.ipa",kSecurityManagerRenameStr];
    NSString *zipOutputPath = [[outputPathURL URLByAppendingPathComponent:resignedAppName] path];
    
    [self postNotifcation:kSecurityManagerNotificationEvent
              withMessage:[NSString stringWithFormat:@"Saving re-signed app '%@' to output directory: %@ ...", resignedAppName, [outputPathURL path]]];
    NSTask *zipTask = [[NSTask alloc] init];
    [zipTask setLaunchPath:kCmdZip];
    [zipTask setCurrentDirectoryPath:[tempIpaDstPath path]];
    [zipTask setArguments:@[@"-q", @"-r", zipOutputPath, kSecurityManagerPayloadDir]];
    
    [zipTask launch];
    [zipTask waitUntilExit];
    
    [self postNotifcation:kSecurityManagerNotificationEventComplete withMessage:[NSString stringWithFormat:@"The ipa has been successuflly re-signed and is named '%@'", resignedAppName]];
    
}

@end
