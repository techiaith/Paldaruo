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

//
// implements a singleton as per : http://www.galloway.me.uk/tutorials/singleton-classes/
//
@interface UTIDataStore : NSObject {

    NSArray *allProfilesArray;
    NSArray *metaDataFields;
    
}

@property UTIUser *activeUser;

- (UTIUser *)userAtIndex:(NSUInteger)idx;

    -(NSString *) getJsonData;
    //-(NSArray *) getArrayData;

    -(void) setJsonData: (NSString *) jsonData;

    -(NSString *) getUid: (NSString *) userName;

    -(void) addNewUser: (NSString *)userName;

    -(NSString*) http_createUser;
    -(void) http_fetchOutstandingPrompts: (UTIPromptsTracker*)prompts useridentifier:(NSString*) ident;
    -(void) http_uploadAudio: (NSString*) uid identifier:(NSString*) ident;
    -(void) http_getMetadata: (NSString*) uid;
    -(void) http_saveMetadata: (NSString*) uid;

    @property (nonatomic, retain) NSArray *allProfilesArray;
    @property (nonatomic, retain) NSArray *metaDataFields;

    @property NSInteger activeUserIndex;

    +(id) sharedDataStore;

@end
