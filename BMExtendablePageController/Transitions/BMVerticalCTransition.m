//
//  BMVerticalCTransition.m
//  Anatomie
//
//  Created by mno on 13.05.13.
//  Copyright (c) 2013 urbn;. All rights reserved.
//

#import "BMVerticalCTransition.h"
#import "NSLayoutConstraint+PlacementHelper.h"

@implementation BMVerticalCTransition
{
    VIEW* _containerView;
    VIEW* _currentView;
    VIEW* _prevView;
    VIEW* _nextView;

    void (^_completionBlock)(VIEW* nowActiveView);
    float _currentValue;

    NSLayoutConstraint* _currentAlignmentConstraint;
}

+ (id<BMExtendableContinuousePageTransition>)transition
{
    return [[BMVerticalCTransition alloc] init];
}

#pragma mark - Custom Continuouse Transition
-(void)beginTransitionWithCurrentView:(VIEW *)currentView nextView:(VIEW *)nextView prevView:(VIEW *)previousView onContainerView:(VIEW *)containerView withCompletion:(void (^)(VIEW *nowActiveView))completion
{    
    _containerView = containerView;
    _currentView = currentView;
    _nextView = nextView;
    _prevView = previousView;
    
    // ensure currentView fills container
    _currentAlignmentConstraint = [NSLayoutConstraint fillSuperView:_currentView center:BM_LAYOUT_CENTER_Y];
    
    [NSLayoutConstraint stickView:_nextView nextToSibling:_currentView direction:BM_LAYOUT_DIRECTION_TOP];
    [NSLayoutConstraint stickView:_prevView nextToSibling:_currentView direction:BM_LAYOUT_DIRECTION_BOTTOM];
    
    _completionBlock = completion;
    _currentValue = 0.0;
    
}

-(void)updateTransitionWithValue:(float)value
{    
    float size = _containerView.bounds.size.height;
    float newOffset = size * value;
    
    [_currentAlignmentConstraint setConstant:newOffset];
    
    _currentValue = value;
}

-(void)finishTransitionWithRelativeIndex:(int)index
{
    float size = _containerView.bounds.size.height;
    float newOffset = size;
    VIEW* destinationView;
    
    if (index == -1)
    {
        // move to prev view
        newOffset *= -1.0;
        destinationView = _prevView;
    }
    else if(index == +1)
    {
        // move to next view
        newOffset *= +1.0;
        destinationView = _nextView;
    }
    else
    {
        // move back to current view
        newOffset = 0.;
        destinationView = _currentView;
    }
    
    float duration = HORIZONTAL_TRANSITION_DURATION_DEFAULT * fabsf(_currentValue - (float)index);
    
#if TARGET_OS_IPHONE
    
    [UIView animateWithDuration:duration
                          delay:0. options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [_currentAlignmentConstraint setConstant:newOffset];
                         [_containerView layoutIfNeeded];
                         
                     } completion:^(BOOL finished) {
                         
                         [NSLayoutConstraint removeConstraintsFromSuperView:_prevView];
                         [NSLayoutConstraint removeConstraintsFromSuperView:_nextView];
                         [NSLayoutConstraint removeConstraintsFromSuperView:_currentView];
                         [NSLayoutConstraint fillSuperView:destinationView];
                         [_containerView layoutIfNeeded];
                         _completionBlock(destinationView);
                     }];
#else
    
    [[NSAnimationContext currentContext] setDuration:duration];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        
        [[_currentAlignmentConstraint animator] setConstant:newOffset];
        
    } completionHandler:^{
        
        [NSLayoutConstraint fillSuperView:destinationView center:BM_LAYOUT_CENTER_Y];
        _completionBlock(destinationView);
        
    }];
#endif
}

-(void)cancelTransition
{    
    float duration = HORIZONTAL_TRANSITION_DURATION_DEFAULT * fabsf(_currentValue);
    
#if TARGET_OS_IPHONE
    
    [UIView animateWithDuration:duration
                          delay:0. options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         [_currentAlignmentConstraint setConstant:0.];
                         
                     } completion:^(BOOL finished) {
                         
                         [NSLayoutConstraint fillSuperView:_currentView];
                     }];
#else
    [[NSAnimationContext currentContext] setDuration:duration];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        
        [_currentAlignmentConstraint setConstant:0.0];
        
    } completionHandler:^{
        
        [NSLayoutConstraint fillSuperView:_currentView];
    }];
#endif
}

@end
