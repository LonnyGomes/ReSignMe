//
//  AppDelegate.m
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/9/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.


#import "AppDelegate.h"
#import "CertificateModel.h"
#import "SecurityManager.h"
#import "AppUserDefaults.h"

@interface AppDelegate()
- (void)scrollToBottom;
@property (nonatomic, strong) SecurityManager *sm;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
       
    //place appInfoView where it should be
    [self.boxOutline addSubview:self.appInfoVC.view];
    
    [self.dropView setDelegate:self];
    
    //clear all default entries
    [self.certPopDownBtn removeAllItems];
    
    //ensure security manager stars w/o dependency problems
    self.sm = [SecurityManager defaultManager];
    if (!self.sm) {
        [self setupDragState:DragStateFatalError];
        NSRunAlertPanel(@"Dependency Error",
                        @"Could not find an installation of XCode or the command line tools!\n"
                        "The Xcode command line tools must be installed to resign you app. Please either install Xcode or the 'Command line tools for Xcode' located at the following url:\n\n"
                        "https://developer.apple.com/downloads/index.action",
                        nil, nil, nil);
        return;
    }
    
   
    
    if ([self populateCertPopDown:[self.sm getDistributionCertificatesList]]) {
        [self setupDragState:DragStateInital];
        [self loadUserDefaults];
        [self registerForNotifications];
    } else {
        [self setupDragState:DragStateFatalError];
         NSRunAlertPanel(@"Certificate Error",
            @"No valid certificates were found!\n"
            "Please install a distribution certificate using the 'Keychain Access' tool.\n\n"
            "The Keychain Access tool can be found in Applications -> Utilities\n\n"
            "A certificate is needed to resign your apps!", nil, nil, nil);
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app {
    return YES;
}

- (void)initTextFields {
    //TODO
}

- (void)loadUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *outputPath = [defaults stringForKey:kAppDefaultsOutputDir];
    if (outputPath) {
        self.outputPathURL = [NSURL URLWithString:outputPath];
    } else {
        self.outputPathURL = kAppResignerDefaultOutputURL;
    }
}

- (void)setupDragState:(DragState)dragState {
    switch (dragState) {
        case DragStateInital:
            [self.statusScrollView setHidden:YES];
            [self.progressBar stopAnimation:self];
            [self.dragMessageTextField setHidden:NO];
            [self.boxOutline setHidden:NO];
            [self.appInfoVC reset];
            [self.doneBtn setHidden:YES];
            [self.reSignBtn setEnabled:NO];
            break;
        case DragStateAppSelected:
            [self.statusScrollView setHidden:YES];
            [self.progressBar stopAnimation:self];
            [self.dragMessageTextField setHidden:YES];
            [self.boxOutline setHidden:NO];
            [self.doneBtn setHidden:YES];
            [self.reSignBtn setEnabled:YES];
            break;
        case DragStateReSign:
            [self.statusScrollView setHidden:NO];
            [self.progressBar startAnimation:self];
            [self.dragMessageTextField setHidden:YES];
            [self.boxOutline setHidden:YES];
            [self.appInfoVC reset];
            [self.doneBtn setHidden:YES];
            [self.reSignBtn setEnabled:NO];
            break;
        case DragStateReSignComplete:
            [self.statusScrollView setHidden:NO];
            [self.progressBar stopAnimation:self];
            [self.dragMessageTextField setHidden:YES];
            [self.boxOutline setHidden:YES];
            [self.appInfoVC reset];
            [self.doneBtn setHidden:NO];
            [self.reSignBtn setEnabled:NO];
            break;
        case DragStateRecoverableError:
            [self.statusScrollView setHidden:NO];
            [self.progressBar stopAnimation:self];
            [self.dragMessageTextField setHidden:YES];
            [self.boxOutline setHidden:YES];
            [self.appInfoVC reset];
            [self.doneBtn setHidden:NO];
            [self.reSignBtn setEnabled:NO];
            break;
        case DragStateFatalError:
            [self.statusScrollView setHidden:YES];
            [self.progressBar stopAnimation:self];
            [self.dragMessageTextField setHidden:YES];
            [self.boxOutline setHidden:NO];
            [self.appInfoVC reset];
            [self.doneBtn setHidden:YES];
            
            [self.dropView setHidden:YES];
            [self.reSignBtn setEnabled:NO];
            [self.browseBtn setEnabled:NO];
            
            break;
        default:
            break;
    }    
}

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processSecuirtyManagerEvent:)
                                                 name:kSecurityManagerNotificationEvent
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processSecuirtyManagerEvent:)
                                                 name:kSecurityManagerNotificationEventOutput
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processSecuirtyManagerEvent:)
                                                 name:kSecurityManagerNotificationEventComplete
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processSecuirtyManagerEvent:)
                                                 name:kSecurityManagerNotificationEventError
                                               object:nil];
}

- (void)setOutputPathURL:(NSURL *)pathURL {
    _outputPathURL = pathURL;
    [self.pathTextField setStringValue:[_outputPathURL.path stringByExpandingTildeInPath]];
    
    //update the user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:self.pathTextField.stringValue forKey:kAppDefaultsOutputDir];
}

