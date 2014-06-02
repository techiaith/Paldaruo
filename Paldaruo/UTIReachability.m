//
//  UTIReachability.m
//  Paldaruo
//
//  Created by Dewi Bryn Jones on 28.5.2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIReachability.h"

@implementation UTIReachability

BOOL internetActive;

+(id) instance {
    
    static UTIReachability *sharedReachibilitySingleton=nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedReachibilitySingleton=[[self alloc] init];
    });
    
    return sharedReachibilitySingleton;

}

-(id) init {
    
    if ((self = [super init]) != nil){
        
        internetActive=YES;
        
        //observe the internet connection to the paldaruo app server
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkStatusChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
        internetReachable = [Reachability reachabilityForInternetConnection];
        hostReachable = [Reachability reachabilityWithHostname:kServerHostName];
        wifiReachable = [Reachability reachabilityForLocalWiFi];

        [self startNotifiers];
        
    }
    
    return self;

}

-(void)startNotifiers{
    
    [internetReachable startNotifier];
    [hostReachable startNotifier];
    [wifiReachable startNotifier];
    
}

-(void)stopNotifiers {
    
    [internetReachable stopNotifier];
    [hostReachable stopNotifier];
    [wifiReachable stopNotifier];
    
}

-(void)networkStatusChanged:(NSNotification *)notice {
    
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    NetworkStatus wifiStatus = [wifiReachable currentReachabilityStatus];
    
    //
    bool existingInternetActive = internetActive;
    
    internetActive = ((internetStatus == ReachableViaWiFi) &&
                      (hostStatus == ReachableViaWiFi) &&
                      (wifiStatus == ReachableViaWiFi));
    
    // don't do anything if the internetactive status has not changed. 
    if (existingInternetActive!=internetActive){
        
        if (internetActive==NO){
        
            // notify all observing viewcontrollers that the internet via wifi is down
            // (so that they can take action when in the middle of their interaction with the user
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InternetUnreachable"
                                                            object:nil];
        
            [self showAppServerUnreachableAlert];
        
        } else {
        
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InternetReachable" object:nil];
        
        }
        
    }
    
}

-(void) showAppServerUnreachableAlert {
    //
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Cysylltiad Di-wifr"
                                                    message: @"Mae Paldaruo angen cysylltiad di-wifr at y we i weithio'n iawn."
                                                   delegate: nil
                                          cancelButtonTitle: @"Iawn"
                                          otherButtonTitles: nil];
    [alert show];
}

@end
