//
//  BMHorizontalFlipTransition.m
//  BMExtendablePageController
//
//  Created by Benjamin Müller on 23.04.13.
//  Copyright (c) 2013 Benjamin Müller. All rights reserved.
//

#import "BMHorizontalFlipTransition.h"
#import "NSLayoutConstraint+PlacementHelper.h"
#import "CAAnimation+Blocks.h"
#import "NSView+BMImageRepresentation.h"

@implementation BMHorizontalFlipTransition{

}

+(id<BMExtendablePageTransition>)transition{
    return [[BMHorizontalFlipTransition alloc] init];
}

-(void)transitionFromIndex:(int)fromIdx toIndex:(int)toIdx
              withDuration:(float)duration
             andCurrenView:(VIEW *)currentView
                toNextView:(VIEW *)nextView
           onContainerView:(VIEW *)containerView
            withCompletion:(void (^)())completion{
    
    
    float destOffset = containerView.bounds.size.width * ((toIdx > fromIdx) ? -1. : 1.);
    
    [NSLayoutConstraint fillSuperView:nextView];
    
    CGImageRef currImg = [currentView imageRepresentation];
    
    CGImageRef nextImg = [nextView imageRepresentation];
    
    // create animation layer
    CALayer* animationLayer = [CALayer layer];
    animationLayer.frame = currentView.bounds;
    
    // add a layer for current view to animationLayer
    CALayer* currentLayer = [CALayer layer];
    [currentLayer setContents:(__bridge id)(currImg)];
    currentLayer.frame = currentView.bounds;
    [animationLayer addSublayer:currentLayer];
    
    // add a layer for next view to animationLayer
    CALayer* nextLayer = [CALayer layer];
    [nextLayer setContents:(__bridge id)(nextImg)];
    nextLayer.frame = CGRectOffset(nextView.bounds, -destOffset, 0.);
    [animationLayer addSublayer:nextLayer];

    // add layer to container
    #if !TARGET_OS_IPHONE
        animationLayer.frame = CGRectOffset(currentView.bounds, 0., -3.);   // strange offset
        [containerView setWantsLayer:YES];
    #endif
    
    [containerView.layer addSublayer:animationLayer];
    
    // do actual scene change
    [NSLayoutConstraint removeConstraintsFromSuperView:currentView];    
    
    // animate transition
    CABasicAnimation* slideAnimation = [CABasicAnimation animationWithKeyPath: @"transform.translation.x"];
    slideAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    slideAnimation.toValue = [NSNumber numberWithFloat:destOffset];
    slideAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    slideAnimation.duration = duration;
    slideAnimation.repeatCount = 0;
    slideAnimation.removedOnCompletion = NO;
    slideAnimation.fillMode = kCAFillModeForwards;

    [slideAnimation setCompletion:^(BOOL finished) {
        [animationLayer removeFromSuperlayer];
        completion();
    }];
    [animationLayer addAnimation:slideAnimation forKey:@"transform.translation.x"];

}

@end


