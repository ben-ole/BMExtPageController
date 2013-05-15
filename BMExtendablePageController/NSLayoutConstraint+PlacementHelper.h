//
//  NSLayoutConstraint+PlacementHelper.h
//  Pods
//
//  Created by Benjamin Müller on 29.04.13.
//
//

#import "BMExtendablePageController.h"

typedef enum {
    BM_LAYOUT_DIRECTION_RIGHT = 0,
    BM_LAYOUT_DIRECTION_LEFT,
    BM_LAYOUT_DIRECTION_TOP,
    BM_LAYOUT_DIRECTION_BOTTOM
}BM_LAYOUT_DIRECTION;

typedef enum {
    BM_LAYOUT_CENTER_X = 0,
    BM_LAYOUT_CENTER_Y
}BM_LAYOUT_CENTER;

@interface NSLayoutConstraint (PlacementHelper)

+(void)removeConstraintsFromSuperView:(VIEW*)aView;

+(void)stickView:(VIEW*)aView nextToSibling:(VIEW*)sibling direction:(BM_LAYOUT_DIRECTION)direction;

+(NSLayoutConstraint*)fillSuperView:(VIEW*)aView;
+(NSLayoutConstraint*)fillSuperView:(VIEW*)aView center:(BM_LAYOUT_CENTER)center;

@end
