//
//  NSView+BMImageRepresentation.m
//  BMExtendablePageController
//
//  Created by Benjamin Müller on 21.05.13.
//  Copyright (c) 2013 Benjamin Müller. All rights reserved.
//

#import "NSView+BMImageRepresentation.h"
#import <QuartzCore/QuartzCore.h>

@implementation VIEW (BMImageRepresentation)


- (CGImageRef)imageRepresentation {
	
#if TARGET_OS_IPHONE
    
    UIGraphicsBeginImageContext(self.bounds.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, self.bounds);
    
    [self.layer renderInContext:ctx];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return newImage.CGImage;
#else
    
    NSBitmapImageRep* bitmap = [self bitmapImageRepForCachingDisplayInRect:self.bounds];
    
    [self cacheDisplayInRect:self.bounds toBitmapImageRep:bitmap];
    
    return    bitmap.CGImage;
#endif
}
@end
