//
//  BMQuartzComposerTransition.h
//  BMExtendablePageController
//
//  Created by Benjamin Müller on 28.05.13.
//  Copyright (c) 2013 Benjamin Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMExtendablePageController.h"

@interface BMCoreImageTransition : NSObject<BMExtendablePageTransition>

/**
 * The CoreImageTransition will be applyed when replacing the subviews.
   @required
 */
@property CATransition* coreImageTransition;

/**
 * Convenience method to easily create an instance of BMCoreImageTransition.
 */
+(id<BMExtendablePageTransition>)transitionWithCATransition:(CATransition*)coreImageTransition inDuration:(float)time;


/**
 * This is an example implementation of a ribble transition which you cann pass to transitionWithCATransition:
    OSX only - using private API on iOS.
 */
+(CATransition*)ribbleTransitionWithRect:(RECT)rect;

@end
