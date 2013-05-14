//
//  BMVerticalCTransition.h
//  Anatomie
//
//  Created by mno on 13.05.13.
//  Copyright (c) 2013 urbn;. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMExtendablePageController/BMExtendablePageController.h>

#define HORIZONTAL_TRANSITION_DURATION_DEFAULT       0.5
#define HORIZONTAL_TRANSITION_LOWER_LIMIT_DEFAULT   -0.5
#define HORIZONTAL_TRANSITION_UPPER_LIMIT_DEFAULT   +0.5

@interface BMVerticalCTransition : NSObject <BMExtendableContinuousePageTransition>

@end
