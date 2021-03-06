//
//  UTIDataStore.h
//  Paldaruo
//
//  Created by Apiau on 28/01/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UTIPromptsTracker.h"
#import "UTIMetaDataField.h"
#import "UTIUser.h"
#import "UTIRequest.h"

@protocol UTIErrorReporter <NSObject>

- (void)showError:(NSError *)error;
- (void)showErrorText:(NSString *)errorText;

@end


@interface UTIDataStore : NSObject  <NSURLSessionTaskDelegate> {
    NSArray *metaDataFields;
}

+(id) sharedDataStore;

@property UTIUser *activeUser;
@property (nonatomic, retain) NSMutableArray *allProfilesArray;
@property (nonatomic, retain) NSArray *metaDataFields;

@property (nonatomic, strong) NSURLSession *session;

- (UTIUser *)userAtIndex:(NSUInteger)idx;
- (UTIUser *)userForName:(NSString *)name;

/**
 *  Saves the current user profiles
 */
- (void)saveProfiles;

/**
 *  Adds a new user (on the server side) for the given name
 *
 *  @param userName The username to associate with this user
 *
 *  @return a UID value, as created by the server, for this user. If the UID is nil,
 *  then user was not created successfully
 */
- (UTIUser *)addNewUser:(NSString *)userName;
- (UTIUser *)addNewUser:(NSString *)userName uid:(NSString *)uid;

- (NSString *)http_createUser_completionBlock:(urlCompletionHandler)block;
- (void)http_fetchOutstandingPrompts:(UTIPromptsTracker *)prompts useridentifier:(NSString *)ident;
- (void)http_uploadAudio:(NSString *)uid identifier:(NSString*)ident sender:(id <NSURLConnectionDelegate, NSURLConnectionDataDelegate>)sender;

- (void)http_uploadAudioFile:(NSString *)uid identifier:(NSString *)ident filename:(NSString *)filename URL:(NSURL *)audioFileURL sender:(id <NSURLConnectionDelegate, NSURLConnectionDataDelegate>)sender;

- (void)http_uploadSilenceAudioFile:(NSString *)uid sender:(id <NSURLConnectionDelegate, NSURLConnectionDataDelegate>)sender;

- (void)http_getMetadata:(NSString *)uid sender:(id <UTIErrorReporter>)sender;
- (void)http_saveMetadata:(NSString *)uid sender:(id <NSURLConnectionDataDelegate, NSURLConnectionDelegate>)sender;


@end
