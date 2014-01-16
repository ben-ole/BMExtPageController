//
//  BMQuartzComposerTransition.m
//  BMExtendablePageController
//
//  Created by Benjamin Müller on 28.05.13.
//  Copyright (c) 2013 Benjamin Müller. All rights reserved.
//

#import "BMCoreImageTransition.h"
#import "NSLayoutConstraint+PlacementHelper.h"
#import <CAAnimationBlocks/CAAnimation+Blocks.h>


@implementation BMCoreImageTransition

@synthesize duration=_duration;

+(id<BMExtendablePageTransition>)transitionWithDuration:(float)time{
    BMCoreImageTransition* trans = [[BMCoreImageTransition alloc] init];
    trans.duration = time;
    return trans;
}

+(id<BMExtendablePageTransition>)transitionWithCATransition:(CATransition *)coreImageTransition inDuration:(float)time{
    
    BMCoreImageTransition* trans = [BMCoreImageTransition transitionWithDuration:time];
    
    trans.coreImageTransition = coreImageTransition;
    
    return trans;
}


-(void)transitionFromIndex:(int)fromIdx toIndex:(int)toIdx andCurrenView:(VIEW *)currentView toNextView:(VIEW *)nextView onContainerView:(VIEW *)containerView withCompletion:(void (^)())completion{
    
    // check if we have a transition
    if(!self.coreImageTransition) return;
        
    // remove next view, cuz it will be added later again
    [nextView removeFromSuperview];
    
    // Specify an explicit duration for the transition.
    [self.coreImageTransition setDuration:self.duration];
    
    [self.coreImageTransition setCompletion:^(BOOL finished) {
        [NSLayoutConstraint fillSuperView:nextView];
        
        completion();
    }];
    
#if ! TARGET_OS_IPHONE
    containerView.layerUsesCoreImageFilters = YES;
    
    [containerView setAnimations:[NSDictionary dictionaryWithObject:self.coreImageTransition forKey:@"subviews"]];

    // do actual scene change
    [[containerView animator] addSubview:nextView];
#else
    containerView.layer.masksToBounds = YES;
    [containerView.layer addAnimation:self.coreImageTransition forKey:kCATransition];
    [containerView addSubview:nextView];
    [NSLayoutConstraint fillSuperView:nextView];    
#endif
}

+(CATransition *)ribbleTransitionWithRect:(RECT)rect{
    
    // Preload shading bitmap to use in transitions (borrowed from the "Fun House" Core Image example).
#if ! TARGET_OS_IPHONE
    NSData *shadingBitmapData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"restrictedshine" ofType:@"tiff"]];
    
    NSBitmapImageRep *shadingBitmap = [[NSBitmapImageRep alloc] initWithData:shadingBitmapData];
    CIImage* inputShadingImage = [[CIImage alloc] initWithBitmapImageRep:shadingBitmap];
    
    // this is a filter based transiton - so create filter
    CIFilter* transitionFilter = [CIFilter filterWithName:@"CIRippleTransition"];
    [transitionFilter setDefaults];
    [transitionFilter setValue:[CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height] forKey:@"inputExtent"];
    [transitionFilter setValue:[CIVector vectorWithX:CGRectGetMidX(rect) Y:CGRectGetMidY(rect)] forKey:@"inputCenter"];
    [transitionFilter setValue:inputShadingImage forKey:@"inputShadingImage"];
    
    // create transition
    CATransition *transition = [[CATransition alloc] init];
    transition.repeatCount = 0;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.removedOnCompletion = YES;
    transition.fillMode = kCAFillModeForwards;
    transition.filter = transitionFilter;
    
    return transition;
#else
    CATransition *animation = [CATransition animation];
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    [animation setType:@"rippleEffect" ];
    
    return animation;
#endif

   }
@end
