//
//  CertificateModel.h
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/9/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CertificateModel : NSObject
- (id)initWithCertificateData:(NSDictionary *)certData;
@property (nonatomic, strong) NSString *label;
@end
