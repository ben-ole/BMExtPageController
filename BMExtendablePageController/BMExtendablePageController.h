//
//  URBNCustomPageController.h
//  PRSNTR
//
//  Created by Benjamin Müller on 11.04.13.
//  Copyright (c) 2013 urbn. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#define PAGE_CONTROLLER_PRELOAD_RANGE 1

@protocol BMExtendablePageControllerDelegate;
@protocol BMExtendablePageTransition;
@protocol BMExtendableContinuousePageTransition;


@interface BMExtendablePageController : VIEW_CONTROLLER

@property(weak) IBOutlet id<BMExtendablePageControllerDelegate> delegate;

/* Array of all displayed objects (after sorting and potentially filtering by you). The delegate will be asked for snapshots as they are needed.
 */
@property(copy,nonatomic) NSArray *arrangedObjects;

/* The index into the arrangedObjects that is being displayed. */
@property (readonly) NSInteger selectedIndex;

/* The viewController associated with the selected arrangedObject. May be nil if delegate is not supplying viewControllers.
 */
@property(retain, readonly) VIEW_CONTROLLER *selectedViewController;

/* Convenience init method as a delegate is required for any use of the page controller.
 */
-(id)initWithDelegate:(id<BMExtendablePageControllerDelegate>)aDelegate;

/*
 jump to any index within the bounds of provided pages using a transition class.
 */
-(void)setSelectedIndex:(NSInteger)selectedIndex withTransition:(id<BMExtendablePageTransition>)transition;

/*
 This is a short hand for setSelectedIndex with an incremented value.
 */
-(void)nextPageWithTransitionStyle:(id<BMExtendablePageTransition>)transition;

/*
 This is a short hand for setSelectedIndex with a decremented value.
 */
-(void)prevPageWithTransitionStyle:(id<BMExtendablePageTransition>)transition;


/* Use this method to attach a continuouse transition to the page controller. Use the returning reference to push subsequent updates to this transition and call finishTransition: or cancelTransition: to complete the processs.*/
-(id<BMExtendableContinuousePageTransition>)attachContinuouseTransition:(id<BMExtendableContinuousePageTransition>)transition;

@end



@protocol BMExtendablePageControllerDelegate <NSObject>
@required

/* Return the identifier of the view controller that owns a view to display the object. If NSPageController does not have an unused viewController for this identifier, the you will be asked to create one via pageController:viewControllerForIdentifier.
 */
- (NSString *)pageController:(BMExtendablePageController *)pageController identifierForIndex:(int)index;

/* NSPageController will cache as many viewControllers and views as necessary to maintain performance. This method is called whenever another instance is required. Note: The viewController may become the selectedViewController after a transition if necessary.
 */
- (VIEW_CONTROLLER *)pageController:(BMExtendablePageController *)pageController viewControllerForIdentifier:(NSString *)identifier;

/* NOTE: The following 2 methods are only useful if you also implement the above two methods.
 */

@optional

/* You only need to implement this if the view frame can differ between arrangedObjects. This method must return immediately. Avoid file, network or any potentially blocking or lengthy work to provide an answer. If this method is not implemented, all arrangedObjects are assumed to have the same frame as the current selectedViewController.view or the bounds of view when selectedViewController is nil.
 */
- (CGRect)pageController:(BMExtendablePageController *)pageController frameForObject:(id)object;

/* Prepare the viewController and view for drawing. Setup data sources and perform layout. Note: this method is called on the main thread and should return immediately. The view will be asked to draw on a background thread and must support background drawing. If this method is not implemented, then viewController's representedObject is set to the representedObject.
 */
- (void)pageController:(BMExtendablePageController *)pageController prepareViewController:(VIEW_CONTROLLER *)viewController withObject:(id)object;

/* Note: You may find these useful regardless of which way you use NSPageController (History vs Custom).
 */

/* This message is sent when any page transition is completed. */
- (void)pageController:(BMExtendablePageController *)pageController didTransitionToObject:(id)object;

/* This message is sent when the user begins a transition wither via swipe gesture of one of the navigation IBAction methods. */
- (void)pageControllerWillStartLiveTransition:(BMExtendablePageController *)pageController;

/* This message is sent when a transition animation completes either via swipe gesture or one of the navigation IBAction methods. Your content view is still hidden and you must call -completeTransition; on pageController when your content is ready to show. If completed successfully, a pageController:didTransitionToRepresentedObject: will already have been sent.
 */
- (void)pageControllerDidEndLiveTransition:(BMExtendablePageController *)pageController;


@end

@protocol BMExtendablePageTransition <NSObject>
@required

-(void)transitionFromIndex:(int)fromIdx toIndex:(int)toIdx withDuration:(float)duration andCurrenView:(VIEW*)currentView toNextView:(VIEW*)nextView onContainerView:(VIEW*)containerView withCompletion:(void (^)())completion;

@optional

/* Implement this method for easy access to a default version of the transition.*/
+(id<BMExtendablePageTransition>)transition;

@end

@protocol BMExtendableContinuousePageTransition <NSObject>
@required

/* setup a transition. The completion block expects an argument to be filled with the proper prevView/nextView/currentView depending on the movement direction */
-(void)beginTransitionWithCurrentView:(VIEW*)currentView nextView:(VIEW*)nextView prevView:(VIEW*)previousView onContainerView:(VIEW*)containerView withCompletion:(void (^)(VIEW* nowActiveView))completion;

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
+(id<BMExtendableContinuousePageTransition>)transition;

@end
