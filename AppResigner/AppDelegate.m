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
- (void)scrollToBottom;
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
    
    //place appInfoView where it should be
    self.appInfoVC.view.frame = self.appInfoPlaceholderView.frame;

    //[self.window.contentView replaceSubview:self.appInfoPlaceholderView with:self.appInfoVC.view];
    [self.window.contentView addSubview:self.appInfoVC.view];
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
            break;
        case DragStateAppSelected:
            [self.statusScrollView setHidden:YES];
            [self.progressBar stopAnimation:self];
            [self.dragMessageTextField setHidden:YES];
            [self.boxOutline setHidden:NO];
            break;
        case DragStateReSign:
            [self.statusScrollView setHidden:NO];
            [self.progressBar startAnimation:self];
            [self.dragMessageTextField setHidden:YES];
            [self.boxOutline setHidden:YES];
            [self.appInfoVC reset];
            break;
        case DragStateReSignComplete:
            [self.statusScrollView setHidden:NO];
            [self.progressBar stopAnimation:self];
            [self.dragMessageTextField setHidden:YES];
            [self.boxOutline setHidden:YES];
            [self.appInfoVC reset];
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
