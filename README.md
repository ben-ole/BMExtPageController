**This project is not maintained anymore!**

# BMExtendablePageController

A replacement for *UIPageController* / *NSPageController*, because we need **custom transitions**!

BMExtPageController is a **drop in - replacement** and mirrors almost all functionalities found in *UIPageController* so if you’ve been starting a project already and you feel limited with default transition styles and behavior offered - give BMExtPageController a try.

## Features offered
* iOS and OSX ready
* Two kinds of transitions offered:
	* Basic transition
	* Continuous transitions - e. g. attach a panning gesture to take control over the transition timing
* Custom transitions
	* use one of the built in transitions, which currently support:
		* *Basic transition*: Fading
		* *Basic transition*: Horizontal Flipping
		* *Continuous transition*: Horizontal *Paged* Scrolling
	* easily extend or create from scratch adopting one of the required protocols
		* BMExtendablePageTransition
		* BMExtendableContinuousePageTransition
* Performance oriented implementation
	* Automatic page preloading
	* ViewController recycling
	* Multithreading using GrandDispatchCentral
* No further dependencies

## Project Integration
Use cocoapods and put the following dependency to your Podfile:

``` ruby
pod 'BMExtendablePageController'
``` 

## Example Usage                        

The way how you provide content for BMExtandablePageController is identical to the *Bookmode* discussed in the *NSPageController* [Reference](http://developer.apple.com/library/Mac/#documentation/AppKit/Reference/NSPageController_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40012265-CH1-SW21)                              

See also [iOS Sample Project](https://github.com/elchbenny/BMExtPageController-iOS-Example)

### 01. Create Instance
Create an instance of *BMExtendablePageController*  by dragging an *UIView/NSView* in your storyboard/xib or create one in code. Anyway, you need to provide a **delegate** implementing the _BMExtendablePageControllerDelegate_ protocol and assign an *NSArray* to the _arrangedObjects_ property containing data for each page.

``` objective-c		
BMExtendablePageController *pageController = [[BMExtendablePageController alloc] 
                                               initWithDelegate:self	
                                                arrangedObjects:@[@„page01“,@„page02“,@„page03“] 
                                                      completed:^{
                                                        // page load completed - do what ever you want.
                                                      }];
```

### 02. Delegate Implementation

``` objective-c		
// return identifiers ( to support recycling )
-(NSString *)pageController:(BMExtendablePageController *)pageController identifierForIndex:(int)index{
    
    if (index == 0) {
        return @„VIEW_CONTROLLER_1“;
    }else if(index == 1){
        return @„VIEW_CONTROLLER_2“;
    }else{
        return @„VIEW_CONTROLLER_3“;
    }
}

// return new instances depending on identifier
-(UIViewController *)pageController:(BMExtendablePageController *)pageController viewControllerForIdentifier:(NSString *)identifier{
    
    if([identifier isEqualToString:VIEW_CONTROLLER_1])
        return [[ViewController01 alloc] init];
    else if([identifier isEqualToString:VIEW_CONTROLLER_2])
        return [[ViewController02 alloc] init];
    else
        return [[ViewController03 alloc] init];
}

-(void)pageController:(BMExtendablePageController *)pageController 	
prepareViewController:(UIViewController *)viewController withObject:(id)object{
	// update the (eventually recycled)  view controller with page specific data object
	viewController.data = object;    
}
```

### 03. Perform Transition

In case you want a **basic transition** you simply call
``` objective-c

// next page
[_pageController nextPageWithTransitionStyle:[BMHorizontalFlipTransition transition]];
	  
// or previous page
[_pageController prevPageWithTransitionStyle:[BMHorizontalFlipTransition 
	   transition]];
	   
// or any page
[_pageController setSelectedIndex:104 withTransition:[BMFadeTransition transition]];	   
```
*Please note: you are responsible to stay within your index boundaries.*

Or attach a **continuous transition** to the page controller (e.g. on touch down)
``` objective-c		
_currentTransition = [_pageController attachContinuouseTransition:	[BMHorizontalCTransition transition]];
```
and now update *_currentTransition* whenever needed - e. g. on *scrollViewDidScroll:*

``` objective-c
[_currentTransition updateTransitionWithValue:normalizedIndex];	// -1.0 < normalizedIndex < +1.0
```	
  
##Available TRANSITIONS
- Horizontal Flip Transition, which is identical to the NSPageControllers *NSPageControllerTransitionStyleHorizontalStrip*
- Continuous Horizontal Transition, which is the same as the Horizontal Flip Transition, but you can fully control the progress of the transition (e.g. by attaching drag gesture updates)
- Fade Transition


##Contribution
Please feel invited to contribute to this projects. Especially, I would be happy to have some more fancy transition styles available. 

##LICENSE

*MIT License*

Copyright (C) 2013 by Benjamin Müller

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
