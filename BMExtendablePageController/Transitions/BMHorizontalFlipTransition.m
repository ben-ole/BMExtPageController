//
//  BMHorizontalFlipTransition.m
//  BMExtendablePageController
//
//  Created by Benjamin Müller on 23.04.13.
//  Copyright (c) 2013 Benjamin Müller. All rights reserved.
//

#import "BMHorizontalFlipTransition.h"
#import "NSLayoutConstraint+PlacementHelper.h"
#import <CAAnimationBlocks/CAAnimation+Blocks.h>
#import "NSView+BMImageRepresentation.h"

@implementation BMHorizontalFlipTransition

@synthesize duration=_duration;

+(id<BMExtendablePageTransition>)transitionWithDuration:(float)time{
    
    BMHorizontalFlipTransition* trans = [[BMHorizontalFlipTransition alloc] init];
    trans.duration = time;
    
    return trans;
}

-(void)transitionFromIndex:(int)fromIdx toIndex:(int)toIdx
             andCurrenView:(VIEW *)currentView
                toNextView:(VIEW *)nextView
           onContainerView:(VIEW *)containerView
            withCompletion:(void (^)())completion{
    
    float size = containerView.bounds.size.width;
    float newOffset = fromIdx < toIdx ? -size : size;
    
    // ensure currentView fills container
    NSLayoutConstraint* currentAlignmentConstraint = [NSLayoutConstraint fillSuperView:currentView];
    
    // bind next and prev view right and left to current view
    [NSLayoutConstraint stickView:nextView
                    nextToSibling:currentView
                        direction:(fromIdx < toIdx)? BM_LAYOUT_DIRECTION_RIGHT : BM_LAYOUT_DIRECTION_LEFT];

    
#if TARGET_OS_IPHONE
    [containerView layoutIfNeeded];
    
    [UIView animateWithDuration:_duration
                          delay:0. options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [currentAlignmentConstraint setConstant:newOffset];
                         [containerView layoutIfNeeded];
                         
                     } completion:^(BOOL finished) {
                         
                         [NSLayoutConstraint removeConstraintsFromSuperView:nextView];
                         [NSLayoutConstraint removeConstraintsFromSuperView:currentView];
                         [NSLayoutConstraint fillSuperView:nextView];
                         
                         [containerView layoutIfNeeded];
                         completion();
                     }];
#else
    
    [[NSAnimationContext currentContext] setDuration:duration];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        
        [[_currentAlignmentConstraint animator] setConstant:newOffset];
    } completionHandler:^{
        
        [NSLayoutConstraint fillSuperView:destinationView];
        _completionBlock(destinationView);
    }];
#endif
    
}

@end


