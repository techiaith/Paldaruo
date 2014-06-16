//
//  UTIDataStore.m
//  Paldaruo
//
//  Created by Apiau on 28/01/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIDataStore.h"
#import "UTIRequest.h"
#import "UTIUploadAudioInfo.h"
#import "UTIAppDelegate.h"
#import "UTIDataStoreOffline.h"


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
    
        NSUserDefaults *persistedStore=[NSUserDefaults standardUserDefaults];
        NSData *allProfiles = [persistedStore dataForKey:@"AllProfiles"];
        if (allProfiles!=nil) {
            _allProfilesArray = [[NSKeyedUnarchiver unarchiveObjectWithData:allProfiles] mutableCopy];
        } else {
            
            _allProfilesArray=[[NSMutableArray alloc] init];
            
        }
        
        self.arrFileUploadData = [[NSMutableArray alloc] init];
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"uk.ac.bangor.techiaith.paldaruo"];
        sessionConfiguration.HTTPMaximumConnectionsPerHost = 1;
        self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                     delegate:self
                                                delegateQueue:[NSOperationQueue mainQueue]];
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
              identifier:(NSString*) ident
                  sender:(id <NSURLConnectionDelegate, NSURLConnectionDataDelegate>)sender {
    //
    // TODO:
    //
    // need to check that the upload engine and subsequent progress bar in the UI
    // can cope and be consistent with a slow upload wifi
    //
    // have used the Network Link Conditioner on the iPad to provide certain test conditions.
    //
    // I'm concerned that there isn't any more any use of NSQueuedOperation as in the beta
    // version.
    //
    // At the moment the progress bar and uploading hang on slow uploads, error messages appear
    // and wavs are missing on the server. If it was for re-introducing uploadOutstandingAudioFiles
    // after the mega merge, these would never arrive at the server.
    //
    // NEED TO EVALUATE WHY UPLOADS HANG. WHY DO ERROR MESSAGES APPEAR. WHY DOES THE PROGRESS BAR
    // NEVER INCREMENTS BEYOND 2. WHAT ALTERATIONS ARE NEED FOR THE UI - PERHAPS REMOVE THE PROGRESS
    // BAR AND FILTER ERROR MESSAGES (ESP. IF uploadOutstandingAudioFiles RESCUES THE SITUATION) PERHAPS
    // THE PROGRESS BAR CAN BE KEPT TO THE FINAL THANK YOU SCREEN IF A PILE OF FILES HAVE ACCUMALATED AND
    // THE USER SHOULD NOT YET SHUTDOWN THE APP.
    //
    // OBSERVSATIONS AFTER A SLOW CONNECTION: timeouts started occurring after the 6th or 7th file. The app
    // would recover and try to send the files again. But the user experience would be confused with the
    // errors popping up all the time. It was seen that 3 to 5 files can be sent at the same time to the server
    // thus causing the timeouts if a request was not serviced in time, whilst other files we're being uploaded.
    //
    // Therefore we need the NSQueuedOperations so that we can utilise built in queue functonality and not have
    // to re-invent the wheel. The problem with NSQueuedOperation however is that it requires using sendAsynchronousRequest
    // which as the Apple documentation states:
    //
    // If you do not need to monitor the status of a request, but merely need to perform some operation when the data
    // has been fully received, you can call sendAsynchronousRequest:queue:completionHandler:, passing a block to
    // handle the results. For more details, see “Retrieving Data Using a Completion Handler Block.”
    //
    //
    
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
    
#ifndef WIFI_OFFLINE_DEMO
    [self http_uploadAudioFile:uid identifier:ident filename:filename URL:audioFileURL sender:sender];
#else
    [UTIDataStoreOffline http_uploadAudioFile:uid identifier:ident filename:filename URL:audioFileURL sender:sender];
#endif
    
}

