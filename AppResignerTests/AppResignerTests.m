//
//  AppResignerTests.m
//  AppResignerTests
//
//  Created by Carpe Lucem Media Group on 2/9/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import "AppResignerTests.h"
#import "AppDelegate.h"

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

- (void)testOutputPathURL
{
    NSURL *myPathURL = [NSURL URLWithString:@"/usr/bin"];
    [appDelegate setOutputPathURL:myPathURL];
    
    NSString *myPath = [myPathURL path];
    NSString *returnedPath = appDelegate.pathTextField.stringValue;
    STAssertEqualObjects(myPath, returnedPath, @"The path set with NSURL should equal the path in the text field!");
}

@end
