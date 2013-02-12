//
//  AppDropDelegate.h
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/11/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDropView;

@protocol AppDropDelegate <NSObject>
@required
- (void)appDropView:(AppDropView *)appDropView fileWasDraggedIntoView:(NSURL *)path;

@end
