//
//  UTIDataStore.m
//  Paldaruo
//
//  Created by Apiau on 28/01/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIDataStore.h"

@implementation UTIDataStore

@synthesize allProfilesArray;
@synthesize metaDataFields;

+(id) sharedDataStore {
    
    static UTIDataStore *sharedDataStoreSingleton=nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedDataStoreSingleton=[[self alloc] init];
    });
    
    return sharedDataStoreSingleton;
}


-(id) init {
    
    //NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
    //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
        
    if (self = [super init]){
        metaDataFields=[[NSArray alloc] init];
        
        NSUserDefaults *persistedStore=[NSUserDefaults standardUserDefaults];
        NSData *allProfiles = [persistedStore dataForKey:@"AllProfiles"];
        if (allProfiles!=nil) {
            allProfilesArray = [NSKeyedUnarchiver unarchiveObjectWithData:allProfiles];
        } else {
            
            allProfilesArray=[[NSArray alloc] init];
            
        }
        
    }
    
    return self;
    
}

- (UTIUser *)addNewUser:(NSString *)userName {

    NSString *uid = [self http_createUser_delegate:nil];
    
    if (!uid) {
        return nil;
    }
    UTIUser *newUser = [UTIUser userWithName:userName uid:uid];
    
    //NSString *newUserJsonString=[NSString stringWithFormat:@"{\"name\":\"%@\",\"uid\":\"%@\"}",userName, uid];
    //
    allProfilesArray = [allProfilesArray arrayByAddingObject:newUser];
    
    // make the new user the active user
    [self setActiveUser:newUser];
    return newUser;
    
}

- (UTIUser *)userAtIndex:(NSUInteger)idx {
    if (idx >= [self.allProfilesArray count]) {
        return nil;
    }
    return [self.allProfilesArray objectAtIndex:idx];
}

-(void) http_uploadAudio: (NSString*) uid
              identifier:(NSString*) ident {
    
    UTIRequest *request = [UTIRequest new];
    request.requestPath = @"savePrompt";
    
    // Add the UID data object
    [request addBodyString:[NSString stringWithFormat:@"content-disposition: form-data; name=\"uid\"\r\n\r\n%@", uid] usingEncoding:NSUTF8StringEncoding];

    // add prompt id
    [request addBodyString:[NSString stringWithFormat:@"content-disposition: form-data; name=\"promptId\"\r\n\r\n%@", ident] usingEncoding:NSUTF8StringEncoding];

    // add wav file
    NSString *filename = [NSString stringWithFormat:@"%@.wav", ident];

    [request addBodyString:[NSString stringWithFormat:@"content-disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", filename] usingEncoding:NSUTF8StringEncoding];
    
    [request addBodyString:@"Content-Type: audio/wav\r\n\r\n" usingEncoding:NSUTF8StringEncoding];
    
    NSURL *audioFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"audioRecording.wav"]];
    [request addBodyData:[[NSData alloc] initWithContentsOfURL:audioFileURL]];
    
    [request setCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSString *message = nil;
        if ([data length] == 0 && error == nil) {
            message = @"Ymateb gwag";
        }
        else if (error != nil && error.code == NSURLErrorTimedOut){
            message = @"Timeout";
        }
        else if (error != nil) {
            message = @"Gwall cyffredinol";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Llwytho i fyny"
                                                        message: message
                                                       delegate: nil
                                              cancelButtonTitle: @"Iawn"
                                              otherButtonTitles: nil];
        [alert show];
    }];
    
    [request sendRequestAsync];
    
}



- (NSString *)http_createUser_delegate:(id <UTIRequestDelegate>)delegate {
    NSString __block *newUserId=nil;
    
    UTIRequest *r = [UTIRequest new];
    r.requestPath = @"createUser";
    if (delegate) {
        r.delegate = delegate;
        [r sendRequestAsync];
    } else {
    r.completionHandler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            NSDictionary *json=[NSJSONSerialization JSONObjectWithData:data
                                                               options:kNilOptions
                                                                 error:nil];
            
            NSDictionary *jsonResponse = json[@"response"];
            newUserId = jsonResponse[@"uid"];
        }
    };
    [r sendRequestSync];
    }
    

    return newUserId;
}



