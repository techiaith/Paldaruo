//
//  UTIPromptsTracker.m
//  Paldaruo
//
//  Created by Apiau on 09/01/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIPromptsTracker.h"

@interface UTIPromptsTracker ()

@property (strong, nonatomic) NSMutableArray *prompts;
@property NSUInteger position;

@end


@implementation UTIPromptsTracker


-(id) init{
    
    if ((self = [super init]) != nil) {
        self.prompts=[[NSMutableArray alloc] init];
    }
    
    return self;
    
}


-(void) addPromptForRecording: (UTIPrompt *)prompt {
    [self.prompts addObject:prompt];
}


-(void) promptHasBeenRecorded: (UTIPrompt *) prompt{
    
    UTIPrompt* nextPrompt=nil;
    
    // find match for a prompt our way.
    for (int i=0; i <= self.prompts.count;i++)
    {
        nextPrompt = (UTIPrompt *) self.prompts[i];
        
        if (nextPrompt->identifier==prompt->identifier){
            nextPrompt->isRecorded=YES;
            break;
        }
    }
    
}


-(UTIPrompt *) getNextPromptToRecord {
    
    if (self.position < (self.prompts.count -1)){
        self.position++;
    }
    return (UTIPrompt*)self.prompts[self.position];
    
}



@end
