//
//  AppDelegate.m
//  ReSignMe
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

#define kMultiAppInfoXOffset 2
#define kMultiAppInfoYOffset 5

#define NOTIFICATION_HEADER_FONT @"Courier"
#define NOTIFICATION_HEADER_FONT_SIZE 16

#define OUTPUT_FONT @"Courier New"
#define OUTPUT_FONT_SIZE 12

@interface AppDelegate()
- (void)scrollToBottom;
- (void)displayNoValidCertError;
- (void)setupGUI;
- (void)setupFonts;
@property (nonatomic, strong) SecurityManager *sm;
@property (nonatomic, assign) BOOL isVerboseOutput;
@property (nonatomic, assign) BOOL isShowingDevCerts;
@property (nonatomic, assign) BOOL shouldRenameApps;
@property (nonatomic, strong) NSDictionary *defaultAttribStringOptions;
@property (nonatomic, strong) NSDictionary *headerAttribStringOptions;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //initialize GUI components
    [self setupGUI];
    
    //initialize font optins
    [self setupFonts];
    
    //ensure security manager starts w/o dependency problems
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
    
    //load user defaults before going any further
    [self loadUserDefaults];

    //load appropriate cert list
    if ([self populateCertPopDown:self.isShowingDevCerts ? self.sm.getDistributionAndDevCertificatesList : self.sm.getDistributionCertificatesList]) {
        [self setupDragState:DragStateInital];
        
        [self registerForNotifications];
    } else {
        [self displayNoValidCertError];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app {
    return YES;
}

- (void)setupGUI {
    //place appInfoView where it should be
    [self.boxOutline addSubview:self.appInfoVC.view];
    
    //place multiInfoView in inside box view with specified offsets
    [self.boxOutline addSubview:self.multiAppInfoVC.view];
    CGRect multiAppInfoVCFrame = [self.multiAppInfoVC.view frame];
    multiAppInfoVCFrame.origin.x = kMultiAppInfoXOffset;
    multiAppInfoVCFrame.origin.y = kMultiAppInfoYOffset;
    [self.multiAppInfoVC.view setFrame:multiAppInfoVCFrame];
    
    [self.dropView setDelegate:self];
    
    //clear all default entries
    [self.certPopDownBtn removeAllItems];
    
    //set default font for text output
    [[self.statusTextView textStorage] setFont:[NSFont fontWithName:OUTPUT_FONT size:OUTPUT_FONT_SIZE]];
}

- (void)setupFonts {
    NSFont *defaultFont = [NSFont fontWithName:OUTPUT_FONT size:OUTPUT_FONT_SIZE];
    NSFont *headerFont  = [NSFont fontWithName:NOTIFICATION_HEADER_FONT size:NOTIFICATION_HEADER_FONT_SIZE];
    
    self.defaultAttribStringOptions = @{NSFontAttributeName:defaultFont};
    self.headerAttribStringOptions  = @{NSFontAttributeName:headerFont};
}

- (void)initTextFields {
    //TODO
}

- (void)loadUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *outputPath = [defaults stringForKey:kAppDefaultsOutputDir];
    if (outputPath) {
        self.outputPathURL = [NSURL URLWithString:[outputPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    } else {
        self.outputPathURL = kAppResignerDefaultOutputURL;
    }
    
    //read in flag for if dev certs will be loaded and set in menu
    self.isShowingDevCerts = [defaults boolForKey:kAppDefaultsShowDevCerts];
    [self.showDevCertsMenuItem setState:self.isShowingDevCerts];
    
    //read in flag for if verbosity mode is enabled and set in menu
    self.isVerboseOutput = [defaults boolForKey:kAppDefaultsIsVerboseOutput];
    [self.verboseOutputMenuItem setState:self.isVerboseOutput];
    
    //determine if the re-signed app should be renamed after re-signed
    if ([defaults objectForKey:kAppDefaultsShouldRenameApps] == nil) {
        //if the key has not been set, let's default the value to true
        [defaults setBool:YES forKey:kAppDefaultsShouldRenameApps];
        self.shouldRenameApps = YES;
    } else {
        self.shouldRenameApps = [defaults boolForKey:kAppDefaultsShouldRenameApps];
    }
    [self.renameAppsMenuItem setState:self.shouldRenameApps];
    
}

- (void)setupDragState:(DragState)dragState {
    switch (dragState) {
        case DragStateInital:
            [self.statusScrollView setHidden:YES];
            [self.progressBar stopAnimation:self];
            [self.dragMessageTextField setHidden:NO];
            [self.boxOutline setHidden:NO];
            [self.appInfoVC reset];
            [self.multiAppInfoVC reset];
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
        case DragStateMultiAppsSelected:
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
            [self.multiAppInfoVC reset];
            [self.doneBtn setHidden:YES];
            [self.reSignBtn setEnabled:NO];
            break;
        case DragStateReSignComplete:
            [self.statusScrollView setHidden:NO];
            [self.progressBar stopAnimation:self];
            [self.dragMessageTextField setHidden:YES];
            [self.boxOutline setHidden:YES];
            [self.appInfoVC reset];
            [self.multiAppInfoVC reset];
            [self.doneBtn setHidden:NO];
            [self.reSignBtn setEnabled:NO];
            break;
        case DragStateRecoverableError:
            [self.statusScrollView setHidden:NO];
            [self.progressBar stopAnimation:self];
            [self.dragMessageTextField setHidden:YES];
            [self.boxOutline setHidden:YES];
            [self.appInfoVC reset];
            [self.multiAppInfoVC reset];
            [self.doneBtn setHidden:NO];
            [self.reSignBtn setEnabled:NO];
            break;
        case DragStateFatalError:
            [self.statusScrollView setHidden:YES];
            [self.progressBar stopAnimation:self];
            [self.dragMessageTextField setHidden:YES];
            [self.boxOutline setHidden:NO];
            [self.appInfoVC reset];
            [self.multiAppInfoVC reset];
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
    
    //update the user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *newOutputPath = [_outputPathURL.path stringByExpandingTildeInPath];
    
    if (newOutputPath && ![newOutputPath isEqual:@""]) {
        
        [self.pathTextField setStringValue:newOutputPath];
        [defaults setObject:newOutputPath forKey:kAppDefaultsOutputDir];
    } else {
        [self.pathTextField setStringValue:@""];
        [defaults setObject:@"" forKey:kAppDefaultsOutputDir];
    }
}

- (BOOL)populateCertPopDown:(NSArray *)certModels {
    BOOL wasSuccess = YES;
    //remove any existing models
    [self.certPopDownBtn removeAllItems];
    
    //loop through all cert models and add them into the pop down
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

#pragma mark - Error popup methods
- (void)displayNoValidCertError {
    [self setupDragState:DragStateFatalError];
    NSRunAlertPanel(@"Certificate Error",
                    @"No valid certificates were found!\n"
                    "Please install a distribution certificate using the 'Keychain Access' tool.\n\n"
                    "The Keychain Access tool can be found in Applications -> Utilities\n\n"
                    "A certificate is needed to resign your apps!", nil, nil, nil);
    
}

#pragma mark - Security Manager Notifcation selectors
- (void)processSecuirtyManagerEvent:(NSNotification *)notification {
    NSString *message = [notification.userInfo valueForKey:kSecurityManagerNotificationKey];
    NSAttributedString *messageAttrb =
        [[NSAttributedString alloc] initWithString:[message stringByAppendingString:@"\n"] attributes:self.defaultAttribStringOptions];
    
    if ([notification.name isEqualToString:kSecurityManagerNotificationEvent]) {
        //status notifications
        //format a header message differently
        if ([notification.userInfo valueForKey:kSecurityManagerNotificationHeaderFormatKey]) {
                messageAttrb = [[NSAttributedString alloc] initWithString:[message stringByAppendingString:@"\n"] attributes:self.headerAttribStringOptions];
        }
        
        [[self.statusTextView textStorage] appendAttributedString:messageAttrb];
    } else if ([notification.name isEqualToString:kSecurityManagerNotificationEventOutput]) {
        //output from a command
        [[self.statusTextView textStorage] appendAttributedString:messageAttrb];
    } else if ([notification.name isEqualToString:kSecurityManagerNotificationEventComplete]) {
        //success event
        [self setupDragState:DragStateReSignComplete];
    } else if ([notification.name isEqualToString:kSecurityManagerNotificationEventError]) {
        //error event
        [[self.statusTextView textStorage] appendAttributedString:messageAttrb];
        NSRange errorRange = NSMakeRange(self.statusTextView.string.length - message.length-1, message.length);
        [self.statusTextView setTextColor:[NSColor redColor] range:errorRange];
        [self setupDragState:DragStateRecoverableError];
        [self scrollToBottom];

        //only display error if one IPA is selected to re-sign
        //in the case of multiple IPAs, the errors should be
        //suppressed until the end
        if (self.dropView.selectedIPAs.count == 1) {
            NSRunAlertPanel(@"Signing Error",
                        [NSString stringWithFormat:
                            @"The following error occurred when attempting to\nre-sign '%@':\n\n%@",
                                [self.dropView.currentIPA lastPathComponent], message],
                        nil, nil, nil);
        }
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
    } else if (!self.dropView.selectedIPAs) {
        NSRunAlertPanel(@"No ipa file specified",
                        @"No ipa has been selected. Please drag an ipa file into the app to re-sign it.",
                        nil, nil, nil);
    } else {
        NSString *selectedIdentity = self.certPopDownBtn.selectedItem.title;
        
        NSURL *outputURL = [NSURL URLWithString:[self.pathTextField.stringValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSInteger options = 0;
        if (self.isVerboseOutput) {
            options |= kSecurityManagerOptionsVerboseOutput;
        }
        if (self.shouldRenameApps) {
            options |= kSecurityManagerOptionsRenameApps;
        }
        
        NSString *resultsMsg;
        if (self.dropView.selectedIPAs.count == 1) {
            //only 1 IPA is selected for re-signing
            NSURL *appURL = [self.dropView.selectedIPAs objectAtIndex:0];
            
            [self setupDragState:DragStateReSign];
            
            //everything is set up, lets re-sign the app
            NSURL *outputFileURL = [self.sm signAppWithIdenity:selectedIdentity appPath:appURL outputPath:outputURL options:options];
            if (outputFileURL) {
                //if a non-nil value was returned, that means we successfully re-signed the ipa
                NSInteger panelResult = NSRunAlertPanel(@"Success", @"The ipa was successfully re-signed!", @"OK", @"Open in Finder", nil);
                if (!panelResult) {
                    //open in finder option was selected so open in finder already
                    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[ outputFileURL ]];
                }
            }
        } else {
            //multiple IPAs were selected to be re-signed 
            NSArray *failedIpas = [self.sm signMultipleAppWithIdenity:selectedIdentity appPaths:self.dropView.selectedIPAs outputPath:outputURL options:options];
            if (failedIpas.count) {
                if (failedIpas.count == 1) {
                    resultsMsg = [NSString stringWithFormat:@"The following app failed to re-sign:\n  %@", [failedIpas objectAtIndex:0]];
                } else {
                    resultsMsg = [NSString stringWithFormat:@"The following %ld apps failed to re-sign:", (unsigned long)failedIpas.count];
                    for (NSURL *curFailedURL in failedIpas) {
                        resultsMsg = [resultsMsg stringByAppendingFormat:@"\n  %@", curFailedURL.path];
                    }
                }
                NSRunAlertPanel(@"Re-sign errors!", resultsMsg, nil, nil, nil);
            } else {
                resultsMsg = [NSString stringWithFormat:@"All %ld apps were successfully re-signed!", self.dropView.selectedIPAs.count];
                //Everything went ok, so let the user know!
                NSRunAlertPanel(@"Success",resultsMsg,nil, nil, nil);
            }
        }
    }
}

- (IBAction)doneBtnPressed:(id)sender {
    self.dropView.selectedIPAs = nil;
    self.statusTextView.string = @"";
    [self.multiAppInfoVC reset];
    [self setupDragState:DragStateInital];
}

- (IBAction)openMenuItemInvoked:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    openDlg.canChooseDirectories = NO;
    openDlg.canChooseFiles = YES;
    openDlg.canCreateDirectories = NO;
    openDlg.allowsMultipleSelection = YES;
    openDlg.allowedFileTypes = @[@"ipa"]; //TODO: shouldn't be hardcoded
    
    if ( [openDlg runModal] == NSOKButton ) {
        self.dropView.selectedIPAs = [NSArray arrayWithArray:openDlg.URLs];

        if (self.dropView.selectedIPAs.count == 1) {
            [self setupDragState:DragStateAppSelected];
            [self.appInfoVC loadIpaFile:openDlg.URL];
        } else {
            [self setupDragState:DragStateMultiAppsSelected];
            [self.multiAppInfoVC loadIpaFilesList:self.dropView.selectedIPAs];
        }
    
    }

}

- (IBAction)verboseOptionMenuItemInvoked:(id)sender {
    
    NSMenuItem *menuItem = (NSMenuItem *)sender;

    //toggle verbose state and store it's value
    self.isVerboseOutput = (menuItem.state+1) % 2;

    [menuItem setState:self.isVerboseOutput];
    
    //we've retrieved the value, now set to user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.isVerboseOutput forKey:kAppDefaultsIsVerboseOutput];
}

- (IBAction)showDevCertsMenuItemInvoked:(id)sender {
    //toggle state and update menu item
    self.isShowingDevCerts = (self.showDevCertsMenuItem.state + 1) % 2;
    [self.showDevCertsMenuItem setState:self.isShowingDevCerts];
    
    //store the new state in the user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.isShowingDevCerts forKey:kAppDefaultsShowDevCerts];
    
    //re-populate the pop-down based on the the user's selection
    BOOL wasSuccess = NO;
    if (self.isShowingDevCerts) {
        wasSuccess = [self populateCertPopDown:self.sm.getDistributionAndDevCertificatesList];
    } else {
        wasSuccess = [self populateCertPopDown:self.sm.getDistributionCertificatesList];
    }
    
    if (!wasSuccess) {
        [self displayNoValidCertError];
    }
}

- (IBAction)renameAppsMenuItemInvoked:(id)sender {
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    
    //toggle rename flag and store it's value
    self.shouldRenameApps = (menuItem.state+1) % 2;
    
    [menuItem setState:self.shouldRenameApps];
    
    //we've retrieved the value, now set to user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.shouldRenameApps forKey:kAppDefaultsShouldRenameApps];
}

#pragma mark - AppDropView delegate methods
- (void)appDropView:(AppDropView *)appDropView fileWasDraggedIntoView:(NSURL *)ipaPathURL {
    [self setupDragState:DragStateAppSelected];
    
    [self.appInfoVC loadIpaFile:ipaPathURL];
}

- (void)appDropView:(AppDropView *)appDropView filesWereDraggedIntoView:(NSArray *)ipaPathURLs {
    [self setupDragState:DragStateMultiAppsSelected];
    
    [self.multiAppInfoVC loadIpaFilesList:ipaPathURLs];
}

- (void)appDropView:(AppDropView *)appDropView invalidFileWasDraggedIntoView:(NSURL *)path {
    [self setupDragState:DragStateInital];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