/*
- (void)http_uploadOutstandingAudio:(NSString*) uid {
    
    NSString *uidTempDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:uid];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    for (NSString* fileName in [fileManager contentsOfDirectoryAtPath:uidTempDirectory error:nil])
    {
        NSString* ident = [fileName stringByReplacingOccurrencesOfString:@".wav"withString:@""];
        NSString *audioFileTarget = [uidTempDirectory stringByAppendingFormat:@"/%@", fileName];
        NSURL *audioFileURL = [NSURL fileURLWithPath:audioFileTarget];
        
        if (![self isFileUploadUTIRequestAlreadyQueued:ident uid:uid]){
            //if (![self isFileAlreadyQueued:ident uid:uid]){
            
            NSString *logMessage = [NSString stringWithFormat:@"http_uploadOutstandingAudio ident:%@ uploadCount:%lu",ident, (unsigned long)[self.currentOutstandingUploads count]];
            NSLog(logMessage);
            
            [self http_uploadAudioFile:uid
                            identifier:ident
                              filename:fileName
                                   URL:audioFileURL
                                sender:nil];
        }

    }

}
*/


- (void)http_uploadAudioFile:(NSString*) uid
                  identifier:(NSString*) ident
                    filename:(NSString*) filename
                         URL:(NSURL*) audioFileURL
                      sender:(id <NSURLConnectionDelegate, NSURLConnectionDataDelegate>)sender {

    // gweler:
    // http://stackoverflow.com/questions/22487336/how-to-get-backgroundsession-nsurlsessionuploadtask-response
    // http://stackoverflow.com/questions/21767334/uploads-using-backgroundsessionconfiguration-and-nsurlsessionuploadtask-cause-ap
    
    // Yn benodol:
    //
    //  With upload tasks, make sure to not call setHTTPBody of a NSMutableRequest.
    //  With upload tasks, the body of the request cannot be in the request itself.
    //  Make sure you implement the appropriate NSURLSessionDelegate, NSURLSessionTaskDelegate methods.
    //  Make sure to implement application:handleEventsForBackgroundURLSession: in
    //  your app delegate (so you can capture the completionHandler, which you'll call
    //  in URLSessionDidFinishEventsForBackgroundURLSession).
    //
    // Felly mae angen creu request heb body (sy'n cymhlethu pethau ynghylch pasio uid, promptId a filename fel
    // parameters. Efallai dylwn newid i ddefnyddio PUT a creu URL y lleoliad terfynol ar sail uid a ident a filename
    // ein hunain.
    
    NSString *urlString = @"http://paldaruo.techiaith.bangor.ac.uk/savePrompt";
    //NSString *urlString = @"http://127.0.0.1:8082/savePrompt";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"PUT"];
    
    [request setValue:[NSString stringWithFormat:@"%@", uid] forHTTPHeaderField:@"uid"];
    [request setValue:[NSString stringWithFormat:@"%@", ident] forHTTPHeaderField:@"promptId"];
    
    UTIUploadAudioInfo *newUploadTask = [[UTIUploadAudioInfo alloc] initWithUid:uid andUploadSource:audioFileURL andIdent:ident];
    [self.arrFileUploadData addObject:newUploadTask];
    
    newUploadTask.uploadTask = [self.session uploadTaskWithRequest:request fromFile:audioFileURL];
    newUploadTask.taskIdentifier = newUploadTask.uploadTask.taskIdentifier;
    
    [newUploadTask.uploadTask resume];
    
}


