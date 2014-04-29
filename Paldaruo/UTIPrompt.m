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
    
    if (self = [super init]) {
        _text=nil;
        _identifier=nil;
        _index=0;
        _recorded=NO;
    }
    
    return self;
    
}

@end
