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
@synthesize activeUserIndex;

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

        NSUserDefaults *persistedStore=[NSUserDefaults standardUserDefaults];
        NSString *allProfiles=[persistedStore stringForKey:@"AllProfilesJson"];
        
        metaDataFields=[[NSArray alloc] init];
        
        if (allProfiles!=nil) {
            
            NSData* data=[allProfiles dataUsingEncoding:NSUTF8StringEncoding];
            allProfilesArray=(NSArray*)[NSJSONSerialization JSONObjectWithData:data
                                                                       options:NSJSONReadingMutableContainers
                                                                         error:nil];
        } else {
            
            allProfilesArray=[[NSArray alloc] init];
            
        }
        
    }
    
    return self;
    
}


-(NSString *) getJsonData {
    
        return @"[{\"name\":\"Alice\",\"uid\":\"1\"},{\"name\":\"Bob\",\"uid\":\"2\"},{\"name\":\"Charlie\",\"uid\":\"3\"}]";
    
    //store("profileInfo", @"[{\"name\":\"Alice\",\"uid\":\"1\"},{\"name\":\"Bob\",\"uid\":\"2\"},{\"name\":\"Charlie\",\"uid\":\"3\"}]");
    //return retrieve("profileInfo");
}



-(void) setJsonData: (NSString *) jsonData {
        
}



-(NSString *) getUid: (NSString *) userName {
    return @"42";
}



-(void) addNewUser: (NSString *)userName {
    
    NSString *uid=[self http_createUser];
    
    NSDictionary *newUserDictionary=[[NSDictionary alloc] initWithObjectsAndKeys:
        userName, @"name",
        uid, @"uid",
        nil];
    
    //NSString *newUserJsonString=[NSString stringWithFormat:@"{\"name\":\"%@\",\"uid\":\"%@\"}",userName, uid];
    //
    allProfilesArray = [allProfilesArray arrayByAddingObject:newUserDictionary];
    
    // persist...
    //
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:allProfilesArray options:0 error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSUserDefaults *persistedStore=[NSUserDefaults standardUserDefaults];
    [persistedStore setObject:jsonString forKey:@"AllProfilesJson"];
    
    [persistedStore synchronize];
    
    // make the new user the active user
    [self setActiveUser:[allProfilesArray count]-1];
    
}



-(void) setActiveUser:(NSInteger)userIndex {
    activeUserIndex=userIndex;
    
}



-(void) http_uploadAudio: (NSString*) uid
               identifier:(NSString*) ident {
    
    NSString *filename = [NSString stringWithFormat:@"%@.wav", ident];
    NSString *audioFileSource = [NSTemporaryDirectory() stringByAppendingString:@"audioRecording.wav"];
    NSString *audoFileTarget = [NSTemporaryDirectory() stringByAppendingString:filename];
    
    [[NSFileManager defaultManager] copyItemAtPath:audioFileSource toPath:audoFileTarget error:nil];
    
    NSURL *audioFileURL = [NSURL fileURLWithPath:audoFileTarget];
    //[NSTemporaryDirectory()stringByAppendingString:@"audioRecording.wav"]];
    
    NSData *file1Data = [[NSData alloc] initWithContentsOfURL:audioFileURL];
    
    //NSString *urlString = @"http://techiaith.bangor.ac.uk/gallu/upload/upload.php";
    NSString *urlString = @"http://paldaruo.techiaith.bangor.ac.uk/savePrompt";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    // add uid
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n%@", uid]] dataUsingEncoding:NSUTF8StringEncoding]];

    // add prompt id
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"promptId\"\r\n\r\n%@", ident]] dataUsingEncoding:NSUTF8StringEncoding]];

    // add wav file
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", filename]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //[body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: audio/wav\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:file1Data]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //
    [request setHTTPBody:body];
    
    // send asynchronous
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [self handleResponseUploadAudio:data error:error];
     }
     
     ];
    
}



-(NSString *) http_createUser {
    
    NSString *newUserId=nil;
    
    NSString *urlString = @"http://paldaruo.techiaith.bangor.ac.uk/createUser";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    NSError *error;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request
                          returningResponse:nil
                                      error:&error];
    
    if (error==nil) {
        
        //newUserId=[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSString *jsonString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Llwytho i fyny"
        //                                                message: jsonString
        //                                               delegate: nil
        //                                      cancelButtonTitle: @"Iawn"
        //                                      otherButtonTitles: nil];
        
        //[alert show];
        
        NSDictionary *json=[NSJSONSerialization JSONObjectWithData:result
                                                           options:kNilOptions
                                                             error:nil];
        
        NSDictionary *jsonResponse = json[@"response"];
        newUserId = jsonResponse[@"uid"];
        
    }
    
    return newUserId;
    
}



