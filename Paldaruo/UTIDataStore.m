//
//  UTIDataStore.m
//  Paldaruo
//
//  Created by Apiau on 28/01/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIDataStore.h"
#import "UTIRequest.h"

@implementation UTIDataStore

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
        _numberOfUploadingFiles = 0;
        NSUserDefaults *persistedStore=[NSUserDefaults standardUserDefaults];
        NSData *allProfiles = [persistedStore dataForKey:@"AllProfiles"];
        if (allProfiles!=nil) {
            _allProfilesArray = [[NSKeyedUnarchiver unarchiveObjectWithData:allProfiles] mutableCopy];
        } else {
            
            _allProfilesArray=[[NSMutableArray alloc] init];
            
        }
        
    }
    
    return self;
    
}

- (UTIUser *)addNewUser:(NSString *)userName {
    return [self addNewUser:userName uid:nil];
}

- (UTIUser *)addNewUser:(NSString *)userName uid:(NSString *)uid {
    if (!uid) {
        uid = [self http_createUser];
    }
    
    if (!uid) {
        return nil;
    }
    
    UTIUser *newUser = [UTIUser userWithName:userName uid:uid];
    
    //NSString *newUserJsonString=[NSString stringWithFormat:@"{\"name\":\"%@\",\"uid\":\"%@\"}",userName, uid];
    //
    [self willChangeValueForKey:@"allProfilesArray"];
    [self.allProfilesArray addObject:newUser];
    [self didChangeValueForKey:@"allProfilesArray"];
    
    // make the new user the active user
    [self setActiveUser:newUser];
    [self saveProfiles];
    return newUser;
    
}

- (UTIUser *)userAtIndex:(NSUInteger)idx {
    if (idx >= [self.allProfilesArray count]) {
        return nil;
    }
    return [self.allProfilesArray objectAtIndex:idx];
}

- (UTIUser *)userForName:(NSString *)name {
    for (UTIUser *u in self.allProfilesArray) {
        if ([u.name isEqualToString:name]) {
            return u;
        }
    }
    return nil;
}

-(void) http_uploadAudio: (NSString*) uid
              identifier:(NSString*) ident sender:(id <NSURLConnectionDelegate, NSURLConnectionDataDelegate>)sender {
    
    NSString *filename = [NSString stringWithFormat:@"%@.wav", ident];
    NSString *uidTempDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:uid];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:uidTempDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:uidTempDirectory
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    
    NSString *audioFileSource = [NSTemporaryDirectory() stringByAppendingString:@"audioRecording.wav"];
    NSString *audioFileTarget = [uidTempDirectory stringByAppendingFormat:@"/%@", filename];
    
    [[NSFileManager defaultManager] copyItemAtPath:audioFileSource toPath:audioFileTarget error:nil];
    
    NSURL *audioFileURL = [NSURL fileURLWithPath:audioFileTarget];
    //[NSTemporaryDirectory()stringByAppendingString:@"audioRecording.wav"]];
    
    [self http_uploadAudioFile:uid identifier:ident filename:filename URL:audioFileURL sender:sender];
    
}


- (void)http_uploadOutstandingAudio:(NSString*) uid {
    
    NSString *uidTempDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:uid];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    for (NSString* fileName in [fileManager contentsOfDirectoryAtPath:uidTempDirectory error:nil]) {
        
        NSString *audioFileTarget = [uidTempDirectory stringByAppendingFormat:@"/%@", fileName];
        NSURL *audioFileURL = [NSURL fileURLWithPath:audioFileTarget];
        
        NSString* ident = [fileName stringByReplacingOccurrencesOfString:@".wav"withString:@""];
        [self http_uploadAudioFile:uid
                        identifier:ident
                          filename:fileName
                               URL:audioFileURL
                            sender:nil];

    }

}


- (void)http_uploadAudioFile:(NSString*) uid
                  identifier:(NSString*) ident
                    filename:(NSString*) filename
                         URL:(NSURL*) audioFileURL
                      sender:(id <NSURLConnectionDelegate, NSURLConnectionDataDelegate>)sender {

    
    UTIRequest *r = [UTIRequest new];
    r.delegate = sender;
    r.requestPath = @"savePrompt";
    [r addBodyString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n%@", uid] withBoundary:YES];
    [r addBodyString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"promptId\"\r\n\r\n%@", ident] withBoundary:YES];

    // add wav file
    
    [r addBodyString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", filename] withBoundary:NO];
    [r addBodyString:@"Content-Type: audio/wav\r\n\r\n" withBoundary:NO];
    [r addBodyData:[[[NSData alloc] initWithContentsOfURL:audioFileURL] base64EncodedDataWithOptions:0] withBoundary:NO];
    
    [r setCompletionHandler:^(NSData *data, NSError *error) {
        self.numberOfUploadingFiles -= 1;
        NSString *message = nil;
        if ([data length]) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSString *error = responseDict[@"error"];
            if (error && [error length]) {
                message = @"Gwall gyda'r gweinydd";
            }
        } else if ([data length] == 0 && error == nil) {
            message = @"Ymateb gwag";
        } else if (error.code == NSURLErrorTimedOut){
            message = @"Timeout";
        } else if (error != nil) {
            message = @"Gwall cyffredinol";
        }
        
        if (message) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Llwytho i fyny"
                                                            message: message
                                                           delegate: nil
                                                  cancelButtonTitle: @"Iawn"
                                                  otherButtonTitles: nil];
            [alert show];
        }
    }];
    self.numberOfUploadingFiles += 1;
    [r sendRequestAsync];
    
}


