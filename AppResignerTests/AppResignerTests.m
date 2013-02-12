//
//  AppResignerTests.m
//  AppResignerTests
//
//  Created by Carpe Lucem Media Group on 2/9/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import "AppResignerTests.h"
#import "AppDelegate.h"
#import "SecurityManager.h"
#import "CertificateModel.h"
#import <OCMock/OCMock.h>

@interface AppDelegate(UnitTests)
@property (nonatomic, strong) SecurityManager *sm;
@end

@implementation AppResignerTests
AppDelegate *appDelegate;

- (void)setUp
{
    [super setUp];
    
    appDelegate = (AppDelegate *)[NSApp delegate];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testApplicationDidFinishLaunching {
    [appDelegate applicationDidFinishLaunching:nil];
    STAssertNotNil(appDelegate.sm, @"Security manager was not initialized");
    STAssertNotNil(appDelegate.outputPathURL, @"The output path should be populated on initialization");
    STAssertEqualObjects(appDelegate.dropView.delegate, appDelegate, @"The AppDropView has not beeen set!");
}

- (void)testPopulateCertIsCalledAtInit {
    id appDelegateMock = [OCMockObject mockForClass:[AppDelegate class]];
    [[appDelegateMock expect] populateCertPopDown:[OCMArg any]];
    [appDelegateMock verify];
}

//- (void)testPopulateCertPopDown {
//    id mockCertModel = [OCMockObject mockForClass:[CertificateModel class]];
//    [[[mockCertModel stub] andReturn:@"My Label"] label];
//    
//    id mockCertPopDownBtn = [OCMockObject mockForClass:[NSPopUpButton class]];
//    [[mockCertPopDownBtn expect] removeAllItems];
//    [[mockCertPopDownBtn expect] addItemWithTitle:[OCMArg any]];
//    appDelegate.certPopDownBtn = mockCertModel;
//    
//    //NSArray *models = @[mockCertModel];
//    
//    [appDelegate populateCertPopDown:[NSArray arrayWithObject:mockCertModel]];
////    
////    [mockCertPopDownBtn verify];
//}

- (void)testOutputPathURL
{
    NSURL *myPathURL = [NSURL URLWithString:@"/usr/bin"];
    [appDelegate setOutputPathURL:myPathURL];
    
    NSString *myPath = [myPathURL path];
    NSString *returnedPath = appDelegate.pathTextField.stringValue;
    STAssertEqualObjects(myPath, returnedPath, @"The path set with NSURL should equal the path in the text field!");
}

@end