-(void) http_fetchOutstandingPrompts:(UTIPromptsTracker*)prompts useridentifier:(NSString *)uid {
    
    NSString *urlString = @"http://paldaruo.techiaith.bangor.ac.uk/getOutstandingPrompts";
    
    //NSString *urlString = [NSURL URLWithString:@"http://paldaruo.techiaith.bangor.ac.uk/getOutstandingPrompts"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];

    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n%@", uid]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //NSString *string = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:body];
    
    //[NSURLConnection sendAsynchronousRequest:request
    //                                     queue:[NSOperationQueue mainQueue]
    //                         completionHandler:^(NSURLResponse*r, NSData*d, NSError*e)
    //   {
    //       [caller handleResponseDownloadPrompts:d error:e];
    //   }];
    
    NSError *error;
    NSData *result = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:nil
                                                       error:&error];

    if (error==nil) {
        
        NSDictionary *json=[NSJSONSerialization JSONObjectWithData:result
                                                           options:kNilOptions
                                                             error:nil];
        NSArray *jsonArray = json[@"response"];
        
        // initialise the prompts tracker.
        for (int x = 0; x < jsonArray.count; x++)
        {
            UTIPrompt* newPrompt=[[UTIPrompt alloc] init];
            
            newPrompt->text = [[jsonArray objectAtIndex:x] objectForKey:@"text"];
            newPrompt->identifier = [[jsonArray objectAtIndex:x] objectForKey:@"identifier"];
            
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

}

-(void) http_getMetadata: (NSString*) uid {
    
    NSString *urlString = @"http://paldaruo.techiaith.bangor.ac.uk/getMetadata";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n%@", uid]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    
    NSError *error;
    NSData *result = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:nil
                                                       error:&error];
    
    if (error==nil) {
        
        NSDictionary *json=[NSJSONSerialization JSONObjectWithData:result
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
    
}

-(void) http_saveMetadata: (NSString*) uid {
    
    NSString *urlString = @"http://paldaruo.techiaith.bangor.ac.uk/saveMetadata";

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n%@", uid]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // get the metadata fields values as a key/value dictionary
    NSMutableDictionary *metaDataValues = [[NSMutableDictionary alloc] init];
    for (int i=0; i < metaDataFields.count; i++){
        
        UTIMetaDataField *nextField = [metaDataFields objectAtIndex:i];
        
        NSString* v=[nextField getValue];
        NSString* k=[nextField getKey];
        
        [metaDataValues setValue:v forKey:k];
        
    }
    
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:metaDataValues
                                                     options:0
                                                       error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"metadata\"\r\n\r\n%@", jsonString]] dataUsingEncoding:NSUTF8StringEncoding]];

    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];

    NSError *error;
    NSData *result = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:nil
                                                       error:&error];
    
    if (error!=nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Llwytho Meta Data"
                                                        message: @"Gwall cyffredinol wrth lwytho eich metadata i fyny"
                                                       delegate: nil
                                              cancelButtonTitle: @"Iawn"
                                              otherButtonTitles: nil];
        [alert show];
    }

    
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
        NSString *deleteFileTarget = [NSTemporaryDirectory() stringByAppendingString:filename];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:deleteFileTarget];
        if (fileExists){
            [fileManager removeItemAtPath:deleteFileTarget error:Nil];
        }
        
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Llwytho i fyny"
        //                                                    message: jsonString
        //                                                   delegate: nil
        //                                          cancelButtonTitle: @"Iawn"
        //                                          otherButtonTitles: nil];
        //
        //[alert show];
    
    }
    else if ([data length] == 0 && error == nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Llwytho i fyny"
                                                        message: @"Ymateb gwag"
                                                       delegate: nil
                                              cancelButtonTitle: @"Iawn"
                                              otherButtonTitles: nil];
        [alert show];
        
    }
    else if (error != nil && error.code == NSURLErrorTimedOut){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Llwytho i fyny"
                                                        message: @"Timeout"
                                                       delegate: nil
                                              cancelButtonTitle: @"Iawn"
                                              otherButtonTitles: nil];
        [alert show];
        
    }
    else if (error != nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Llwytho i fyny"
                                                        message: @"Gwall cyffredinol"
                                                       delegate: nil
                                              cancelButtonTitle: @"Iawn"
                                              otherButtonTitles: nil];
        [alert show];
        
    }
    
}

@end
