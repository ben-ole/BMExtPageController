//
//  URBNHorizontalPageTransition.m
//  PINMAPP
//
//  Created by Benjamin Müller on 18.04.13.
//  Copyright (c) 2013 Benjamin Müller. All rights reserved.
//

#import "BMHorizontalCTransition.h"
#import <ObjectiveSugar/ObjectiveSugar.h>

@implementation BMHorizontalCTransition{
    UIView* _containerView;
    UIView* _currentView;
    UIView* _prevView;
    UIView* _nextView;
    CGRect  _currentViewStartFrame;
    CGRect  _nextViewStartFrame;
    CGRect  _prevViewStartFrame;
    void (^_completionBlock)(UIView* nowActiveView);
    float _currentValue;
}



+(id<URBNCustomContinuousePageTransition>)transition{
    return [[BMHorizontalCTransition alloc] init];
}

#pragma mark - Custom Page Transition
-(void)transitionFromIndex:(int)fromIdx toIndex:(int)toIdx
              withDuration:(float)duration
             andCurrenView:(UIView *)currentView toNextView:(UIView *)nextView
           onContainerView:(UIView *)containerView
            withCompletion:(void (^)())completion{
    
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
}

#pragma mark - Custom Continuouse Transition
-(void)beginTransitionWithCurrentView:(UIView *)currentView nextView:(UIView *)nextView prevView:(UIView *)previousView onContainerView:(UIView *)containerView withCompletion:(void (^)(UIView *nowActiveView))completion{
 
    _currentView = currentView;
    _nextView = nextView;
    _prevView = previousView;
    _containerView = containerView;
    _completionBlock = completion;
    _currentValue = 0.;
    
    _currentViewStartFrame = _currentView.frame;
    
    _nextView.frame = CGRectOffset(_currentView.frame, _currentView.frame.size.width, 0);
    _nextViewStartFrame = _nextView.frame;
    [_containerView addSubview:_nextView];
    
    _prevView.frame = CGRectOffset(_currentView.frame, - _currentView.frame.size.width, 0);
    _prevViewStartFrame = _prevView.frame;
    [_containerView addSubview:_prevView];
}

-(void)updateTransitionWithValue:(float)value{
    
    // ensure boundaries
    value = MAX(-1.0,MIN(1.0, value));
    
    float size = _containerView.frame.size.width;
    float newOffset = size * value;
    
    _currentView.frame = CGRectOffset(_currentViewStartFrame, newOffset, 0);
    _nextView.frame = CGRectOffset(_nextViewStartFrame, newOffset, 0);
    _prevView.frame = CGRectOffset(_prevViewStartFrame, newOffset, 0);
    
    _currentValue = value;
}

-(void)finishTransition{
    float size = _containerView.frame.size.width;
    float newOffset = size;
    NSArray* removeViews;
    UIView* finalView;
    
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

    [UIView animateWithDuration:duration
                          delay:0. options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                     
                         _currentView.frame = CGRectOffset(_currentViewStartFrame, newOffset, 0);
                         _nextView.frame = CGRectOffset(_nextViewStartFrame, newOffset, 0);
                         _prevView.frame = CGRectOffset(_prevViewStartFrame, newOffset, 0);
                 } completion:^(BOOL finished) {
                     
                     [removeViews each:^(id object) {
                         [object removeFromSuperview];
                     }];
                     
                     _completionBlock(finalView);
                 }];
}

-(void)cancelTransition{

    float duration = HORIZONTAL_TRANSITION_DURATION_DEFAULT * fabsf(_currentValue);
    
    [UIView animateWithDuration:duration
                          delay:0. options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         _currentView.frame = _currentViewStartFrame;
                         _nextView.frame = _nextViewStartFrame;
                         _prevView.frame = _prevViewStartFrame;
                     } completion:^(BOOL finished) {
                         
                     }];
}

@end
