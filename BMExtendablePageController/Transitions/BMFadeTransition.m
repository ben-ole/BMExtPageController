//
//  URBNFadePageTransition.m
//  PRSNTR
//
//  Created by Benjamin Müller on 16.04.13.
//  Copyright (c) 2013 urbn. All rights reserved.
//

#import "BMFadeTransition.h"
#import "NSLayoutConstraint+PlacementHelper.h"

@implementation BMFadeTransition{

}

+(id<BMExtendablePageTransition>)transition{
    
    return [[BMFadeTransition alloc] init];
}

-(void)transitionFromIndex:(int)fromIdx toIndex:(int)toIdx withDuration:(float)duration andCurrenView:(VIEW *)currentView toNextView:(VIEW *)nextView onContainerView:(VIEW *)containerView withCompletion:(void (^)())completion{

    [NSLayoutConstraint fillSuperView:currentView];

    if (toIdx > fromIdx) {  // forward
        // insert new view controller behind and fade current out
        
#if TARGET_OS_IPHONE

        [containerView sendSubviewToBack:nextView];
        [NSLayoutConstraint fillSuperView:nextView];
        nextView.alpha = 0.;

        [UIView animateWithDuration:duration animations:^{
            currentView.alpha = 0.;
            nextView.alpha = 1.;
        } completion:^(BOOL finished) {
                             
            [NSLayoutConstraint removeConstraintsFromSuperView:currentView];

            completion();
            currentView.alpha = 1.;
        }];
#else
        [nextView removeFromSuperviewWithoutNeedingDisplay];
        [nextView setAlphaValue:0.];
        [containerView addSubview:nextView positioned:NSWindowBelow relativeTo:currentView];
        [NSLayoutConstraint fillSuperView:nextView];
        
        
        [[NSAnimationContext currentContext] setDuration:duration];
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [[currentView animator] setAlphaValue:0.];
            [[nextView animator] setAlphaValue:1.];
        } completionHandler:^{
            
            [NSLayoutConstraint removeConstraintsFromSuperView:currentView];
            
            completion();
            currentView.alphaValue = 1.;
        }];
        
#endif
        
    }else{
        // insert new view controller on top and fade in

#if TARGET_OS_IPHONE
        [containerView bringSubviewToFront:nextView];
        [NSLayoutConstraint fillSuperView:nextView];
        
        nextView.alpha = 0.;
        
        [UIView animateWithDuration:duration animations:^{
            nextView.alpha = 1.;
            currentView.alpha = 0.;
        } completion:^(BOOL finished) {
            completion();
            currentView.alpha = 1.;
        }];
#else
        [nextView removeFromSuperviewWithoutNeedingDisplay];
        [containerView addSubview:nextView positioned:NSWindowAbove relativeTo:currentView];
        [NSLayoutConstraint fillSuperView:nextView];        
        
        nextView.alphaValue = 0.;
        
        [[NSAnimationContext currentContext] setDuration:duration];
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [[nextView animator] setAlphaValue:1.];
            [[currentView animator] setAlphaValue:0.];
        } completionHandler:^{
            [NSLayoutConstraint removeConstraintsFromSuperView:currentView];
            
            completion();
            [currentView setAlphaValue:1.0];
        }];
#endif
    }
    
}

@end