-(void) handleResponseUploadAudio:(NSString *)uid
                    audioFileName:(NSString *)filename
                         response:(NSURLResponse *)response
                            error:(NSError *)error {
    
    //
    if (error== nil) {
        
        //NSString *logMessage = [NSString stringWithFormat:@"handleResponseUploadAudio ident:%@ uploadCount:%lu",filename,(unsigned long)[self.currentOutstandingUploads count]];
        //NSLog(logMessage);
        
        NSString *uidTempDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:uid];
        NSString *deleteFileTarget = [uidTempDirectory stringByAppendingFormat:@"/%@",filename];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:deleteFileTarget];
        if (fileExists){
            [fileManager removeItemAtPath:deleteFileTarget error:Nil];
        }
        
        // wedi symud galw ar llwytho i fyny ffeiliau wav 'outstanding' i fama yn hytrach na
        // view controller. Mae'n gwirio felly pob tro ar ol lwyddo i llwytho i fyny os mae na
        // ffeiliau wav eraill sydd heb eu lwytho'n lwyddianus.
        //
        //[self http_uploadOutstandingAudio:uid];
        
    }
    else {
        [self showCommunicationWithServerError:@"Llwytho sain i fyny" errorObject:error];
    }

}


-(void) http_uploadSilenceAudioFile: (NSString*) uid
                  sender:(id <NSURLConnectionDelegate, NSURLConnectionDataDelegate>)sender {
    
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *newDateString = [outputFormatter stringFromDate:now];
    NSString *identifier = [NSString stringWithFormat:@"silence_%@",newDateString];
    NSString *filename = [NSString stringWithFormat:@"%@.wav", identifier];

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
   
#ifndef WIFI_OFFLINE_DEMO
    [self http_uploadAudioFile:uid identifier:identifier filename:filename URL:audioFileURL sender:sender];
#else
    [UTIDataStoreOffline http_uploadAudioFile:uid identifier:identifier filename:filename URL:audioFileURL sender:sender];
#endif
    
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
            } else {
                [self showCommunicationWithServerError:@"Creu Defnyddiwr" errorObject:error];
            }
        };
        
        [r sendRequestSync];
    }
    return newUserId;
}


-(void) http_fetchOutstandingPrompts:(UTIPromptsTracker*)prompts useridentifier:(NSString *)uid {

#ifndef WIFI_OFFLINE_DEMO
    
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
            [prompts setFetchErrorObject:error];
            [self showCommunicationWithServerError:@"Estyn Testunau i'w Recordio" errorObject:error];
        }
        
    }];
    
    [r sendRequestSync];
    
#else
    
    [UTIDataStoreOffline http_fetchOutstandingPrompts:prompts useridentifier:uid];
    
#endif
    
}


-(void) http_getMetadata: (NSString*) uid sender:(id <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UTIErrorReporter>)sender{
    
    
#ifndef WIFI_OFFLINE_DEMO
    
    UTIRequest *r = [UTIRequest new];
    r.requestPath = @"getMetadata";
    r.delegate = sender;
    [r addBodyString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n%@", uid] withBoundary:NO]
    ;
    
    [r setCompletionHandler:^(NSData *data, NSError *error) {
        
        if (error) {
            [self showCommunicationWithServerError:@"Estyn Metadata" errorObject:error];
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
                
                [self showCommunicationWithServerError:@"Estyn Metadata"
                                           description:@"Gwall cyffredinol gyda gweinydd Paldaruo"];
                
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
    
#else
    
    [UTIDataStoreOffline http_getMetadata:uid sender:sender];
    
#endif
    
}


- (void)http_saveMetadata: (NSString*) uid sender:(id <NSURLConnectionDelegate, NSURLConnectionDataDelegate>)sender{
    
#ifndef WIFI_OFFLINE_DEMO

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
#else
    
    [UTIDataStoreOffline http_saveMetadata:uid sender:sender];

#endif
}



- (void)saveProfiles {
    NSUserDefaults *persistedStore=[NSUserDefaults standardUserDefaults];
    [persistedStore setObject:[NSKeyedArchiver archivedDataWithRootObject:self.allProfilesArray] forKey:@"AllProfiles"];
}


-(void)showCommunicationWithServerError:(NSString*) title errorObject:(NSError*)error {
   
    UIAlertView *alert;
    
    if (error.code != -9999){
        
        NSString *message = [NSString stringWithFormat:@"Roedd problem cysylltu. Gwiriwch ac ailgysylltu'ch dyfais i'r rhwydwaith ddiwifr cyn parhau. \n\n%@", [error localizedDescription]];
        
        alert= [[UIAlertView alloc] initWithTitle:title
                                          message:message
                                         delegate:nil
                                cancelButtonTitle:@"Iawn"
                                otherButtonTitles:nil];
        
    }
    else {
        
        alert= [[UIAlertView alloc] initWithTitle:title
                                          message:[error localizedDescription]
                                         delegate:nil
                                cancelButtonTitle:@"Iawn"
                                otherButtonTitles:nil];
        
    }

    [alert show];
    
}


-(void)showCommunicationWithServerError:(NSString*) title
                            description:(NSString*)description {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                          message:description
                                         delegate:nil
                                cancelButtonTitle:@"Iawn"
                                otherButtonTitles:nil];
    
    [alert show];
    
}



-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    if ([self isExistFileUploadInfoWithTaskIdentifier:dataTask.taskIdentifier]){
        int index = [self getFileUploadInfoIndexWithTaskIdentifier:dataTask.taskIdentifier];
        UTIUploadAudioInfo *upinfo = [self.arrFileUploadData objectAtIndex:index];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSString *message = [NSString stringWithFormat:@"Completed - Ident : %@ ", upinfo.ident];
            NSLog(message);
        }];
    }
}


