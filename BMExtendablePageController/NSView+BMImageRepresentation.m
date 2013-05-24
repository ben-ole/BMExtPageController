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
    
    [self setWantsLayer:YES];
    [self.layer display];
    CGContextRef ctx = NULL;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    int pixelsHigh = (int)self.layer.bounds.size.height;
    int pixelsWide = (int)self.layer.bounds.size.width;
    
    NSLog(@"w: %i h: %i",pixelsWide,pixelsHigh);
    
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    ctx = CGBitmapContextCreate (NULL,
                                 pixelsWide,
                                 pixelsHigh,
                                 8,
                                 bitmapBytesPerRow,
                                 colorSpace,
                                 kCGImageAlphaPremultipliedLast);
    
    if (ctx == NULL){
        NSLog(@"Failed to create context.");
        return nil;
    }
    
    [self.layer display];
    
    CGImageRef img = CGBitmapContextCreateImage(ctx);
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:img];
    
    
    NSData *imageData = [bitmap representationUsingType:NSPNGFileType properties:nil];
    [imageData writeToFile:@"/Users/Benjamin/Desktop/test/test.png" atomically:NO];

    CGColorSpaceRelease( colorSpace );
//    CGContextRelease(ctx);
    
    return img;

#endif
}
@end
