//
//  UTIAppDelegate.m
//  Paldaruo
//
//  Created by Dewi Bryn Jones on 27.12.2013.
//  Copyright (c) 2013 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIDataStore.h"

@implementation UTIAppDelegate
							
- (void)applicationWillResignActive:(UIApplication *)application {
    [[UTIReachability instance] stopNotifiers];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[UTIReachability instance] stopNotifiers];
    [[UTIDataStore sharedDataStore] saveProfiles];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[UTIReachability instance] startNotifiers];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UTIReachability instance] startNotifiers];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[UTIDataStore sharedDataStore] saveProfiles];
}


- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    
    self.backgroundSessionCompletionHandler = completionHandler;
    NSLog(@"handleEventsForBackgroundURLSession initiated");
    
}

@end
