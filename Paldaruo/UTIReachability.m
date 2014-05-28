//
//  UTIReachability.m
//  Paldaruo
//
//  Created by Dewi Bryn Jones on 28.5.2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIReachability.h"

@implementation UTIReachability

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
        
        //observe the internet connection to the paldaruo app server
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkStatusChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
        hostReachable = [Reachability reachabilityWithHostname:kServerHostName];
        [hostReachable startNotifier];
        
        wifiReachable = [Reachability reachabilityForLocalWiFi];
        [wifiReachable startNotifier];

    }
    
    return self;

}

-(void)networkStatusChanged:(NSNotification *)notice {
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    NetworkStatus wifiStatus = [wifiReachable currentReachabilityStatus];
    
    //
    BOOL internetActive = ((hostStatus == ReachableViaWiFi) && (wifiStatus == ReachableViaWiFi));
    
    //
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
