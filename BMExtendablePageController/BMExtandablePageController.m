//
//  URBNCustomPageController.m
//  PRSNTR
//
//  Created by Benjamin Müller on 11.04.13.
//  Copyright (c) 2013 urbn. All rights reserved.
//

#import "BMExtandablePageController.h"
#import <ObjectiveSugar/ObjectiveSugar.h>

@implementation BMExtandablePageController{
    NSMutableArray* _pages;
    NSMutableDictionary* _freeViewController;
}

#pragma mark - INIT
-(id)init{
    if ((self = [super init])) {
        [self setup];
    }

    return self;
}

-(id)initWithDelegate:(id<URBNCustomPageControllerDelegate>)aDelegate{
    if ((self = [self init])) {
        self.delegate = aDelegate;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setup];
    }
    return self;
}

-(void)setup{
    _selectedIndex = 0;
    _arrangedObjects = nil;
    _pages = [[NSMutableArray alloc] init];
    _freeViewController = [[NSMutableDictionary alloc] init];
}

#pragma mark - PUBLIC
-(void)setArrangedObjects:(NSArray *)arrangedObjects{
    _arrangedObjects = [arrangedObjects copy];
    
    [_pages removeAllObjects];

    for (int i=0; i<_arrangedObjects.count; i++) {
        [_pages addObject:[NSNull null]];
    }
    
    NSAssert(_delegate, @"Make sure to assign a delegate for the page controller");
    
    [self updatePageCache];
    
    assert(![[_pages objectAtIndex:_selectedIndex] isKindOfClass:[NSNull class]]);
    
    _selectedViewController = [_pages objectAtIndex:_selectedIndex];
    
    [self presentSelectedViewController];
}

-(void)setSelectedIndex:(NSInteger)selectedIndex withTransitionStyle:(Class<URBNCustomPageTransition>)transitionStyle{
    
    // check bounds
    NSAssert(selectedIndex < _pages.count, @"selected index beyond bounds (was %i but max is %i)",(int)selectedIndex,(int)_arrangedObjects.count-1);
    
    UIView* currentView = [(UIViewController*)[_pages objectAtIndex:_selectedIndex] view];
    UIView* nextView = [(UIViewController*)[_pages objectAtIndex:selectedIndex] view];
    
    
    [((id <URBNCustomPageTransition>) transitionStyle) transitionFromIndex:(int)_selectedIndex
                                                                   toIndex:(int)selectedIndex
                                                              withDuration:0.8
                                                             andCurrenView:currentView
                                                                toNextView:nextView
                                                           onContainerView:self.view
                                                            withCompletion:^(){
                                                                _selectedIndex = selectedIndex;
                                                                [self updatePageCache];
                                                            }];

}

-(void)nextPageWithTransitionStyle:(Class<URBNCustomPageTransition>)transitionStyle{
    
    if (_selectedIndex < _arrangedObjects.count - 1) {
        [self setSelectedIndex:_selectedIndex+1 withTransitionStyle:transitionStyle];
    }
}

-(void)prevPageWithTransitionStyle:(Class<URBNCustomPageTransition>)transitionStyle{
    
    if (_selectedIndex > 0) {
        [self setSelectedIndex:_selectedIndex-1 withTransitionStyle:transitionStyle];
    }
}

-(id<URBNCustomContinuousePageTransition>)attachContinuouseTransition:(id<URBNCustomContinuousePageTransition>)transition{
    
    UIView* currentView = [(UIViewController*)[_pages objectAtIndex:_selectedIndex] view];
    
    UIView* nextView = nil;
    if (_selectedIndex+1 < _arrangedObjects.count)
        nextView = [(UIViewController*)[_pages objectAtIndex:_selectedIndex+1] view];
    
    UIView* prevView = nil;
    if (_selectedIndex > 0)
        prevView = [(UIViewController*)[_pages objectAtIndex:_selectedIndex-1] view];
    
    [transition beginTransitionWithCurrentView:currentView
                                      nextView:nextView prevView:prevView
                               onContainerView:self.view
                                withCompletion:^(UIView *nowActiveView) {
        
                                    if (nowActiveView == nextView) {
                                        _selectedIndex++;
                                    }else if(nowActiveView == prevView){
                                        _selectedIndex--;
                                    }
                                    
                                    [self updatePageCache];
    }];
    
    return transition;
}

