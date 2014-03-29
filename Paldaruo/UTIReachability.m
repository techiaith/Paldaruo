//
//  UTIReachability.m
//  Paldaruo
//
//  Created by Apiau on 07/03/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIReachability.h"

@implementation UTIReachability

BOOL internetActive;

+(id) instance {
    
    static UTIReachability *sharedReachabilitySingleton=nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedReachabilitySingleton=[[self alloc] init];
    });
    
    return sharedReachabilitySingleton;
}


-(id) init {
    
    if ((self = [super init]) != nil) {
        
        // Monitor the internet connection
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
        
        hostReachable = [Reachability reachabilityWithHostname: @"paldaruo.techiaith.bangor.ac.uk"];
        [hostReachable startNotifier];
        
        wifiReachable = [Reachability reachabilityForLocalWiFi];
        [wifiReachable startNotifier];
        
        //
        internetActive = (([hostReachable currentReachabilityStatus] == ReachableViaWiFi) &&
                          ([wifiReachable currentReachabilityStatus] == ReachableViaWiFi));
        
    }
    
    return self;
    
}

-(void)networkStatusChanged:(NSNotification *)notice {
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    NetworkStatus wifiStatus = [wifiReachable currentReachabilityStatus];
    
    //
    internetActive = ((hostStatus == ReachableViaWiFi) && (wifiStatus == ReachableViaWiFi));
    
    //
    if (internetActive==NO){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"InternetUnreachable"
                                                           object:nil];
        
        
        //
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Cysylltiad Di-wifr"
                                                        message: @"Mae Paldaruo angen cysylltiad di-wifr at y we i weithio'n iawn."
                                                       delegate: nil
                                              cancelButtonTitle: @"Iawn"
                                              otherButtonTitles: nil];
        [alert show];
        
        
    } else {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"InternetReachable" object:nil];
         
    }
    
}

+(BOOL) isPaldaruoReachable{
    return internetActive;
}


@end
