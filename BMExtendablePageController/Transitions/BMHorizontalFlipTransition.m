//
//  BMHorizontalFlipTransition.m
//  BMExtendablePageController
//
//  Created by Benjamin Müller on 23.04.13.
//  Copyright (c) 2013 Benjamin Müller. All rights reserved.
//

#import "BMHorizontalFlipTransition.h"
#import "NSLayoutConstraint+PlacementHelper.h"

@implementation BMHorizontalFlipTransition

+(id<BMExtendablePageTransition>)transition{
    return [[BMHorizontalFlipTransition alloc] init];
}

-(void)transitionFromIndex:(int)fromIdx toIndex:(int)toIdx
              withDuration:(float)duration
             andCurrenView:(VIEW *)currentView
                toNextView:(VIEW *)nextView
           onContainerView:(VIEW *)containerView
            withCompletion:(void (^)())completion{

    // ensure currentView fills superview
    NSLayoutConstraint* currentAlignmentConstraint = [NSLayoutConstraint fillSuperView:currentView];
    
    // bound next view to current view
    [NSLayoutConstraint stickView:nextView
                    nextToSibling:currentView
                        direction:(toIdx > fromIdx ? BM_LAYOUT_DIRECTION_RIGHT : BM_LAYOUT_DIRECTION_LEFT)];
    
    float destOffset = containerView.bounds.size.width * ((toIdx > fromIdx) ? -1. : 1.);
    
    // animate transition
#if TARGET_OS_IPHONE

    [UIView animateWithDuration:duration delay:0. options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         [currentAlignmentConstraint setConstant:destOffset];
                         
                     } completion:^(BOOL finished) {
                         
                         completion();
                     }];
#else
    [[NSAnimationContext currentContext] setDuration:duration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        
        [[currentAlignmentConstraint animator] setConstant:destOffset];
        
    } completionHandler:^{
        
        [NSLayoutConstraint removeConstraintsFromSuperView:currentView];
        [NSLayoutConstraint fillSuperView:nextView];
        
        completion();
    }];
#endif
}



@end
