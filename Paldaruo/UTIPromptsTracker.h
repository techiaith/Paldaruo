//
//  UTIPromptsTracker.h
//  Paldaruo
//
//  Created by Apiau on 09/01/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UTIPrompt.h"

@interface UTIPromptsTracker : NSObject

-(void) addPromptForRecording: (UTIPrompt *)prompt;
-(void) promptHasBeenRecorded: (UTIPrompt *) prompt;
-(UTIPrompt *) getNextPromptToRecord;

@end
