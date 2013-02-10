//
//  AppDropView.m
//  AppResigner
//
//  Created by Carpe Lucem Media Group on 2/10/13.
//  Copyright (c) 2013 Carpe Lucem Media Group. All rights reserved.
//

#import "AppDropView.h"

@implementation AppDropView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
        [self addCursorRect:self.bounds cursor:[NSCursor openHandCursor]];
    }
    
    return self;
}

#pragma mark - cursor methods
- (void)activateDragCursor {
    [[NSCursor openHandCursor] set];
}

- (void)deactivetDragCursor {
    [NSCursor pop];
}

#pragma mark - drag protocol methods

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    [self activateDragCursor];
    return NSDragOperationGeneric;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
    [self deactivetDragCursor];
    [self setNeedsDisplay:YES];
}
- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    [self setNeedsDisplay:YES];
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSArray *filenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    //For now, just handle one file
    if (filenames.count > 0) {
        NSString *path = [filenames objectAtIndex:0];
        
        if ([path hasSuffix:@".ipa"]) {
            return YES;
        }
    }
    
    NSRunAlertPanel(@"Invalid file", @"Please select an ipa", nil, nil, nil);
    return NO;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    [self deactivetDragCursor];
    NSArray *filenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    self.selectedIPA = [filenames objectAtIndex:0];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
