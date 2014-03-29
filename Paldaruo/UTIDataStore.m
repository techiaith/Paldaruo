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

    NSString *uid = [self http_createUser];
    
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
    
    [self http_uploadAudioFile:uid identifier:ident filename:filename URL:audioFileURL];
    
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
                               URL:audioFileURL];

    }

}


- (void)http_uploadAudioFile:(NSString*) uid
                  identifier:(NSString*) ident
                    filename:(NSString*) filename
                         URL:(NSURL*) audioFileURL {
    
    UTIRequest *r = [UTIRequest new];
    r.requestPath = @"savePrompt";
    [r addBodyString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n%@", uid]];
    [r addBodyString:[NSString stringWithFormat:@"content-disposition: form-data; name=\"promptId\"\r\n\r\n%@", ident]];

    // add wav file
    
    [r addBodyString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", filename]];
    [r addBodyString:@"Content-Type: audio/wav\r\n\r\n"];
    
    [r addBodyData:[[NSData alloc] initWithContentsOfURL:audioFileURL]];
    
    [r setCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
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
        r.completionHandler = ^(NSURLResponse *response, NSData *data, NSError *error) {
            if (error==nil) {
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
    
    [r addBodyString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n%@", uid]];
    
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
    
    [r addBodyString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n%@", uid]];
    
    
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


- (BOOL)http_saveMetadata: (NSString*) uid {
    
    BOOL returnResult = YES;
    
    NSString *urlString = @"http://paldaruo.techiaith.bangor.ac.uk/saveMetadata";

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",kRequestBoundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",kRequestBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n%@", uid]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // get the metadata fields values as a key/value dictionary
    NSMutableDictionary *metaDataValues = [[NSMutableDictionary alloc] init];
    [metaDataFields enumerateObjectsUsingBlock:^(UTIMetaDataField *field, NSUInteger idx, BOOL *stop) {
        [metaDataValues setValue:[field getValue] forKey:[field getKey]];
    }];
    
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:metaDataValues
                                                     options:0
                                                       error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"metadata\"\r\n\r\n%@", jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];

    NSError *error;
    NSURLResponse *returningResponse;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:&returningResponse
                                                       error:&error];
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)returningResponse;
    int code = [httpResponse statusCode];

    
    if ((error!=nil) || (code!=200)) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Llwytho Meta Data"
                                                        message: @"Gwall cyffredinol wrth lwytho eich metadata i fyny"
                                                       delegate: nil
                                              cancelButtonTitle: @"Iawn"
                                              otherButtonTitles: nil];
        [alert show];
        
        returnResult=NO;

    }
    
    return returnResult;
    
}



-(void) handleResponseUploadAudio:(NSData *)data error:(NSError *)error {
    
    
    if ([data length] >0 && error == nil) {
    
        //NSDictionary *json=[NSJSONSerialization JSONObjectWithData:data
        //                                                   options:kNilOptions
        //                                                     error:nil];
        
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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


@end
