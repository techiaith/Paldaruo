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
    
    
    NSDictionary *json = @{@"response":@[
                                       @{@"identifier":@"sample1", @"text":@"HEN GWLAD TADAU ANNWYL MI"},
                                       @{@"identifier":@"sample2", @"text":@"TATWS BLODAU MORON MEFUS"}
                                       ]
                           };
    
    NSArray *jsonArray = json[@"response"];
    
    // initialise the prompts tracker.
    for (int x = 0; x < jsonArray.count; x++)
    {
        UTIPrompt* newPrompt=[[UTIPrompt alloc] init];
        
        newPrompt.text = [[jsonArray objectAtIndex:x] objectForKey:@"text"];
        newPrompt.identifier = [[jsonArray objectAtIndex:x] objectForKey:@"identifier"];
        
        //[self.prompts addPromptForRecording:newPrompt];
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
