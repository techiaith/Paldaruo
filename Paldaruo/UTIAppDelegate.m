//
//  UTIAppDelegate.m
//  Paldaruo
//
//  Created by Dewi Bryn Jones on 27.12.2013.
//  Copyright (c) 2013 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIDataStore.h"

//#import "TestFlight.h"

@implementation UTIAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.appReachability = [Reachability reachabilityForInternetConnection];
    NetworkUnreachable block = ^(Reachability *r) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Cysylltiad Di-wifr"
                                                        message: @"Mae Paldaruo angen cysylltiad di-wifr at y we i weithio'n iawn."
                                                       delegate: nil
                                              cancelButtonTitle: @"Iawn"
                                              otherButtonTitles: nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    };
    self.appReachability.unreachableBlock = block;
    [self.appReachability startNotifier];
    // start of your application:didFinishLaunchingWithOptions // ...
    //[TestFlight takeOff:@"82c9650a-2835-4afb-812c-e449bc352d70"];
    
    // The rest of your application:didFinishLaunchingWithOptions method// ...
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.appReachability stopNotifier];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.appReachability stopNotifier];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UTIDataStore sharedDataStore] saveProfiles];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self.appReachability startNotifier];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[UTIDataStore sharedDataStore] saveProfiles];
}

@end
