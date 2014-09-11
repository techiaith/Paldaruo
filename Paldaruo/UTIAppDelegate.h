//
//  UTIAppDelegate.h
//  Paldaruo
//
//  Created by Dewi Bryn Jones on 27.12.2013.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UTIReachability.h"

@interface UTIAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy) void (^backgroundSessionCompletionHandler)();

@end
