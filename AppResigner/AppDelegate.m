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

@interface AppDelegate()
- (void)scrollToBottom;
@property (nonatomic, strong) SecurityManager *sm;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.sm = [SecurityManager defaultManager];
    
    //place appInfoView where it should be
    self.appInfoVC.view.frame = self.appInfoPlaceholderView.frame;
    
    //[self.window.contentView replaceSubview:self.appInfoPlaceholderView with:self.appInfoVC.view];
    [self.window.contentView addSubview:self.appInfoVC.view];
    
    self.outputPathURL = kAppResignerDefaultOutputURL;
    [self.dropView setDelegate:self];
    [self registerForNotifications];
    
    if ([self populateCertPopDown:[self.sm getDistributionCertificatesList]]) {
        [self setupDragState:DragStateInital];
    } else {
        [self setupDragState:DragStateFatalError];
         NSRunAlertPanel(@"Certificate Error",
            @"No valid certificates were found!\n"
            "Please install a distribution certificate using the 'Keychain Access' tool.\n\n"
            "The Keychain Access tool can be found in Applications -> Utilities\n\n"
            "A certificate is needed to resign your apps!", nil, nil, nil);
    }
}

- (void)initTextFields {
    //TODO
}

- (void)setupDragState:(DragState)dragState {
    switch (dragState) {
        case DragStateInital:
            [self.statusScrollView setHidden:YES];
            [self.progressBar stopAnimation:self];
            [self.dragMessageTextField setHidden:NO];
            [self.boxOutline setHidden:NO];
            [self.appInfoVC reset];
            [self.clearBtn setHidden:YES];
            break;
        case DragStateAppSelected:
            [self.statusScrollView setHidden:YES];
            [self.progressBar stopAnimation:self];
            [self.dragMessageTextField setHidden:YES];
            [self.boxOutline setHidden:NO];
            [self.clearBtn setHidden:YES];
            break;
        case DragStateReSign:
            [self.statusScrollView setHidden:NO];
            [self.progressBar startAnimation:self];
            [self.dragMessageTextField setHidden:YES];
            [self.boxOutline setHidden:YES];
            [self.appInfoVC reset];
            [self.clearBtn setHidden:YES];
            break;
        case DragStateReSignComplete:
            [self.statusScrollView setHidden:NO];
            [self.progressBar stopAnimation:self];
            [self.dragMessageTextField setHidden:YES];
            [self.boxOutline setHidden:YES];
            [self.appInfoVC reset];
            [self.clearBtn setHidden:NO];
            break;
        case DragStateRecoverableError:
            [self.statusScrollView setHidden:NO];
            [self.progressBar stopAnimation:self];
            [self.dragMessageTextField setHidden:YES];
            [self.boxOutline setHidden:YES];
            [self.appInfoVC reset];
            [self.clearBtn setHidden:NO];
            break;
        case DragStateFatalError:
            [self.statusScrollView setHidden:YES];
            [self.progressBar stopAnimation:self];
            [self.dragMessageTextField setHidden:YES];
            [self.boxOutline setHidden:NO];
            [self.appInfoVC reset];
            [self.clearBtn setHidden:YES];
            
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
}

- (BOOL)populateCertPopDown:(NSArray *)certModels {
    BOOL wasSuccess = YES;
    [self.certPopDownBtn removeAllItems];
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
    if (self.dropView.selectedIPA && self.pathTextField.stringValue) {
        [self setupDragState:DragStateReSign];
        NSString *selectedIdentity = self.certPopDownBtn.selectedItem.title;
        NSURL *appURL = [NSURL URLWithString:self.dropView.selectedIPA];
        NSURL *outputURL = [NSURL URLWithString:self.pathTextField.stringValue];
        [self.sm signAppWithIdenity:selectedIdentity appPath:appURL outputPath:outputURL];
    } else {
        //TODO: handle errors more legantly
        NSLog(@"Not all fields are defined");
    }
}

- (IBAction)clearBtnPressed:(id)sender {
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
