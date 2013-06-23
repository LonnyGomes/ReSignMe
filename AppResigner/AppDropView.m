//
//  AppDropView.m
//  ReSignMe
//
//  Created by Carpe Lucem Media Group on 2/10/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//
//  This file is part of ReSignMe.
//
//  ReSignMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ReSignMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ReSignMe.  If not, see <http://www.gnu.org/licenses/>.


#import "AppDropView.h"
@interface AppDropView()
- (BOOL)isValidForFileAtPath:(NSString *)path;
- (NSArray *)getIpaFilenamesFromPasteBoard:(id<NSDraggingInfo>)sender;
@property (nonatomic, assign) BOOL isValidFile;
@end

@implementation AppDropView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
        [self addCursorRect:self.bounds cursor:[NSCursor openHandCursor]];
        self.isInDragState = NO;
        self.isValidFile = NO;
    }
    
    return self;
}

- (NSString *)currentIPA {
    //TODO: this currently is a stub method
    if (self.selectedIPAs) {
        return [self.selectedIPAs objectAtIndex:0];
    }
    
    return nil;
}

#pragma mark - ipa valididy checks
- (BOOL)isValidForFileAtPath:(NSString *)path {
    if ([path hasSuffix:@"ipa"]) {
        return YES;
    }
    
    return NO;
}

- (NSArray *)getIpaFilenamesFromPasteBoard:(id<NSDraggingInfo>)sender {
    NSArray *paths = nil;
    NSArray *filenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    NSMutableArray *validFiles = [NSMutableArray array];
    
    for (NSString *curFilename in filenames) {
        if ([self isValidForFileAtPath:curFilename]) {
            [validFiles addObject:curFilename];
        }
    }
    //For now, just handle one file
    if (filenames.count > 0) {
        paths = [NSArray arrayWithArray:validFiles];
    }
    
    return paths;
}

#pragma mark - cursor methods
- (void)activateDragCursor {
    if (self.isValidFile) {
        [[NSCursor openHandCursor] set];
    } else {
        [self deactivetDragCursor];
    }
}

- (void)deactivetDragCursor {
    [[NSCursor operationNotAllowedCursor] set];
}


#pragma mark - drag protocol methods
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSArray *paths = [self getIpaFilenamesFromPasteBoard:sender];
    self.isInDragState = YES;

    //if we have at least one value, the drag is valid
    self.isValidFile = (paths.count) ? YES : NO;
    
    [self setNeedsDisplay:YES];
    [self activateDragCursor];
    return NSDragOperationGeneric;
}


- (void)draggingExited:(id<NSDraggingInfo>)sender {
    [self deactivetDragCursor];
    self.isInDragState = NO;
    self.isValidFile = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    self.isInDragState = YES;
    [self setNeedsDisplay:YES];

    return YES;
}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender {
    [self activateDragCursor];
    self.isInDragState = YES;
    [self setNeedsDisplay:YES];
    
    return NSDragOperationGeneric;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSArray *paths = [self getIpaFilenamesFromPasteBoard:sender];
   
    if (paths.count) {
        return YES;
    } else {
        self.isInDragState = NO;
        [self setNeedsDisplay:YES];
        
        self.selectedIPAs = nil;
        
        NSRunAlertPanel(@"Invalid file", @"Please select an ipa. It can be dragged into the application.", nil, nil, nil);
        
        if (self.delegate) {
            [self.delegate performSelector:@selector(appDropView:invalidFileWasDraggedIntoView:) withObject:self withObject:nil];
        }
        return NO;
    }    
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    [self deactivetDragCursor];
    self.isInDragState = NO;
    [self setNeedsDisplay:YES];
    
    //TODO: handle multiple files
    NSArray *paths  = [self getIpaFilenamesFromPasteBoard:sender];
    self.selectedIPAs = [NSArray arrayWithArray:paths];
    
    if (self.delegate && self.selectedIPAs) {
        if (self.selectedIPAs.count == 1) {
            NSURL *ipaURL = [NSURL URLWithString:[[self.selectedIPAs objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [self.delegate performSelector:@selector(appDropView:fileWasDraggedIntoView:) withObject:self withObject:ipaURL];
        } else {
            NSMutableArray *urls = [NSMutableArray array];
            NSURL *curIpaURL;
            for (NSString *curIpaFilename in self.selectedIPAs) {
                curIpaURL = [NSURL URLWithString:[curIpaFilename stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                [urls addObject:curIpaURL];
            }

            [self.delegate performSelector:@selector(appDropView:filesWereDraggedIntoView:) withObject:self withObject:urls];

        }
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (!self.isInDragState) return;
    CGContextRef context = (CGContextRef)([[NSGraphicsContext currentContext] graphicsPort]);
    
    NSColor *clr = (self.isValidFile) ? HOVER_CLR_VALID : HOVER_CLR_INVALID;
    CGColorRef hoverClr = CGColorCreateGenericRGB(clr.redComponent, clr.greenComponent, clr.blueComponent, clr.alphaComponent);
    
    CGContextSetFillColorWithColor(context, hoverClr);
    CGContextFillRect(context, self.bounds);
    CGColorRelease(hoverClr);
}

@end
