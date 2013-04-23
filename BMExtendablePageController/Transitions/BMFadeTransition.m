//
//  URBNFadePageTransition.m
//  PRSNTR
//
//  Created by Benjamin Müller on 16.04.13.
//  Copyright (c) 2013 urbn. All rights reserved.
//

#import "BMFadeTransition.h"

@implementation BMFadeTransition

+(id<BMExtendablePageTransition>)transition{
    
    return [[BMFadeTransition alloc] init];
}

-(void)transitionFromIndex:(int)fromIdx toIndex:(int)toIdx withDuration:(float)duration andCurrenView:(VIEW *)currentView toNextView:(VIEW *)nextView onContainerView:(VIEW *)containerView withCompletion:(void (^)())completion{


    if (toIdx > fromIdx) {  // forward
        // insert new view controller behind and fade current out

        nextView.frame = containerView.bounds;
        
#if TARGET_OS_IPHONE
        [containerView insertSubview:nextView
                        belowSubview:nextView];
        
        [UIView animateWithDuration:duration animations:^{
            currentView.alpha = 0.;
        } completion:^(BOOL finished) {
            [currentView removeFromSuperview];
            completion();
        }];
#else
        [containerView addSubview:nextView
                       positioned:NSWindowBelow
                       relativeTo:currentView];
        
        [[NSAnimationContext currentContext] setDuration:duration];
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [[currentView animator] setAlphaValue:0.];
        } completionHandler:^{
            [currentView removeFromSuperview];
            completion();
        }];
        
#endif
        
    }else{
        // insert new view controller on top and fade in
        
        nextView.frame = containerView.bounds;

#if TARGET_OS_IPHONE
        nextView.alpha = 0.;
        
        [containerView insertSubview:nextView
                        aboveSubview:currentView];
        
        [UIView animateWithDuration:duration animations:^{
            nextView.alpha = 1.;
        } completion:^(BOOL finished) {
            [currentView removeFromSuperview];
            completion();
        }];
#else
        nextView.alphaValue = 0.;
                
        [containerView addSubview:nextView
                       positioned:NSWindowAbove
                       relativeTo:currentView];
        
        [[NSAnimationContext currentContext] setDuration:duration];
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [[nextView animator] setAlphaValue:1.];
        } completionHandler:^{
            [currentView removeFromSuperview];
            completion();
        }];
#endif
    }
    
}

@end
