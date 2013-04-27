//
//  BMHorizontalFlipTransition.m
//  BMExtendablePageController
//
//  Created by Benjamin Müller on 23.04.13.
//  Copyright (c) 2013 Benjamin Müller. All rights reserved.
//

#import "BMHorizontalFlipTransition.h"

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

    float destOffset = containerView.bounds.size.width * ((toIdx > fromIdx) ? 1. : -1.);
    
    nextView.frame = CGRectOffset(containerView.bounds, destOffset, 0);

        
#if TARGET_OS_IPHONE

    [UIView animateWithDuration:duration delay:0. options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         currentView.frame = CGRectOffset(currentView.frame, -destOffset, 0);
                         nextView.frame = containerView.bounds;
                         
                     } completion:^(BOOL finished) {
                         
                         completion();
                     }];
#else
    [[NSAnimationContext currentContext] setDuration:duration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [[currentView animator] setFrame:CGRectOffset(currentView.frame, -destOffset, 0)];
        [[nextView animator] setFrame:containerView.bounds];
    } completionHandler:^{
        completion();
    }];
#endif
}

@end
