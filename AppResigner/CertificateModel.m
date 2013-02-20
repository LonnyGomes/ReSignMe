//
//  CertificateModel.m
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/9/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//
//  This file is part of EzAppResigner.
//
//  Foobar is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Foobar is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

#import "CertificateModel.h"
#include <CommonCrypto/CommonDigest.h>

@implementation CertificateModel
- (id)initWithCertificateData:(NSDictionary *)certData {
    self = [super init];
    if (self) {
        self.label = [certData objectForKey:@"labl"];
        NSData *data =  [NSData dataWithData:[certData objectForKey:@"issr"]];
        
//        //build hex string from cert data
//        NSMutableString *hexStr = [NSMutableString string];
//        const unsigned char *c = data.bytes;
//        for (int idx = 0; idx < data.length; idx++) {
//            [hexStr appendFormat:@"%02x", *c];
//            c++;
//        }
        
        NSMutableString *shaHash = [NSMutableString string];
        unsigned char shaDigest[CC_SHA1_DIGEST_LENGTH];
        if (CC_SHA1(data.bytes, (unsigned int)data.length, shaDigest)) {
            NSLog(@"got hash");
            
            const unsigned char *ptr = shaDigest;
            for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
                [shaHash appendFormat:@"%02x", shaDigest[i]];
                //ptr++;
            }
        }
        
        self.keyHash = shaHash;
    }
    
    return self;
}
@end
