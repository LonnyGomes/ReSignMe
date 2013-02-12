//
//  AppDelegate.m
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/9/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import "AppDelegate.h"
#import "CertificateModel.h"
#import "SecurityManager.h"

@interface AppDelegate()
@property (nonatomic, strong) SecurityManager *sm;

@end
@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.sm = [SecurityManager defaultManager];
    
    [self populateCertPopDown:[self.sm getDistributionCertificatesList]];
    self.outputPathURL = kAppResignerDefaultOutputURL;
    [self setupDragState:DragStateInital];
    [self.dropView setDelegate:self];
    [self registerForNotifications];
}

- (void)initTextFields {
    //TODO
}

- (void)setupDragState:(DragState)dragState {
    switch (dragState) {
        case DragStateInital:
            [self.statusScrollView setHidden:YES];
            [self.progressBar setHidden:YES];
            [self.dragMessageTextField setHidden:NO];
            break;
        case DragStateAppSelected:
            [self.statusScrollView setHidden:YES];
            [self.progressBar setHidden:YES];
            [self.dragMessageTextField setHidden:YES];
            break;
        case DragStateReSign:
            [self.statusScrollView setHidden:NO];
            [self.progressBar setHidden:NO];
            [self.dragMessageTextField setHidden:YES];
            break;
        default:
            break;
    }    
}

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processSecuirtyManagerEvent:) name:kSecurityManagerNotificationEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processSecuirtyManagerEvent:) name:kSecurityManagerNotificationEventOutput object:nil];
}

- (void)setOutputPathURL:(NSURL *)pathURL {
    _outputPathURL = pathURL;
    [self.pathTextField setStringValue:[_outputPathURL.path stringByExpandingTildeInPath]];
}

- (void)populateCertPopDown:(NSArray *)certModels {
    for (CertificateModel *curModel in certModels) {
        [self.certPopDownBtn removeAllItems];
        [self.certPopDownBtn addItemWithTitle:curModel.label];
    }
}

#pragma mark - Security Manager Notifcation selectors
- (void)processSecuirtyManagerEvent:(NSNotification *)notification {
    NSString *message = [notification.userInfo valueForKey:kSecurityManagerNotificationKey];
    NSLog(@"Got notification:%@", message);
    //TODO:based on the notification type, format the text
    if ([notification.name isEqualToString:kSecurityManagerNotificationEvent]) {
        [self.statusTextView setString:[self.statusTextView.string stringByAppendingFormat:@"%@\n", message]];
    } else if ([notification.name isEqualToString:kSecurityManagerNotificationEventOutput]) {
        [self.statusTextView setString:[self.statusTextView.string stringByAppendingFormat:@"%@", message]];
    }

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

#pragma mark - AppDropView delegate methods
- (void)appDropView:(AppDropView *)appDropView fileWasDraggedIntoView:(NSURL *)path {
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
