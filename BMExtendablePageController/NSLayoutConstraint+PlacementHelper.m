//
//  NSLayoutConstraint+PlacementHelper.m
//  Pods
//
//  Created by Benjamin Müller on 29.04.13.
//
//

#import "NSLayoutConstraint+PlacementHelper.h"

@implementation NSLayoutConstraint (PlacementHelper)

+(void)removeConstraintsFromSuperView:(VIEW *)aView{
    
    if(!aView || !aView.superview) return;
    
    aView.translatesAutoresizingMaskIntoConstraints = FALSE;
    
    NSMutableArray* relatedConstraints = [[NSMutableArray alloc] init];
    for (NSLayoutConstraint* constr in aView.superview.constraints) {
        
        if (constr.firstItem == aView || constr.secondItem == aView) {
            [relatedConstraints addObject:constr];
        }
    }
    
    [aView.superview removeConstraints:relatedConstraints];
    
}

+(void)stickView:(VIEW *)aView nextToSibling:(VIEW *)sibling direction:(BM_LAYOUT_DIRECTION)direction{
    
    if(!aView || !aView.superview || !sibling) return;
    
    aView.translatesAutoresizingMaskIntoConstraints = FALSE;
    sibling.translatesAutoresizingMaskIntoConstraints = FALSE;
    
    [NSLayoutConstraint removeConstraintsFromSuperView:aView];
    
    if(direction == BM_LAYOUT_DIRECTION_RIGHT){
        [aView.superview addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:sibling attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.]];
        
    }else if(direction  == BM_LAYOUT_DIRECTION_LEFT){
        [aView.superview addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:sibling attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.]];
    }
    
    [aView.superview addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:sibling attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.]];

    [aView.superview addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:sibling attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.]];

    [aView.superview addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:sibling attribute:NSLayoutAttributeWidth multiplier:1 constant:0.]];

    [aView.superview addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:sibling attribute:NSLayoutAttributeHeight multiplier:1 constant:0.]];
    
}

+(NSLayoutConstraint*)fillSuperView:(VIEW *)aView{
    
    if(!aView || !aView.superview) return nil;
    
    aView.translatesAutoresizingMaskIntoConstraints = FALSE;
    [NSLayoutConstraint removeConstraintsFromSuperView:aView];
    
    NSLayoutConstraint* centerLayout = [NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:aView.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.];
    
    [aView.superview addConstraint:centerLayout];
    
    [aView.superview addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:aView.superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.]];
    
    [aView.superview addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:aView.superview attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.]];
    
    [aView.superview addConstraint:[NSLayoutConstraint constraintWithItem:aView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:aView.superview attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.]];

    return centerLayout;
}

@end
