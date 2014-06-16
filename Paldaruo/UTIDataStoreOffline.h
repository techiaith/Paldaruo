//
//  UTIDataStoreOffline.h
//  Paldaruo
//
//  Created by Dewi Bryn Jones on 16.6.2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UTIDataStore.h"

@interface UTIDataStoreOffline : NSObject {
    
}

+ (void)http_getMetadata:(NSString *)uid sender:(id <UTIErrorReporter>)sender;
+ (void)http_saveMetadata:(NSString *)uid sender:(id <NSURLConnectionDataDelegate, NSURLConnectionDelegate>)sender;

+ (void)http_fetchOutstandingPrompts:(UTIPromptsTracker *)prompts useridentifier:(NSString *)ident;
+ (void)http_uploadAudioFile:(NSString *)uid identifier:(NSString *)ident filename:(NSString *)filename URL:(NSURL *)audioFileURL sender:(id <NSURLConnectionDelegate, NSURLConnectionDataDelegate>)sender;

@end
