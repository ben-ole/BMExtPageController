//
//  BMHorizontalFlipTransition.m
//  BMExtendablePageController
//
//  Created by mno on 13.05.13.
//  Copyright (c) 2013 urbn;. All rights reserved.
//

#import "BMVerticalFlipTransition.h"
#import "NSLayoutConstraint+PlacementHelper.h"

@implementation BMVerticalFlipTransition

@synthesize duration=_duration;

+(id<BMExtendablePageTransition>)transitionWithDuration:(float)time{

    BMVerticalFlipTransition* trans = [[BMVerticalFlipTransition alloc] init];
    trans.duration = time;
    
    return trans;
}

-(void)transitionFromIndex:(int)fromIdx toIndex:(int)toIdx
             andCurrenView:(VIEW *)currentView
                toNextView:(VIEW *)nextView
           onContainerView:(VIEW *)containerView
            withCompletion:(void (^)())completion{

    // ensure currentView fills superview
    NSLayoutConstraint* currentAlignmentConstraint = [NSLayoutConstraint fillSuperView:currentView center:BM_LAYOUT_CENTER_Y];
    
    // bound next view to current view
    [NSLayoutConstraint stickView:nextView
                    nextToSibling:currentView
                        direction:(toIdx > fromIdx ? BM_LAYOUT_DIRECTION_BOTTOM : BM_LAYOUT_DIRECTION_TOP)];
    
    float destOffset = containerView.bounds.size.height * ((toIdx > fromIdx) ? -1. : 1.);
    
    // animate transition
#if TARGET_OS_IPHONE

    [UIView animateWithDuration:self.duration delay:0. options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         [currentAlignmentConstraint setConstant:destOffset];
                         
                     } completion:^(BOOL finished) {
                         
                         completion();
                     }];
#else
    [[NSAnimationContext currentContext] setDuration:self.duration];
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
