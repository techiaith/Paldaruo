//
//  UTIPrompt.m
//  Paldaruo
//
//  Created by Apiau on 09/01/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIPrompt.h"

@implementation UTIPrompt

-(id) init{
    
    if ((self = [super init]) != nil) {
        text=nil;
        identifier=nil;
        index=0;
        isRecorded=NO;
    }
    
    return self;
    
}

@end
