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
                                       @{@"identifier":@"sample1", @"text":@"lleuad, melyn, aelodau, siarad, ffordd, ymlaen, cefnogaeth, Helen"},
                                       @{@"identifier":@"sample2", @"text":@"gwraig, oren, diwrnod, gwaith, mewn, eisteddfod, disgownt, iddo"},
                                       @{@"identifier":@"sample3", @"text":@"oherwydd, Elliw, awdurdod, blynyddoedd, gwlad, tywysog, llyw, uwch"},
                                       @{@"identifier":@"sample4", @"text":@"rhybuddio, Elen, uwchraddio, hwnnw, beic, Cymru, rhoi, aelod"},
                                       @{@"identifier":@"sample5", @"text":@"rhai, steroid, cefnogaeth, felen, cau, garej, angau, ymhlith"},
                                       @{@"identifier":@"sample6", @"text":@"gwneud, iawn, un, dweud, llais, wedi, gyda, llyn"},
                                       @{@"identifier":@"sample7", @"text":@"lliw, yng Nghymru, gwneud, rownd, ychydig, wy, yn, llaes"},
                                       @{@"identifier":@"sample8", @"text":@"hyn, newyddion, ar, roedd, pan, llun, melin, sychu"},
                                       @{@"identifier":@"sample9", @"text":@"ychydig, glin, wrth, Huw, at, nhw, bod, bydd"}
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