-(void) http_fetchOutstandingPrompts:(UTIPromptsTracker*)prompts useridentifier:(NSString *)uid {
    UTIRequest *r = [UTIRequest new];
    r.requestPath = @"getOutstandingPrompts";
    
    [r addBodyString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n%@", uid] usingEncoding:NSUTF8StringEncoding];
    
    [r setCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            
            NSDictionary *json=[NSJSONSerialization JSONObjectWithData:data
                                                               options:kNilOptions
                                                                 error:nil];
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
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Llwytho i lawr"
                                                            message: @"Gwall cyffredinol"
                                                           delegate: nil
                                                  cancelButtonTitle: @"Iawn"
                                                  otherButtonTitles: nil];
            [alert show];
            
        }
    }];
    [r sendRequestSync];
    
}

-(void) http_getMetadata: (NSString*) uid {
    
    UTIRequest *r = [UTIRequest new];
    r.requestPath = @"getMetadata";
    
    [r addBodyString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n%@", uid] usingEncoding:NSUTF8StringEncoding];
    
    
    [r setCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error==nil) {
            NSDictionary *json=[NSJSONSerialization JSONObjectWithData:data
                                                               options:kNilOptions
                                                                 error:nil];
            NSArray *jsonFieldsArray = json[@"response"];
            
            // initialise the prompts tracker.
            for (int x = 0; x < jsonFieldsArray.count; x++)
            {
                UTIMetaDataField *newField=[[UTIMetaDataField alloc] init];
                NSDictionary *jsonFieldAttributes=[jsonFieldsArray objectAtIndex:x];
                
                newField->fieldId=jsonFieldAttributes[@"id"];
                newField->title=jsonFieldAttributes[@"title"];
                newField->question=jsonFieldAttributes[@"question"];
                newField->explanation=jsonFieldAttributes[@"explanation"];
                
                // options.
                NSArray *jsonOptionsArray=jsonFieldAttributes[@"options"];
                
                if (jsonOptionsArray!=(id)[NSNull null]){
                    
                    newField->isText=NO;
                    
                    for (int o=0; o<jsonOptionsArray.count; o++){
                        
                        NSString *optionId=[[jsonOptionsArray objectAtIndex:o] objectForKey:@"id"];
                        NSString *optionText=[[jsonOptionsArray objectAtIndex:o] objectForKey:@"text"];
                        
                        [newField addOptionWithId:optionId text:optionText];
                        
                    }
                } else {
                    newField->isText=YES;
                }
                metaDataFields = [metaDataFields arrayByAddingObject:newField];
            }
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Llwytho i lawr"
                                                            message: @"Gwall cyffredinol"
                                                           delegate: nil
                                                  cancelButtonTitle: @"Iawn"
                                                  otherButtonTitles: nil];
            [alert show];
            
        }

    }];
    
    
}

-(void) http_saveMetadata: (NSString*) uid {
    UTIRequest *r = [UTIRequest new];
    r.requestPath = @"saveMetadata";
    
    [r addBodyString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n%@", uid] usingEncoding:NSUTF8StringEncoding];
    
    
    // get the metadata fields values as a key/value dictionary
    NSMutableDictionary *metaDataValues = [[NSMutableDictionary alloc] init];
    [metaDataFields enumerateObjectsUsingBlock:^(UTIMetaDataField *field, NSUInteger idx, BOOL *stop) {
        [metaDataValues setValue:[field getValue] forKey:[field getKey]];
    }];
    
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:metaDataValues
                                                     options:0
                                                       error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    [r addBodyString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"metadata\"\r\n\r\n%@", jsonString] usingEncoding:NSUTF8StringEncoding];
    
    
    [r setCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error!=nil) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Llwytho Meta Data"
                                                            message: @"Gwall cyffredinol wrth lwytho eich metadata i fyny"
                                                           delegate: nil
                                                  cancelButtonTitle: @"Iawn"
                                                  otherButtonTitles: nil];
            [alert show];
        }
    }];
    
}

- (void)saveProfiles {
    NSData *profilesData = [NSKeyedArchiver archivedDataWithRootObject:allProfilesArray];
    [[NSUserDefaults standardUserDefaults] setObject:profilesData forKey:@"AllProfiles"];
}

@end
