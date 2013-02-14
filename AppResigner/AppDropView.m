//
//  AppDropView.m
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/10/13.
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


#import "AppDropView.h"
@interface AppDropView()
- (BOOL)isValidForFileAtPath:(NSString *)path;
- (NSString *)getFilenameFromPasteBoard:(id<NSDraggingInfo>)sender;
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


#pragma mark - ipa valididy checks
- (BOOL)isValidForFileAtPath:(NSString *)path {
    if ([path hasSuffix:@".ipa"]) {
        return YES;
    }
    
    return NO;
}

- (NSString *)getFilenameFromPasteBoard:(id<NSDraggingInfo>)sender {
    NSString *path = nil;
    NSArray *filenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    //For now, just handle one file
    if (filenames.count > 0) {
        path = [filenames objectAtIndex:0];
    }
    
    return path;
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
    NSString *path = [self getFilenameFromPasteBoard:sender];
    self.isInDragState = YES;
    self.isValidFile = [self isValidForFileAtPath:path];
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
    NSString *path = [self getFilenameFromPasteBoard:sender];
   
    if ([self isValidForFileAtPath:path]) {
        return YES;
    } else {
        self.isInDragState = NO;
        [self setNeedsDisplay:YES];
        
        self.selectedIPA = nil;
        
        NSRunAlertPanel(@"Invalid file", @"Please select an ipa. It can be dragged into the application.", nil, nil, nil);
        
        if (self.delegate) {
            [self.delegate performSelector:@selector(appDropView:invalidFileWasDraggedIntoView:) withObject:self withObject:path];
        }
        return NO;
    }    
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    [self deactivetDragCursor];
    self.isInDragState = NO;
    [self setNeedsDisplay:YES];
    
    self.selectedIPA = [self getFilenameFromPasteBoard:sender];
    
    if (self.delegate && self.selectedIPA) {
        [self.delegate performSelector:@selector(appDropView:fileWasDraggedIntoView:) withObject:self withObject:[NSURL URLWithString:self.selectedIPA]];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (!self.isInDragState) return;
    CGContextRef context = (CGContextRef)([[NSGraphicsContext currentContext] graphicsPort]);
    
    NSColor *clr = (self.isValidFile) ? HOVER_CLR_VALID : HOVER_CLR_INVALID;
    CGColorRef hoverClr = clr.CGColor;
    
    CGContextSetFillColorWithColor(context, hoverClr);
    CGContextFillRect(context, self.bounds);
}

@end