-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    if (totalBytesExpectedToSend == NSURLSessionTransferSizeUnknown)
    {
        NSLog(@"Unknown upload size");
    }
    else {
    
        if ([self isExistFileUploadInfoWithTaskIdentifier:task.taskIdentifier]){
            int index = [self getFileUploadInfoIndexWithTaskIdentifier:task.taskIdentifier];
            UTIUploadAudioInfo *upinfo = [self.arrFileUploadData objectAtIndex:index];
    
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                upinfo.uploadProgress = (double) totalBytesSent / (double)totalBytesExpectedToSend;
                NSString *message = [NSString stringWithFormat:@"Progress - Ident : %@ (%.2f)", upinfo.ident, upinfo.uploadProgress];
                NSLog(message);
            }];
        } else {
            NSString *message = [NSString stringWithFormat:@"Task Id %lu not found", (unsigned long)task.taskIdentifier];
            NSLog(message);
        }
    }
    
}


-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error   {
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    
    if ([response statusCode] >= 300) {
        NSLog(@"Background transfer is failed, status code: %d", [response statusCode]);
        return;
    }
    
    NSDictionary* headers = [response allHeaderFields];
    NSString *filename = headers[@"fileId"];
    NSString *uid = headers[@"uid"];
    
    [self handleResponseUploadAudio:uid audioFileName:filename response:response error:error];
    
    NSLog(@"Background transfer is success");
    
}


- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
    NSLog(@"URLSessionDidFinishEventsForBackgroundURLSession");
    
    UTIAppDelegate *appDelegate = (UTIAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    
    NSLog(@"All tasks are finished");
}



-(int) getFileUploadInfoIndexWithTaskIdentifier:(unsigned long) taskIdentifier {
    int index=0;
    
    for (int i=0; i<[self.arrFileUploadData count]; i++){
        UTIUploadAudioInfo *upinfo=[self.arrFileUploadData objectAtIndex:i];
        if (upinfo.taskIdentifier==taskIdentifier){
            index=i;
            break;
        }
    }
    
    return  index;
}


-(BOOL) isExistFileUploadInfoWithTaskIdentifier:(unsigned long) taskIdentifier {

    BOOL result=NO;
    
    for (int i=0; i<[self.arrFileUploadData count]; i++){
        UTIUploadAudioInfo *upinfo=[self.arrFileUploadData objectAtIndex:i];
        if (upinfo.taskIdentifier==taskIdentifier){
            result=YES;
        }
    }
    
    return result;
    
}

@end
