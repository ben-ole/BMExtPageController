//
//  URBNCustomPageController.h
//  PRSNTR
//
//  Created by Benjamin Müller on 11.04.13.
//  Copyright (c) 2013 urbn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define PAGE_CONTROLLER_PRELOAD_RANGE 1

@protocol URBNCustomPageControllerDelegate;
@protocol URBNCustomPageTransition;
@protocol URBNCustomContinuousePageTransition;


@interface BMExtandablePageController : UIViewController

@property(weak) IBOutlet id<URBNCustomPageControllerDelegate> delegate;

/* Array of all displayed objects (after sorting and potentially filtering by you). The delegate will be asked for snapshots as they are needed.
 */
@property(copy,nonatomic) NSArray *arrangedObjects;

/* The index into the arrangedObjects that is being displayed. */
@property (readonly) NSInteger selectedIndex;

/* The viewController associated with the selected arrangedObject. May be nil if delegate is not supplying viewControllers.
 */
@property(retain, readonly) UIViewController *selectedViewController;

/* Convenience init method as a delegate is required for any use of the page controller.
 */
-(id)initWithDelegate:(id<URBNCustomPageControllerDelegate>)aDelegate;

/*
 jump to any index within the bounds of provided pages using a transition class.
 */
-(void)setSelectedIndex:(NSInteger)selectedIndex withTransition:(id<URBNCustomPageTransition>)transition;

/*
 This is a short hand for setSelectedIndex with an incremented value.
 */
-(void)nextPageWithTransitionStyle:(id<URBNCustomPageTransition>)transition;

/*
 This is a short hand for setSelectedIndex with a decremented value.
 */
-(void)prevPageWithTransitionStyle:(id<URBNCustomPageTransition>)transition;


/* Use this method to attach a continuouse transition to the page controller. Use the returning reference to push subsequent updates to this transition and call finishTransition: or cancelTransition: to complete the processs.*/
-(id<URBNCustomContinuousePageTransition>)attachContinuouseTransition:(id<URBNCustomContinuousePageTransition>)transition;

@end



@protocol URBNCustomPageControllerDelegate <NSObject>
@required

/* Return the identifier of the view controller that owns a view to display the object. If NSPageController does not have an unused viewController for this identifier, the you will be asked to create one via pageController:viewControllerForIdentifier.
 */
- (NSString *)pageController:(BMExtandablePageController *)pageController identifierForIndex:(int)index;

/* NSPageController will cache as many viewControllers and views as necessary to maintain performance. This method is called whenever another instance is required. Note: The viewController may become the selectedViewController after a transition if necessary.
 */
- (UIViewController *)pageController:(BMExtandablePageController *)pageController viewControllerForIdentifier:(NSString *)identifier;

/* NOTE: The following 2 methods are only useful if you also implement the above two methods.
 */

@optional

/* You only need to implement this if the view frame can differ between arrangedObjects. This method must return immediately. Avoid file, network or any potentially blocking or lengthy work to provide an answer. If this method is not implemented, all arrangedObjects are assumed to have the same frame as the current selectedViewController.view or the bounds of view when selectedViewController is nil.
 */
- (CGRect)pageController:(BMExtandablePageController *)pageController frameForObject:(id)object;

/* Prepare the viewController and view for drawing. Setup data sources and perform layout. Note: this method is called on the main thread and should return immediately. The view will be asked to draw on a background thread and must support background drawing. If this method is not implemented, then viewController's representedObject is set to the representedObject.
 */
- (void)pageController:(BMExtandablePageController *)pageController prepareViewController:(UIViewController *)viewController withObject:(id)object;

/* Note: You may find these useful regardless of which way you use NSPageController (History vs Custom).
 */

/* This message is sent when any page transition is completed. */
- (void)pageController:(BMExtandablePageController *)pageController didTransitionToObject:(id)object;

/* This message is sent when the user begins a transition wither via swipe gesture of one of the navigation IBAction methods. */
- (void)pageControllerWillStartLiveTransition:(BMExtandablePageController *)pageController;

/* This message is sent when a transition animation completes either via swipe gesture or one of the navigation IBAction methods. Your content view is still hidden and you must call -completeTransition; on pageController when your content is ready to show. If completed successfully, a pageController:didTransitionToRepresentedObject: will already have been sent.
 */
- (void)pageControllerDidEndLiveTransition:(BMExtandablePageController *)pageController;


@end

@protocol URBNCustomPageTransition <NSObject>
@required

-(void)transitionFromIndex:(int)fromIdx toIndex:(int)toIdx withDuration:(float)duration andCurrenView:(UIView*)currentView toNextView:(UIView*)nextView onContainerView:(UIView*)containerView withCompletion:(void (^)())completion;

@optional

/* Implement this method for easy access to a default version of the transition.*/
+(id<URBNCustomPageTransition>)transition;

@end

@protocol URBNCustomContinuousePageTransition <NSObject>
@required

/* setup a transition. The completion block expects an argument to be filled with the proper prevView/nextView/currentView depending on the movement direction */
-(void)beginTransitionWithCurrentView:(UIView*)currentView nextView:(UIView*)nextView prevView:(UIView*)previousView onContainerView:(UIView*)containerView withCompletion:(void (^)(UIView* nowActiveView))completion;

/* Update the transition to reflect user interaction.
 @param value should be in a range of -1.0 to 1.0
 */
-(void)updateTransitionWithValue:(float)value;

/*
 Cancel the transition and move back to current page. This method does not call the completion block set in beginTransition:
 */
-(void)cancelTransition;

/* Finish the transition without further user interaction. This animate to the previous/next page or back to current page in case a given limit was not reached yet. This methold will call the completion block set in beginTransition: .*/
-(void)finishTransition;

@optional
/* Implement this method for easy access to a default version of the transition.*/

+(id<URBNCustomContinuousePageTransition>)transition;

@end
