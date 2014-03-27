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

//
// implements a singleton as per : http://www.galloway.me.uk/tutorials/singleton-classes/
//
@interface UTIDataStore : NSObject {

    NSArray *allProfilesArray;
    NSArray *metaDataFields;
    NSInteger activeUserIndex;
    
}

    -(NSString *) getJsonData;
    //-(NSArray *) getArrayData;

    -(void) setJsonData: (NSString *) jsonData;

    -(NSString *) getUid: (NSString *) userName;

    -(void) setActiveUser: (NSInteger) userIndex;
    -(void) addNewUser: (NSString *)userName;

    -(NSString*) http_createUser;

    -(void) http_fetchOutstandingPrompts: (UTIPromptsTracker*)prompts useridentifier:(NSString*) ident;
    -(void) http_uploadOutstandingAudio:(NSString*) uid;
    -(void) http_uploadAudio: (NSString*) uid identifier:(NSString*) ident;
    -(void) http_getMetadata: (NSString*) uid;
    -(BOOL) http_saveMetadata: (NSString*) uid;

    -(void) http_uploadAudioFile:(NSString*) uid
                      identifier:(NSString*) ident
                        filename:(NSString*) filename
                             URL:(NSURL*) audioFileURL;

    @property (nonatomic, retain) NSArray *allProfilesArray;
    @property (nonatomic, retain) NSArray *metaDataFields;

    @property NSInteger activeUserIndex;

    +(id) sharedDataStore;

@end
