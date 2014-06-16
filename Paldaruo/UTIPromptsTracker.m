//
//  UTIPromptsTracker.m
//  Paldaruo
//
//  Created by Apiau on 09/01/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIPromptsTracker.h"
#include <stdlib.h>


@interface UTIPromptsTracker ()

@property (strong, nonatomic) NSMutableArray *prompts;

@property NSInteger initialCount;
@property NSInteger remainingCount;
@property NSError *error;

@end


@implementation UTIPromptsTracker


-(id) init{
    
    if ((self = [super init]) != nil) {
        
        self.prompts=[[NSMutableArray alloc] init];
        self.initialCount=0;
        self.remainingCount=0;
        self.error=nil;
        
    }
    
    return self;
    
}

-(void) addPromptForRecording: (UTIPrompt *)prompt {
    [self.prompts addObject:prompt];
    self.initialCount=self.prompts.count;
}


-(void) promptHasBeenRecorded: (UTIPrompt *) prompt{
    [self.prompts removeObject:prompt];
    self.remainingCount=self.prompts.count;
}


-(UTIPrompt *) getNextPromptToRecord {
    
    //int r=arc4random_uniform(self.prompts.count);
    //if (r<self.prompts.count){
    if (self.prompts.count>0){
        //return (UTIPrompt*)self.prompts[r];
        return (UTIPrompt*)self.prompts[0];
    }
    else
        return nil;
    
}


-(NSInteger) getInitialCount{
    return self.initialCount;
}


-(NSInteger) getRemainingCount {
    return self.remainingCount;
}


-(void) setFetchErrorObject: (NSError*)error {
    self.error = error;
}

-(NSError *) getFetchErrorObject{
    return self.error;
}


@end
