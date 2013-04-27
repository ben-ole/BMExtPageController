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
        [containerView sendSubviewToBack:nextView];
        
#if TARGET_OS_IPHONE
        
        [UIView animateWithDuration:duration animations:^{
            currentView.alpha = 0.;
        } completion:^(BOOL finished) {
            
            completion();
            currentView.alpha = 1.;
        }];
#else
        
        [[NSAnimationContext currentContext] setDuration:duration];
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [[currentView animator] setAlphaValue:0.];
        } completionHandler:^{
            completion();
            currentView.alphaValue = 1.;
        }];
        
#endif
        
    }else{
        // insert new view controller on top and fade in
        
        nextView.frame = containerView.bounds;
        [containerView bringSubviewToFront:nextView];

#if TARGET_OS_IPHONE
        nextView.alpha = 0.;
        
        [UIView animateWithDuration:duration animations:^{
            nextView.alpha = 1.;
        } completion:^(BOOL finished) {
            completion();
        }];
#else
        nextView.alphaValue = 0.;
        
        [[NSAnimationContext currentContext] setDuration:duration];
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [[nextView animator] setAlphaValue:1.];
        } completionHandler:^{
            completion();
        }];
#endif
    }
    
}

@end
