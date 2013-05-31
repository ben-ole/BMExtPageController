//
//  BMQuartzComposerTransition.m
//  BMExtendablePageController
//
//  Created by Benjamin Müller on 28.05.13.
//  Copyright (c) 2013 Benjamin Müller. All rights reserved.
//

#import "BMCoreImageTransition.h"
#import "NSLayoutConstraint+PlacementHelper.h"
#import "CAAnimation+Blocks.h"

@implementation BMCoreImageTransition

+(id<BMExtendablePageTransition>)transition{
    return [[BMCoreImageTransition alloc] init];
}

+(id<BMExtendablePageTransition>)transitionWithCATransition:(CATransition *)coreImageTransition{
    
    BMCoreImageTransition* trans = [BMCoreImageTransition transition];
    
    trans.coreImageTransition = coreImageTransition;
    
    return trans;
}


-(void)transitionFromIndex:(int)fromIdx toIndex:(int)toIdx withDuration:(float)duration andCurrenView:(VIEW *)currentView toNextView:(VIEW *)nextView onContainerView:(VIEW *)containerView withCompletion:(void (^)())completion{
    
    // check if we have a transition
    if(!self.coreImageTransition) return;
    
    [NSLayoutConstraint fillSuperView:nextView];
    
    // remove next view, cuz it will be added later again
    [nextView removeFromSuperview];
    
    // Specify an explicit duration for the transition.
    [self.coreImageTransition setDuration:duration];
    
    [self.coreImageTransition setCompletion:^(BOOL finished) {
        completion();
        
        [NSLayoutConstraint fillSuperView:nextView];
        [NSLayoutConstraint removeConstraintsFromSuperView:currentView];
    }];
    
    [containerView setAnimations:[NSDictionary dictionaryWithObject:self.coreImageTransition forKey:@"subviews"]];

    // do actual scene change
    [[containerView animator] replaceSubview:currentView with:nextView];
}

+(CATransition *)ribbleTransitionWithRect:(RECT)rect{
    
    // Preload shading bitmap to use in transitions (borrowed from the "Fun House" Core Image example).
    NSData *shadingBitmapData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"restrictedshine" ofType:@"tiff"]];
    NSBitmapImageRep *shadingBitmap = [[NSBitmapImageRep alloc] initWithData:shadingBitmapData];
    CIImage* inputShadingImage = [[CIImage alloc] initWithBitmapImageRep:shadingBitmap];

    // this is a filter based transiton - so create filter
    CIFilter* transitionFilter = [CIFilter filterWithName:@"CIRippleTransition"];
    [transitionFilter setDefaults];
    [transitionFilter setValue:[CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height] forKey:@"inputExtent"];
    [transitionFilter setValue:[CIVector vectorWithX:NSMidX(rect) Y:NSMidY(rect)] forKey:@"inputCenter"];    
    [transitionFilter setValue:inputShadingImage forKey:@"inputShadingImage"];

    // create transition
    CATransition *transition = [[CATransition alloc] init];
    transition.repeatCount = 0;
    transition.removedOnCompletion = NO;
    transition.fillMode = kCAFillModeForwards;
    transition.filter = transitionFilter;
    
    return transition;
}
@end
