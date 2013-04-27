//
//  URBNHorizontalPageTransition.m
//  PINMAPP
//
//  Created by Benjamin Müller on 18.04.13.
//  Copyright (c) 2013 Benjamin Müller. All rights reserved.
//

#import "BMHorizontalCTransition.h"

@implementation BMHorizontalCTransition{
    
    VIEW* _containerView;
    VIEW* _currentView;
    VIEW* _prevView;
    VIEW* _nextView;
    
#if TARGET_OS_IPHONE
    CGRect  _currentViewStartFrame;
    CGRect  _nextViewStartFrame;
    CGRect  _prevViewStartFrame;
#endif
    
    void (^_completionBlock)(VIEW* nowActiveView);
    float _currentValue;
}



+(id<BMExtendableContinuousePageTransition>)transition{
    return [[BMHorizontalCTransition alloc] init];
}

#pragma mark - Custom Continuouse Transition
-(void)beginTransitionWithCurrentView:(VIEW *)currentView nextView:(VIEW *)nextView prevView:(VIEW *)previousView onContainerView:(VIEW *)containerView withCompletion:(void (^)(VIEW *nowActiveView))completion{
 
    _currentView = currentView;
    _nextView = nextView;
    _prevView = previousView;
    _containerView = containerView;
    _completionBlock = completion;
    _currentValue = 0.;

    _currentViewStartFrame = _containerView.bounds;
    
    _nextView.frame = CGRectOffset(_containerView.bounds, _containerView.bounds.size.width, 0);
    _nextViewStartFrame = _nextView.frame;
    
    _prevView.frame = CGRectOffset(_containerView.bounds, - _containerView.bounds.size.width, 0);
    _prevViewStartFrame = _prevView.frame;
    
}

-(void)updateTransitionWithValue:(float)value{
        
    float size = _containerView.bounds.size.width;
    float newOffset = size * value;
    
    _currentView.frame = CGRectOffset(_currentViewStartFrame, newOffset, 0);
    _nextView.frame = CGRectOffset(_nextViewStartFrame, newOffset, 0);
    _prevView.frame = CGRectOffset(_prevViewStartFrame, newOffset, 0);
    
    _currentValue = value;
}

-(void)finishTransitionWithRelativeIndex:(int)index{
        
    float size = _containerView.frame.size.width;
    float newOffset = size;
    VIEW* destinationView;
    
    if (index == -1) {
        // move to prev view
        newOffset *= -1.0;
        destinationView = _nextView;
    }else if(index == +1){
        // move to next view
        newOffset *= +1.0;
        destinationView = _prevView;
    }else{
        // move back to current view
        newOffset = 0.;
        destinationView = _currentView;
    }

    float duration = HORIZONTAL_TRANSITION_DURATION_DEFAULT * fabsf(_currentValue - (float)index);

#if TARGET_OS_IPHONE
    [UIView animateWithDuration:duration
                          delay:0. options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                     
                         _currentView.frame = CGRectOffset(_currentViewStartFrame, newOffset, 0);
                         _nextView.frame = CGRectOffset(_nextViewStartFrame, newOffset, 0);
                         _prevView.frame = CGRectOffset(_prevViewStartFrame, newOffset, 0);
                 } completion:^(BOOL finished) {
                     
                     _completionBlock(destinationView);
                 }];
#else
    
    [[NSAnimationContext currentContext] setDuration:duration];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [[_currentView animator] setFrame:CGRectOffset(_currentViewStartFrame, newOffset, 0)];
        [[_nextView animator] setFrame:CGRectOffset(_nextViewStartFrame, newOffset, 0)];
        [[_prevView animator] setFrame:CGRectOffset(_prevViewStartFrame, newOffset, 0)];
    } completionHandler:^{
        
        _completionBlock(destinationView);
    }];
#endif
}

-(void)cancelTransition{

    float duration = HORIZONTAL_TRANSITION_DURATION_DEFAULT * fabsf(_currentValue);
    
#if TARGET_OS_IPHONE

    [UIView animateWithDuration:duration
                          delay:0. options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         _currentView.frame = _currentViewStartFrame;
                         _nextView.frame = _nextViewStartFrame;
                         _prevView.frame = _prevViewStartFrame;
                     } completion:^(BOOL finished) {
                         
                     }];
#else
    [[NSAnimationContext currentContext] setDuration:duration];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [[_currentView animator] setFrame:_currentViewStartFrame];
        [[_nextView animator] setFrame:_nextViewStartFrame];
        [[_prevView animator] setFrame:_prevViewStartFrame];        
    } completionHandler:^{

    }];
#endif
}

@end
