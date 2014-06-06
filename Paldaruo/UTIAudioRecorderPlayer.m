//
//  UTIRecordingSession.m
//  Paldaruo
//
//  Created by Apiau on 04/06/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIAudioRecorderPlayer.h"

@implementation UTIAudioRecorderPlayer

@synthesize delegate;


-(id) init {
    
    if ((self = [super init]) != nil){
    
        NSURL *audioFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"audioRecording.wav"]];
        
        NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithFloat:48000], AVSampleRateKey,
                                       [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                       [NSNumber numberWithInt: kAudioFormatLinearPCM], AVFormatIDKey,
                                       [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                       nil];
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        self.audioRecorder = [[AVAudioRecorder alloc]
                              initWithURL:audioFileURL
                              settings:audioSettings
                              error:nil];

    }
    
    return self;
    
}


#define RECORDING_TIMEOUT 20.0

-(void) recordAudio {
    
    [self.audioRecorder prepareToRecord];
    self.audioRecorder.meteringEnabled = YES;
    
    [self.audioRecorder record];
    [self.audioRecorder updateMeters];
    
    maximumDbLevel=-160.0;
    lastAverageDbLevel=0.0;
    
    _timerRecordingMetering = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.0]
                                                       interval:0.03
                                                         target:self
                                                       selector:@selector(levelTimerCallback:)
                                                       userInfo:nil
                                                        repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:_timerRecordingMetering forMode:NSDefaultRunLoopMode];
    
    self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:RECORDING_TIMEOUT
                                                            target:self
                                                          selector:@selector(timeOutRecording)
                                                          userInfo:nil
                                                           repeats:NO];
}


-(void) stopRecording {
    
    [self.audioRecorder stop];
    [self.audioPlayer stop];
    
    [_timerRecordingMetering invalidate];
    _timerRecordingMetering=nil;
    
    [self.recordingTimer invalidate];
    self.recordingTimer = nil;
    
    NSURL *audioFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"audioRecording.wav"]];
    
    // copy the file to a new location
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:nil];
    [self.audioPlayer setDelegate:self];
    
}

-(void) timeOutRecording {
    
    [self stopRecording];
    [delegate audioRecordingDidTimeout];
    
}

- (void)levelTimerCallback:(NSTimer *)timer {
    
    [self.audioRecorder updateMeters];
    
    float average = [self.audioRecorder averagePowerForChannel:0];
    float peak = [self.audioRecorder peakPowerForChannel:0];
    
    lastAverageDbLevel=average;
    if (peak>maximumDbLevel)
        maximumDbLevel=peak;
    
}

-(void) playAudio {
    [self.audioPlayer play];
}

-(float) getAveragePower{
    return powf(10.f, lastAverageDbLevel/20.f);
}

-(float) getPeakPower {
    return powf(10.f, maximumDbLevel/20.f);
}

//If user does not do anything by the end of the sound go to secondWindow
- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) player
                        successfully: (BOOL) flag {
    
    [delegate audioDidFinishPlaying:flag];
    
}

-(BOOL) areLevelsOk {
    float peak=[self getPeakPower];
    
    if (peak > PEAK_LOWER && peak < PEAK_UPPER)
        return YES;
    else
        return NO;
}

-(BOOL) areLevelsTooLoud {
    float peak=[self getPeakPower];
    
    if (peak > PEAK_UPPER)
        return YES;
    else
        return NO;
}

-(BOOL) areLevelsTooQuiet{
    float peak=[self getPeakPower];
    
    if (peak < PEAK_LOWER)
        return YES;
    else
        return NO;
}


@end
