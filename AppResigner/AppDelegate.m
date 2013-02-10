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
}

- (void)setOutputPathURL:(NSURL *)outputPathURL {
    _outputPathURL = outputPathURL;
    [self.pathTextField setStringValue:outputPathURL.path];
}

- (void)populateCertPopDown:(NSArray *)certModels {
    for (CertificateModel *curModel in certModels) {
        [self.certPopDownBtn removeAllItems];
        [self.certPopDownBtn addItemWithTitle:curModel.label];
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
        NSString *selectedIdentity = self.certPopDownBtn.selectedItem.title;
        NSURL *appURL = [NSURL URLWithString:self.dropView.selectedIPA];
        NSURL *outputURL = [NSURL URLWithString:self.pathTextField.stringValue];
        [self.sm signAppWithIdenity:selectedIdentity appPath:appURL outputPath:outputURL];
    } else {
        //TODO: handle errors more legantly
        NSLog(@"Not all fields are defined");
    }
}
@end
