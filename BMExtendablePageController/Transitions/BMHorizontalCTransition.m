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
    
    void (^_completionBlock)(VIEW* nowActiveView);
    float _currentValue;
    
    NSLayoutConstraint* _currentAlignmentConstraint;
}



+(id<BMExtendableContinuousePageTransition>)transition{
    return [[BMHorizontalCTransition alloc] init];
}

#pragma mark - Custom Continuouse Transition
-(void)beginTransitionWithCurrentView:(VIEW *)currentView nextView:(VIEW *)nextView prevView:(VIEW *)previousView onContainerView:(VIEW *)containerView withCompletion:(void (^)(VIEW *nowActiveView))completion{
 
    _containerView = containerView;
    _currentView = currentView;
    _nextView = nextView;
    _prevView = previousView;
    
    _containerView.translatesAutoresizingMaskIntoConstraints = FALSE;
    _currentView.translatesAutoresizingMaskIntoConstraints = FALSE;
    _nextView.translatesAutoresizingMaskIntoConstraints = FALSE;
    _prevView.translatesAutoresizingMaskIntoConstraints = FALSE;
    
    [self removeConstraintsFromSuperView:_currentView];
    _currentAlignmentConstraint = [NSLayoutConstraint constraintWithItem:_currentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.];
    [_containerView addConstraint:_currentAlignmentConstraint];
    
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_currentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.]];
    
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_currentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.]];
    
    // remove any existing constraints for prev and following views
    if (_nextView)
        [self stickView:_nextView nextToSibling:_currentView isNext:YES];

    if (_prevView)
        [self stickView:_prevView nextToSibling:_currentView isNext:NO];
    
    _completionBlock = completion;
    _currentValue = 0.;
    
}

-(void)updateTransitionWithValue:(float)value{
        
    float size = _containerView.bounds.size.width;
    float newOffset = size * value;

    [_currentAlignmentConstraint setConstant:newOffset];
    
    _currentValue = value;
}

-(void)finishTransitionWithRelativeIndex:(int)index{
        
    float size = _containerView.bounds.size.width;
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
                     
                         [_currentAlignmentConstraint setConstant:newOffset];
                         
                 } completion:^(BOOL finished) {
                     
                     [self bindViewToContainerLayout:destinationView];
                    _completionBlock(destinationView);                     
                 }];
#else
    
    [[NSAnimationContext currentContext] setDuration:duration];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        
        [_currentAlignmentConstraint setConstant:newOffset];
    } completionHandler:^{
        
        [self bindViewToContainerLayout:destinationView];
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
                         
                         [_currentAlignmentConstraint setConstant:0.];

                     } completion:^(BOOL finished) {

                         [self bindViewToContainerLayout:_currentView];
                     }];
#else
    [[NSAnimationContext currentContext] setDuration:duration];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        
        [_currentAlignmentConstraint setConstant:0.];
    } completionHandler:^{
        
         [self bindViewToContainerLayout:_currentView];
    }];
#endif
}

#pragma mark - HELPER
-(void)bindViewToContainerLayout:(VIEW*)aView{
    [self removeConstraintsFromSuperView:aView];
    
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.]];
}

-(void)removeConstraintsFromSuperView:(VIEW*)aView{
    
    CGRect currentFrame = aView.frame;
    
    NSMutableArray* relatedConstraints = [[NSMutableArray alloc] init];
    for (NSLayoutConstraint* constr in aView.superview.constraints) {
        
        if (constr.firstItem == aView || constr.secondItem == aView) {
            [relatedConstraints addObject:constr];
        }
    }
    
    [aView.superview removeConstraints:relatedConstraints];
    
    aView.frame = currentFrame;
}

-(void)stickView:(VIEW*)aView nextToSibling:(VIEW*)sibling isNext:(Boolean)isNext{
    [self removeConstraintsFromSuperView:aView];
    
    if(isNext){
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:sibling attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.]];
    }else{
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:sibling attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.]];
    }
    
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:sibling attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:sibling attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:sibling attribute:NSLayoutAttributeWidth multiplier:1 constant:0.]];

}

@end