- (BOOL)populateCertPopDown:(NSArray *)certModels {
    BOOL wasSuccess = YES;
    
    for (CertificateModel *curModel in certModels) {
        [self.certPopDownBtn addItemWithTitle:curModel.label];
    }
    
    if (!self.certPopDownBtn.itemArray.count) {
        wasSuccess = NO;
    }
    
    return wasSuccess;
}

- (void)scrollToBottom
{
    NSPoint newScrollOrigin;
    
    // assume that the scrollview is an existing variable
    if ([[self.statusScrollView documentView] isFlipped]) {
        newScrollOrigin=NSMakePoint(0.0,NSMaxY([[self.statusScrollView documentView] frame])
                                    -NSHeight([[self.statusScrollView contentView] bounds]));
    } else {
        newScrollOrigin=NSMakePoint(0.0,0.0);
    }
    
    [[self.statusScrollView documentView] scrollPoint:newScrollOrigin];
    
}

#pragma mark - Security Manager Notifcation selectors
- (void)processSecuirtyManagerEvent:(NSNotification *)notification {
    NSString *message = [notification.userInfo valueForKey:kSecurityManagerNotificationKey];
    //NSLog(@"Got notification:%@", message);
    //TODO:based on the notification type, format the text
    
    if ([notification.name isEqualToString:kSecurityManagerNotificationEvent]) {
        [self.statusTextView setString:[self.statusTextView.string stringByAppendingFormat:@"%@\n", message]];
    } else if ([notification.name isEqualToString:kSecurityManagerNotificationEventOutput]) {
        [self.statusTextView setString:[self.statusTextView.string stringByAppendingFormat:@"%@", message]];
    } else if ([notification.name isEqualToString:kSecurityManagerNotificationEventComplete]) {
        NSRunAlertPanel(@"Success", @"The ipa was successfully re-signed!", nil, nil, nil);
        [self setupDragState:DragStateReSignComplete];
    } else if ([notification.name isEqualToString:kSecurityManagerNotificationEventError]) {
        [self.statusTextView setString:[self.statusTextView.string stringByAppendingFormat:@"%@", message]];
        NSRange errorRange = NSMakeRange(self.statusTextView.string.length - message.length, message.length);
        [self.statusTextView setTextColor:[NSColor redColor] range:errorRange];
        [self setupDragState:DragStateRecoverableError];
        [self scrollToBottom];
        NSRunAlertPanel(@"Signing Error",
                        [NSString stringWithFormat:
                            @"The following error occurred when attempting to re-sign '%@':\n\n%@",
                                [self.dropView.selectedIPA lastPathComponent], message],
                        nil, nil, nil);
    }
    
    [self scrollToBottom];

}

#pragma mark - IB Actions
- (IBAction)browseBtnPressed:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    openDlg.canChooseDirectories = YES;
    openDlg.canChooseFiles = NO;
    openDlg.canCreateDirectories = YES;
    openDlg.allowsMultipleSelection = NO;
    
    if ( [openDlg runModal] == NSOKButton ) {
        self.outputPathURL = openDlg.URL;
    }
}

- (IBAction)reSignBtnPressed:(id)sender {
    BOOL isDir;
    BOOL outputPathExists =
        [[NSFileManager defaultManager] fileExistsAtPath:self.pathTextField.stringValue
                                             isDirectory:&isDir];
    
    if (!outputPathExists) {
        NSRunAlertPanel(@"Invalid Path",
                        @"The path specified for the Output Directory is "
                        "either not specified or does not exist!",
                        nil, nil, nil);
    } else if (!isDir) {
        NSRunAlertPanel(@"Not a valid Directory",
                        @"The path specified for the Output Directory is not a directory!",
                        nil, nil, nil);
    } else if (!self.dropView.selectedIPA) {
        NSRunAlertPanel(@"No ipa file specified",
                        @"No ipa has been selected. Please drag an ipa file into the app to re-sign it.",
                        nil, nil, nil);
    } else {
        [self setupDragState:DragStateReSign];
        NSString *selectedIdentity = self.certPopDownBtn.selectedItem.title;
        NSURL *appURL = [NSURL URLWithString:self.dropView.selectedIPA];
        NSURL *outputURL = [NSURL URLWithString:self.pathTextField.stringValue];
        [self.sm signAppWithIdenity:selectedIdentity appPath:appURL outputPath:outputURL];
    }
}

- (IBAction)doneBtnPressed:(id)sender {
    self.dropView.selectedIPA = nil;
    self.statusTextView.string = @"";
    [self setupDragState:DragStateInital];
}

#pragma mark - AppDropView delegate methods
- (void)appDropView:(AppDropView *)appDropView fileWasDraggedIntoView:(NSURL *)ipaPathURL {
    [self setupDragState:DragStateAppSelected];
    
    [self.appInfoVC loadIpaFile:ipaPathURL];
}

- (void)appDropView:(AppDropView *)appDropView invalidFileWasDraggedIntoView:(NSURL *)path {
    [self setupDragState:DragStateInital];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
