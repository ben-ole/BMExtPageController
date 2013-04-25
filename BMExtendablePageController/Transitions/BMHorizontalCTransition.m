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

#if TARGET_OS_IPHONE
    _currentViewStartFrame = _currentView.frame;
    
    _nextView.frame = CGRectOffset(_currentView.frame, _currentView.frame.size.width, 0);
    _nextViewStartFrame = _nextView.frame;
    [_containerView addSubview:_nextView];
    
    _prevView.frame = CGRectOffset(_currentView.frame, - _currentView.frame.size.width, 0);
    _prevViewStartFrame = _prevView.frame;
    [_containerView addSubview:_prevView];
#endif
    
}

-(void)updateTransitionWithValue:(float)value{
    
    // ensure boundaries
    value = MAX(-1.0,MIN(1.0, value));
    
    NSLog(@"value: %f",value);
    
    float size = _containerView.frame.size.width;
    float newOffset = size * value;
    
#if TARGET_OS_IPHONE
    _currentView.frame = CGRectOffset(_currentViewStartFrame, newOffset, 0);
    _nextView.frame = CGRectOffset(_nextViewStartFrame, newOffset, 0);
    _prevView.frame = CGRectOffset(_prevViewStartFrame, newOffset, 0);
#endif
    
    _currentValue = value;
}

-(void)finishTransitionWithRelativeIndex:(int)index{
    
    NSLog(@"move: %i",index);
    
    float size = _containerView.frame.size.width;
    float newOffset = size;
    VIEW* destinationView;
    
    if (index == -1) {
        // move to prev view
        newOffset *= -1.0;
        destinationView = _prevView;
    }else if(index == +1){
        // move to next view
        newOffset *= +1.0;
        destinationView = _nextView;
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
                     
                     if (destinationView == _nextView) {

                         [_currentView removeFromSuperview];
                         [_prevView removeFromSuperview];
                         
                     }else if(destinationView == _prevView){
                         
                         [_currentView removeFromSuperview];
                         [_nextView removeFromSuperview];
                     }else{
                         
                         [_nextView removeFromSuperview];
                         [_prevView removeFromSuperview];
                     }
                     
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
#endif
}

@end
