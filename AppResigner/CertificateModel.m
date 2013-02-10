//
//  CertificateModel.m
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/9/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import "CertificateModel.h"

@implementation CertificateModel
- (id)initWithCertificateData:(NSDictionary *)certData {
    self = [super init];
    if (self) {
        self.label = [certData objectForKey:@"labl"];
    }
    
    return self;
}
@end
