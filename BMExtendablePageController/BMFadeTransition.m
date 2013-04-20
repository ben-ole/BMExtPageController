//
//  URBNFadePageTransition.m
//  PRSNTR
//
//  Created by Benjamin Müller on 16.04.13.
//  Copyright (c) 2013 urbn. All rights reserved.
//

#import "BMFadeTransition.h"

@implementation BMFadeTransition

-(void)transitionFromIndex:(int)fromIdx toIndex:(int)toIdx withDuration:(float)duration andCurrenView:(UIView *)currentView toNextView:(UIView *)nextView onContainerView:(UIView *)containerView withCompletion:(void (^)())completion{

    if (toIdx > fromIdx) {  // forward
            // insert new view controller behind and fade current out
        [containerView insertSubview:nextView
                        belowSubview:nextView];
        
        nextView.frame = containerView.bounds;
        
        [UIView animateWithDuration:duration animations:^{
            currentView.alpha = 0.;
        } completion:^(BOOL finished) {
            [currentView removeFromSuperview];
            completion();
        }];
        
    }else{
        // insert new view controller on top and fade in
        nextView.alpha = 0.;
        
        [containerView insertSubview:nextView
                        aboveSubview:currentView];
        
        nextView.frame = containerView.bounds;

        [UIView animateWithDuration:duration animations:^{
            nextView.alpha = 1.;
        } completion:^(BOOL finished) {
            [currentView removeFromSuperview];
            completion();
        }];
    }
}

@end