- (NSString *)http_createUser {
    return [self http_createUser_completionBlock:nil];
}


- (NSString *)http_createUser_completionBlock:(urlCompletionHandler)block {
    
    
    NSString __block *newUserId=nil;
    
    
    UTIRequest *r = [UTIRequest new];
    r.requestPath = @"createUser";
    if (block) {
        r.completionHandler = block;
        [r sendRequestAsync];
        return nil;
    } else {
        r.completionHandler = ^(NSData *data, NSError *error) {
            if (error==nil) {
                NSDictionary *json=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
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
    
    [r addBodyString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n%@", uid] withBoundary:NO];
    
    [r setCompletionHandler:^(NSData *data, NSError *error) {
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



-(void) http_getMetadata: (NSString*) uid sender:(id <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UTIErrorReporter>)sender{
    
    UTIRequest *r = [UTIRequest new];
    r.requestPath = @"getMetadata";
    r.delegate = sender;
    [r addBodyString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n%@", uid] withBoundary:NO]
    ;
    
    [r setCompletionHandler:^(NSData *data, NSError *error) {
        if (error) {
            [sender showError:error];
        }
        if (error==nil) {
            NSDictionary *json=[NSJSONSerialization JSONObjectWithData:data
                                                               options:kNilOptions
                                                                 error:nil];
            id jsonResponse = json[@"response"];

            if (![jsonResponse isKindOfClass:[NSArray class]]) {
                
                NSString *errMsg = nil;
                if ([jsonResponse respondsToSelector:@selector(objectForKey:)]) {
                    errMsg = [jsonResponse objectForKey:@"error"];
                }
                [sender showError:[NSError errorWithDomain:@"uk.ac.bangor.techiaith.paldaruo" code:-9999 userInfo:@{NSLocalizedDescriptionKey : errMsg ? errMsg : @"Gwall Cyffredinol"}]];
                return;
            }
            // initialise the prompts tracker.
            for (NSDictionary *jsonFieldAttributes in jsonResponse) {
                UTIMetaDataField *newField=[[UTIMetaDataField alloc] init];
                
                newField.fieldId=jsonFieldAttributes[@"id"];
                newField.title=jsonFieldAttributes[@"title"];
                newField.question=jsonFieldAttributes[@"question"];
                newField.explanation=jsonFieldAttributes[@"explanation"];
                
                // options.
                NSArray *jsonOptionsArray=jsonFieldAttributes[@"options"];
                
                if (jsonOptionsArray!=(id)[NSNull null]){
                    
                    newField.isText=NO;
                    
                    for (NSDictionary *options in jsonOptionsArray) {
                        NSString *optionId = [options objectForKey:@"id"];
                        NSString *optionText = [options objectForKey:@"text"];
                        [newField addOptionWithId:optionId text:optionText];
                    }
                } else {
                    newField.isText=YES;
                }
                metaDataFields = [metaDataFields arrayByAddingObject:newField];
            }
            
        }
    }];
    
    [r sendRequestAsync];
}


- (void)http_saveMetadata: (NSString*) uid sender:(id <NSURLConnectionDelegate, NSURLConnectionDataDelegate>)sender{
    
    UTIRequest *r = [UTIRequest new];
    r.requestPath = @"saveMetadata";
    r.delegate = sender;
    [r addBodyString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n%@", uid] withBoundary:YES];

    
    // get the metadata fields values as a key/value dictionary
    NSMutableDictionary *metaDataValues = [[NSMutableDictionary alloc] init];
    [metaDataFields enumerateObjectsUsingBlock:^(UTIMetaDataField *field, NSUInteger idx, BOOL *stop) {
        [metaDataValues setValue:field.value forKey:field.fieldId];
    }];
    
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:metaDataValues
                                                     options:0
                                                       error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [r addBodyString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"metadata\"\r\n\r\n%@", jsonString] withBoundary:NO];

    [r sendRequestAsync];
    
}



-(void) handleResponseUploadAudio:(NSData *)data error:(NSError *)error {
    
    if ([data length] >0 && error == nil) {
    
        NSDictionary *json=[NSJSONSerialization JSONObjectWithData:data
                                                           options:kNilOptions
                                                             error:nil];
        
        NSDictionary *jsonResponse = json[@"response"];
        NSString *filename = jsonResponse[@"fileId"];
        NSString *uid = jsonResponse[@"uid"];
        
        NSString *uidTempDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:uid];
        NSString *deleteFileTarget = [uidTempDirectory stringByAppendingFormat:@"/%@",filename];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:deleteFileTarget];
        if (fileExists){
            [fileManager removeItemAtPath:deleteFileTarget error:Nil];
        }
        
    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Problem Cysylltu"
                                                        message: @"Gwiriwch ac ail-gysylltwch eich ddyfais i'r rhwydwaith ddi-wifr cyn barhau"
                                                       delegate: nil
                                              cancelButtonTitle: @"Iawn"
                                              otherButtonTitles: nil];
        [alert show];
        
    }
    
}


- (void)saveProfiles {
    NSUserDefaults *persistedStore=[NSUserDefaults standardUserDefaults];
    [persistedStore setObject:[NSKeyedArchiver archivedDataWithRootObject:self.allProfilesArray] forKey:@"AllProfiles"];
}

@end