#pragma mark - VIEW STUFF
-(void)presentSelectedViewController{
    [self.view addSubview:_selectedViewController.view];
    _selectedViewController.view.frame = self.view.bounds;
}


#pragma mark - HELPER
-(void)updatePageCache{
    // first unload exisiting page to possibly free recyclable controllers
    // second load newly required pages
    
    // try beein fast :)
    [_pages enumerateObjectsWithOptions:NSEnumerationConcurrent
                                       usingBlock:^(id obj, NSUInteger i, BOOL *stop) {
       
        // don't delete pages in active range
        if (i >= MAX(0,_selectedIndex - PAGE_CONTROLLER_PRELOAD_RANGE) &&
            i <= MIN(_arrangedObjects.count - 1,
                     _selectedIndex + PAGE_CONTROLLER_PRELOAD_RANGE) )
            return;
        
        // don't care about empty pages
        if ([obj isKindOfClass:[NSNull class]])
            return;
        
        // recycle objects
        [self depositViewControllerWithIndex:(int)i];
        [_pages replaceObjectAtIndex:i withObject:[NSNull null]];
    }];
    
    // now process the currently active indices

    int startIndx = (int) MAX(0, _selectedIndex-PAGE_CONTROLLER_PRELOAD_RANGE);
    int l = (int) MIN(_arrangedObjects.count - startIndx, _selectedIndex + PAGE_CONTROLLER_PRELOAD_RANGE +1 - startIndx);
    NSLog(@"loading active indices at %i with length %i",startIndx,l);
    NSIndexSet *activeIndices = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndx,l)];
    
    [_pages enumerateObjectsAtIndexes:activeIndices
                              options:NSEnumerationConcurrent
                           usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                               
        if ([obj isKindOfClass:[NSNull class]]) {
            [self loadPageWithIndex:(int)idx];
        }
    }];
}

-(void)loadPageWithIndex:(int)index{
    // check if already created
    if (![[_pages objectAtIndex:index] isKindOfClass:[NSNull class]])
        return;
    
    NSLog(@"load page with idx: %i",index);

    // get a viewcontroller for index
    UIViewController* pageCtrl = [self requireViewControllerForIndex:index];
    [_delegate pageController:self prepareViewController:pageCtrl withObject:[_arrangedObjects objectAtIndex:index]];

    // store viewcontroller
    [_pages replaceObjectAtIndex:index withObject:pageCtrl];
}


-(UIViewController*)requireViewControllerForIndex:(int)index{
    // ask delegate for viewcontroller
    NSString* pageId = [_delegate pageController:self identifierForIndex:index];
    
    NSMutableArray* freeViewCtrlForPageId = [_freeViewController valueForKey:pageId];
    
    if (freeViewCtrlForPageId && freeViewCtrlForPageId.count > 0) {
        // if there is one - recycle
        return [freeViewCtrlForPageId pop];
    }else{
        // or recreate a new
        return [_delegate pageController:self
             viewControllerForIdentifier:pageId];
    }
}

-(void)depositViewControllerWithIndex:(int)index{
    NSLog(@"deposit page with idx: %i",index);
    
    NSString* pageId = [_delegate pageController:self identifierForIndex:index];
    
    NSMutableArray* freeViewCtrlForPageId = [_freeViewController valueForKey:pageId];
    
    // if there is not an array already - create one
    unless (freeViewCtrlForPageId){
        freeViewCtrlForPageId = [NSMutableArray array];
        [_freeViewController setObject:freeViewCtrlForPageId
                                forKey:_freeViewController];
    }
    
    [freeViewCtrlForPageId push:[_pages objectAtIndex:index]];    
}

@end
