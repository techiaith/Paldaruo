//
//  UTIRecordingSession.h
//  Paldaruo
//
//  Created by Apiau on 04/06/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>

#define PEAK_UPPER 1.0000
#define PEAK_LOWER 0.5000

@class UTIAudioRecorderPlayer;

@protocol UTIAudioRecorderPlayerDelegate

-(void)audioDidFinishPlaying:(BOOL)successful;

@end

@interface UTIAudioRecorderPlayer : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, assign) id delegate;

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSTimer *timerRecordingMetering;

-(void) recordAudio;
-(void) stopRecording;
-(void) playAudio;

-(float) getPeakPower;
-(float) getAveragePower;

-(BOOL) areLevelsOk;
-(BOOL) areLevelsTooLoud;
-(BOOL) areLevelsTooQuiet;

@end

float maximumDbLevel;
float lastAverageDbLevel;
