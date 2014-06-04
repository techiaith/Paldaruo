//
//  UTIViewController.h
//  Paldaruo    
//
//  Created by Dewi Bryn Jones on 27.12.2013.
//  Copyright (c) 2013 Uned Technolegau Iaith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>

#import "UTIPromptsTracker.h"
#import "UTIDataStore.h"
#import "UTIAudioRecorderPlayer.h"

@interface UTIViewController : UIViewController <UTIAudioRecorderPlayerDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) UTIAudioRecorderPlayer *audio;
@property (strong, nonatomic) NSMutableArray *currentUploadConnections;

-(void) recordAudio;
-(void) stopRecording;
-(void) playAudio;

-(void) updateSessionProgress;

-(BOOL) gotoNextPrompt;

-(void) setRecordStatusText : (NSString *) text;
-(void) setMoveToNextRecordStateTitle : (NSString *) text;

@end

typedef enum TypeDefRecordStatus {
    DOWNLOADING_PROMPTS,
    RECORDING_SESSION_START,
    RECORDING_WAIT_TO_START,
    RECORDING,
    RECORDING_FINISHED,
    RECORDING_LISTENING_END,
    RECORDING_WAIT_TO_GOTO_NEXT,
    RECORDING_WAIT_TO_REDO_RECORDING,
    RECORDING_SESSION_END
} RecordStatus;

enum TypeDefRecordStatus currentRecordingStatus;

UTIPromptsTracker *prompts;
NSString *uid;

float maximumDbLevel;
float lastAverageDbLevel;

