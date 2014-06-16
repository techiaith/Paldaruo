//
//  UTIDataStoreOffline.m
//  Paldaruo
//
//  Created by Dewi Bryn Jones on 16.6.2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIDataStoreOffline.h"

@implementation UTIDataStoreOffline


+ (void)http_fetchOutstandingPrompts:(UTIPromptsTracker *)prompts useridentifier:(NSString *)ident {
    
    NSArray *hardcodePrompts = [NSArray arrayWithObjects:
                                @"hen gwlad tadau annwyl mi",
                                @"tatws moron pys cig",
                                @"gwyliau haul traeth tywod",
                                nil];
    
    for (int x=0; x < hardcodePrompts.count; x++)
    {
        UTIPrompt *newPrompt = [[UTIPrompt alloc] init];
        newPrompt.text = [hardcodePrompts objectAtIndex:x];
        newPrompt.identifier = [NSString stringWithFormat:@"offline-sample-%d",x];
        
        [prompts addPromptForRecording:newPrompt];
    }
    

}


+ (void)http_uploadAudioFile:(NSString *)uid identifier:(NSString *)ident filename:(NSString *)filename URL:(NSURL *)audioFileURL sender:(id <NSURLConnectionDelegate, NSURLConnectionDataDelegate>)sender{
    // do nothing
}


+ (void)http_getMetadata:(NSString *)uid sender:(id <UTIErrorReporter>)sender {
    // do nothing
}


+ (void)http_saveMetadata:(NSString *)uid sender:(id <NSURLConnectionDataDelegate, NSURLConnectionDelegate>)sender {
    // do nothing
}


@end
