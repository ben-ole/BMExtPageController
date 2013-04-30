//
//  NSLayoutConstraint+PlacementHelper.h
//  Pods
//
//  Created by Benjamin Müller on 29.04.13.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    BM_LAYOUT_DIRECTION_RIGHT = 0,
    BM_LAYOUT_DIRECTION_LEFT,
    BM_LAYOUT_DIRECTION_TOP,
    BM_LAYOUT_DIRECTION_BOTTOM
}BM_LAYOUT_DIRECTION;

@interface NSLayoutConstraint (PlacementHelper)

+(void)removeConstraintsFromSuperView:(VIEW*)aView;

+(void)stickView:(VIEW*)aView nextToSibling:(VIEW*)sibling direction:(BM_LAYOUT_DIRECTION)direction;

+(NSLayoutConstraint*)fillSuperView:(VIEW*)aView;

@end
