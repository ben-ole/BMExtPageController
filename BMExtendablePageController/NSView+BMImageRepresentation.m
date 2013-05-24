//
//  NSView+BMImageRepresentation.m
//  BMExtendablePageController
//
//  Created by Benjamin Müller on 21.05.13.
//  Copyright (c) 2013 Benjamin Müller. All rights reserved.
//

#import "NSView+BMImageRepresentation.h"

@implementation VIEW (BMImageRepresentation)


- (CGImageRef)imageRepresentation {
	
#if TARGET_OS_IPHONE
    #warning to be implemented!
    
//    CGRect offscreenRect = self.bounds;
//    NSBitmapImageRep* offscreenRep = nil;
//    
//    offscreenRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil
//                                                           pixelsWide:offscreenRect.size.width
//                                                           pixelsHigh:offscreenRect.size.height
//                                                        bitsPerSample:8
//                                                      samplesPerPixel:4
//                                                             hasAlpha:YES
//                                                             isPlanar:NO
//                                                       colorSpaceName:NSCalibratedRGBColorSpace
//                                                         bitmapFormat:0
//                                                          bytesPerRow:(4 * offscreenRect.size.width)
//                                                         bitsPerPixel:32];
//    
//    [NSGraphicsContext saveGraphicsState];
//    [NSGraphicsContext setCurrentContext:[NSGraphicsContext
//                                          graphicsContextWithBitmapImageRep:offscreenRep]];
//    
//    [self display];
//    
//    [NSGraphicsContext restoreGraphicsState];
//    
//    return offscreenRep.CGImage;
    return nil;
#else
    
    NSBitmapImageRep* bitmap = [self bitmapImageRepForCachingDisplayInRect:self.bounds];
    
    [self cacheDisplayInRect:self.bounds toBitmapImageRep:bitmap];
    
    return    bitmap.CGImage;
    

#endif
}
@end
