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

#pragma mark - Custom Page Transition
-(void)transitionFromIndex:(int)fromIdx toIndex:(int)toIdx
              withDuration:(float)duration
             andCurrenView:(VIEW *)currentView toNextView:(VIEW *)nextView
           onContainerView:(VIEW *)containerView
            withCompletion:(void (^)())completion{
    
#if TARGET_OS_IPHONE

    nextView.frame = CGRectOffset(currentView.frame, currentView.frame.size.width * (toIdx > fromIdx ? +1 : -1), 0);
    [containerView addSubview:nextView];
    
    [UIView animateWithDuration:duration delay:0. options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         currentView.frame = CGRectOffset(currentView.frame, currentView.frame.size.width * (toIdx > fromIdx ? -1 : +1), 0);
                         nextView.frame = containerView.bounds;
                         
                     } completion:^(BOOL finished) {
                        
                         [currentView removeFromSuperview];
                         completion();
                     }];
#endif
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
    
    float size = _containerView.frame.size.width;
    float newOffset = size * value;
    
#if TARGET_OS_IPHONE
    _currentView.frame = CGRectOffset(_currentViewStartFrame, newOffset, 0);
    _nextView.frame = CGRectOffset(_nextViewStartFrame, newOffset, 0);
    _prevView.frame = CGRectOffset(_prevViewStartFrame, newOffset, 0);
#endif
    
    _currentValue = value;
}

-(void)finishTransition{
    float size = _containerView.frame.size.width;
    float newOffset = size;
    NSArray* removeViews;
    VIEW* finalView;
    
    if (_currentValue < HORIZONTAL_TRANSITION_LOWER_LIMIT_DEFAULT) {
        // move to prev view
        newOffset *= -1.0;
        finalView = _prevView;
        removeViews = @[_currentView,_nextView];
    }else if(_currentValue > HORIZONTAL_TRANSITION_UPPER_LIMIT_DEFAULT){
        // move to next view
        newOffset *= +1.0;
        finalView = _nextView;
        removeViews = @[_currentView,_prevView];
    }else{
        // move back to current view
        newOffset = 0.;
        finalView = _currentView;
        removeViews = @[_prevView,_nextView];
    }

    float duration = HORIZONTAL_TRANSITION_DURATION_DEFAULT * fabsf(_currentValue - newOffset);

#if TARGET_OS_IPHONE
    [UIView animateWithDuration:duration
                          delay:0. options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                     
                         _currentView.frame = CGRectOffset(_currentViewStartFrame, newOffset, 0);
                         _nextView.frame = CGRectOffset(_nextViewStartFrame, newOffset, 0);
                         _prevView.frame = CGRectOffset(_prevViewStartFrame, newOffset, 0);
                 } completion:^(BOOL finished) {
                     
                     [removeViews enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                         
                         [obj removeFromSuperview];
                     }];
                     
                     _completionBlock(finalView);
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
