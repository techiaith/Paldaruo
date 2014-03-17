//
//  UTIReachability.h
//  Paldaruo
//
//  Created by Apiau on 07/03/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@class Reachability;

@interface UTIReachability : NSObject {
    
    Reachability* hostReachable;
    Reachability* wifiReachable;
    
}

    -(BOOL) isPaldaruoReachable;

    +(id) instance;

@end

