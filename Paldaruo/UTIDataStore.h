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

//
// implements a singleton as per : http://www.galloway.me.uk/tutorials/singleton-classes/
//


@interface UTIDataStore : NSObject {

    NSArray *allProfilesArray;
    NSArray *metaDataFields;
    
}

@property UTIUser *activeUser;
@property (nonatomic, retain) NSArray *allProfilesArray;
@property (nonatomic, retain) NSArray *metaDataFields;

- (UTIUser *)userAtIndex:(NSUInteger)idx;


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
- (NSString *)http_createUser_delegate:(id <UTIRequestDelegate>)delegate;
- (void)http_fetchOutstandingPrompts:(UTIPromptsTracker *)prompts useridentifier:(NSString *)ident;
- (void)http_uploadAudio:(NSString *)uid identifier:(NSString*)ident;
- (void)http_getMetadata:(NSString *)uid;
- (void)http_saveMetadata:(NSString *)uid;



+(id) sharedDataStore;

@end
