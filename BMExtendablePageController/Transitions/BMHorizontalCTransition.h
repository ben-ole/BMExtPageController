//
//  URBNHorizontalPageTransition.h
//  PINMAPP
//
//  Created by Benjamin Müller on 18.04.13.
//  Copyright (c) 2013 Benjamin Müller. All rights reserved.
//

#import "BMExtendablePageController.h"

#define HORIZONTAL_TRANSITION_DURATION_DEFAULT       1.5
#define HORIZONTAL_TRANSITION_LOWER_LIMIT_DEFAULT   -0.5
#define HORIZONTAL_TRANSITION_UPPER_LIMIT_DEFAULT   +0.5

@interface BMHorizontalCTransition : NSObject <BMExtendableContinuousPageTransition>

@end
