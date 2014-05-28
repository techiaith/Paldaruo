//
//  UTIReachability.h
//  Paldaruo
//
//  Created by Dewi Bryn Jones on 28.5.2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@class Reachability;

@interface UTIReachability : NSObject {
    
    Reachability* internetReachable;
    Reachability* hostReachable;
    Reachability* wifiReachable;
    
}

+(id) instance;

- (void) startNotifiers;
- (void) stopNotifiers;


@end
