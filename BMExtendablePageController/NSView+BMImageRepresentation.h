//
//  NSView+BMImageRepresentation.h
//  BMExtendablePageController
//
//  Created by Benjamin Müller on 21.05.13.
//  Copyright (c) 2013 Benjamin Müller. All rights reserved.
//

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define VIEW_CONTROLLER UIViewController
#define VIEW UIView
#define RECT CGRect
#else
#import <Cocoa/Cocoa.h>
#define VIEW_CONTROLLER NSViewController
#define VIEW NSView
#define RECT NSRect
#endif
#endif

@interface VIEW (BMImageRepresentation)

- (CGImageRef)imageRepresentation;

@end
