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
        _currentOutstandingUploads = [NSMutableArray new];
        
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
    
    [self http_uploadAudioFile:uid identifier:ident filename:filename URL:audioFileURL sender:sender];
    
}


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
    [r addBodyData:[[NSData alloc] initWithContentsOfURL:audioFileURL] withBoundary:NO];
    
    [self addFileUploadUTIRequestToDispatchQueue:r ident:ident uid:uid];
    
    [r setCompletionHandler:^(NSData *data, NSError *error) {
        
        [self handleResponseUploadAudio:data error:error];
        
    }];
    
    [self sendNextUTIFileToServer];
        
}


-(void) sendNextUTIFileToServer {
    
    if (self.numberOfUploadingFiles==0){
        
        if ([self.currentOutstandingUploads count] > 0){
            self.numberOfUploadingFiles += 1;
            UTIRequest *r = (UTIRequest *)[self.currentOutstandingUploads objectAtIndex:0];
            
            NSString *logMessage = [NSString stringWithFormat:@"http_uploadAudioFile ident:%@ uploadCount:%lu size:%lu",
                                    r.tag,
                                    (unsigned long)[self.currentOutstandingUploads count],
                                    (unsigned long)[r.bodyDataArray count]];
            NSLog(logMessage);
            
            [r sendRequestAsync];
        }
    }
    
}


-(void) addFileUploadUTIRequestToDispatchQueue:(UTIRequest *) request
                                         ident:(NSString*) ident
                                           uid:(NSString*)uid{
    
    NSString *outstandingFileCandidateId = [NSString stringWithFormat:@"%@_%@",uid, ident];
    request.tag=outstandingFileCandidateId;
    
    [self.currentOutstandingUploads addObject:request];
    
}



-(void) removeFileUploadUTIRequestFromSendQueue:(NSString*) ident uid:(NSString*)uid {
    
    NSString *outstandingFileCandidateId = [NSString stringWithFormat:@"%@_%@",uid, ident];
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (UTIRequest *nextRequest in self.currentOutstandingUploads){
        
        if (![nextRequest.tag isEqualToString:outstandingFileCandidateId]){
            //[self.currentOutstandingUploads removeObject:nextRequest];
            [tempArray addObject:nextRequest];
        }
        
    }
    
    [self.currentOutstandingUploads removeAllObjects];
    [self.currentOutstandingUploads addObjectsFromArray:tempArray];
    
    if ([self.currentOutstandingUploads count]==0)
    {
        NSLog(@"Current Outstanding Uploads Queue is empty");
    }
}


-(BOOL) isFileUploadUTIRequestAlreadyQueued:(NSString*) ident uid:(NSString*)uid {
    NSString *outstandingFileCandidateId = [NSString stringWithFormat:@"%@_%@",uid, ident];
    
    
    for (UTIRequest *nextRequest in self.currentOutstandingUploads){
        if ([nextRequest.tag isEqualToString:outstandingFileCandidateId]){
            return YES;
        }
    }
    
    return NO;
    
}


-(void) handleResponseUploadAudio:(NSData *)data error:(NSError *)error {
    
    self.numberOfUploadingFiles -= 1;
    
    if ([data length] > 0 && error == nil) {
        
        NSDictionary *json=[NSJSONSerialization JSONObjectWithData:data
                                                           options:kNilOptions
                                                             error:nil];
        
        NSDictionary *jsonResponse = json[@"response"];
        NSString *filename = jsonResponse[@"fileId"];
        NSString *uid = jsonResponse[@"uid"];
        
        NSString *logMessage = [NSString stringWithFormat:@"handleResponseUploadAudio ident:%@ uploadCount:%lu",filename,(unsigned long)[self.currentOutstandingUploads count]];
        NSLog(logMessage);
        
        NSString *uidTempDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:uid];
        NSString *deleteFileTarget = [uidTempDirectory stringByAppendingFormat:@"/%@",filename];
        NSString *ident = [filename stringByReplacingOccurrencesOfString:@".wav"withString:@""];
        
        // remove successful file upload from queue and the iDevice
        [self removeFileUploadUTIRequestFromSendQueue:ident uid:uid];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:deleteFileTarget];
        if (fileExists){
            [fileManager removeItemAtPath:deleteFileTarget error:Nil];
        }
        
        [self sendNextUTIFileToServer];

        // wedi symud galw ar llwytho i fyny ffeiliau wav 'outstanding' i fama yn hytrach na
        // view controller. Mae'n gwirio felly pob tro ar ol lwyddo i llwytho i fyny os mae na
        // ffeiliau wav eraill sydd heb eu lwytho'n lwyddianus.
        [self http_uploadOutstandingAudio:uid];
        
    }
    else {
        [self showCommunicationWithServerError:@"Llwytho sain i fyny" errorObject:error];
        
        // try again
        [self sendNextUTIFileToServer];
    }
    
    
    
}


/*
 -(void) addFileToSendQueue:(NSString*) ident uid:(NSString*)uid {
 NSString *outstandingFileCandidateId = [NSString stringWithFormat:@"%@_%@",uid, ident];
 NSUInteger fileIndex = [self.currentOutstandingUploads indexOfObject:outstandingFileCandidateId];
 if (fileIndex==NSNotFound)
 {
 [self.currentOutstandingUploads addObject:outstandingFileCandidateId];
 }
 }
 
 
 -(void) removeFileUploadFromSendQueue:(NSString*) ident uid:(NSString*)uid {
 NSString *outstandingFileCandidateId = [NSString stringWithFormat:@"%@_%@",uid, ident];
 
 NSUInteger fileIndex = [self.currentOutstandingUploads indexOfObject:outstandingFileCandidateId];
 
 if (fileIndex!=NSNotFound){
 [self.currentOutstandingUploads removeObjectAtIndex:fileIndex];
 }
 }
 
 
 -(BOOL) isFileAlreadyQueued:(NSString*) ident uid:(NSString*)uid {
 NSString *outstandingFileCandidateId = [NSString stringWithFormat:@"%@_%@",uid, ident];
 NSUInteger fileIndex = [self.currentOutstandingUploads indexOfObject:outstandingFileCandidateId];
 if (fileIndex==NSNotFound)
 {
 return NO;
 } else {
 return YES;
 }
 }
 */


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
    
    [self http_uploadAudioFile:uid
                    identifier:identifier
                      filename:filename
                           URL:audioFileURL
                        sender:sender];
    
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
    
}


-(void) http_getMetadata: (NSString*) uid sender:(id <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UTIErrorReporter>)sender{
    
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



- (void)saveProfiles {
    NSUserDefaults *persistedStore=[NSUserDefaults standardUserDefaults];
    [persistedStore setObject:[NSKeyedArchiver archivedDataWithRootObject:self.allProfilesArray] forKey:@"AllProfiles"];
}


-(void)showCommunicationWithServerError:(NSString*) title errorObject:(NSError*)error {
   
    UIAlertView *alert;
    
    if (error.code != -9999){
        
        alert= [[UIAlertView alloc] initWithTitle:title
                                          message:@"Roedd problem cysylltu. Gwiriwch ac ailgysylltu'ch dyfais i'r rhwydwaith ddiwifr cyn parhau"
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


@end
