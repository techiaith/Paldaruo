//
//  UTIViewController.m
//  Paldaruo
//
//  Created by Dewi Bryn Jones on 27.12.2013.
//  Copyright (c) 2013 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIViewController.h"
#import "UTIReachability.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)

@interface UTIViewController ()

- (IBAction)btnMoveToNextRecordingState:(id)sender;
- (IBAction)btnRedoRecording:(id)sender;
- (IBAction)unwindToHome:(id)sender;

@property (weak) UTIPrompt *currentPrompt;

@property (weak, nonatomic) IBOutlet UILabel *lblOutletNextPrompt;
@property (weak, nonatomic) IBOutlet UILabel *lblOutletRecordingStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletMoveToNextRecordingState;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletRedoRecording;
@property (weak, nonatomic) IBOutlet UILabel *lblOutletProfileName;
@property (weak, nonatomic) IBOutlet UILabel *lblOutletSessionProgress;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletBackToHome;
@property (weak, nonatomic) IBOutlet UILabel *lblUploadingFilesInfo;
@property (weak, nonatomic) IBOutlet UIProgressView *uploadProgressBar;

@property (strong, nonatomic) NSTimer *lblOutletRecordingStatusTimer;
@property (strong, nonatomic) NSTimer *timerRecordingMetering;

@end

@implementation UTIViewController


- (void)viewDidLoad {
    
    uid = [[UTIDataStore sharedDataStore] activeUser].uid;
    
    currentRecordingStatus=DOWNLOADING_PROMPTS;
    [self btnMoveToNextRecordingState:self];
    
    _currentUploadConnections = [NSMutableArray new];
    self.uploadProgressBar.progress = 0;
    
    prompts = [[UTIPromptsTracker alloc] init];
    
    //[[UTIDataStore sharedDataStore] fetchOutstandingPrompts:self identifier:uid];
    //[[UTIDataStore sharedDataStore] http_fetchOutsandingPrompts:prompts identifier:uid];
    [[UTIDataStore sharedDataStore] http_fetchOutstandingPrompts:prompts useridentifier:uid];
    
    //
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
    
    currentRecordingStatus=RECORDING_SESSION_START;
    [self btnMoveToNextRecordingState:self];
    
    // register to be informed of the status of the internet connection to the paldaruo app server.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInternetReachable:)
                                                 name:@"InternetReachable"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInternetUnreachable:)
                                                 name:@"InternetUnreachable"
                                               object:nil];
    
    [super viewDidLoad];
    
}

- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"InternetReachable"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"InternetUnreachable"
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnMoveToNextRecordingState:(id)sender {
    
    switch (currentRecordingStatus) {
            
        case DOWNLOADING_PROMPTS: {
            NSString* userName = [[UTIDataStore sharedDataStore] activeUser].name;
            NSString* userGreeting=[NSString stringWithFormat:@"Helo %@!", userName];
            
            [[self lblOutletProfileName] setText:userGreeting];
            
            [self.lblOutletNextPrompt setText:@"Estyn testunau i'w recordio...."];
            [self.btnOutletMoveToNextRecordingState setHidden:YES];
            [self.lblOutletRecordingStatus setHidden:YES];
            [self.lblOutletSessionProgress setHidden:YES];
            [self.btnOutletRedoRecording setHidden:YES];
            break;
            
            
        } case RECORDING_SESSION_START: {
            if (![self gotoNextPrompt]) {
                break;
            }
            [self setMoveToNextRecordStateTitle:@"Cychwyn Recordio"];
            
            [self.lblOutletSessionProgress setHidden:NO];
            [self.btnOutletMoveToNextRecordingState setHidden:NO];
            [self.btnOutletRedoRecording setHidden:YES];
            
            [self updateSessionProgress];
            
            currentRecordingStatus=RECORDING_WAIT_TO_START;
            break;
            
            
        } case RECORDING_WAIT_TO_START: {
            [self setMoveToNextRecordStateTitle:@"Gorffen Recordio"];
            
            //[self.lblOutletRecordingStatus setHidden:NO];
            [self.btnOutletRedoRecording setHidden:YES];
            
            [self recordAudio];
            
            currentRecordingStatus=RECORDING;
            break;
            
            
        } case RECORDING: {
            [self stopRecording];

            [self.btnOutletRedoRecording setHidden:YES];
            
            if (IS_IPHONE)
                [self setMoveToNextRecordStateTitle:@"Gwrando"];
            else
                [self setMoveToNextRecordStateTitle:@"Cliciwch i wrando ar eich recordiad"];
            
            [self setRedoRecordingText:@"Recordio eto"];
            [self.btnOutletRedoRecording setHidden:NO];
            
            currentRecordingStatus=RECORDING_FINISHED;
            break;
            
            
        } case RECORDING_FINISHED: {
            [self setMoveToNextRecordStateTitle:@""];
            [self.btnOutletMoveToNextRecordingState setHidden:YES];
            [self.btnOutletRedoRecording setHidden:YES];
            [self playAudio];
            break;
            
            
        } case RECORDING_LISTENING_END: {
            [self setMoveToNextRecordStateTitle:@"Nesaf"];
            [self.btnOutletMoveToNextRecordingState setHidden:NO];
            
            [self setRedoRecordingText:@"Recordio eto"];
            [self.btnOutletRedoRecording setHidden:NO];
            
            currentRecordingStatus=RECORDING_WAIT_TO_GOTO_NEXT;
            break;
            
            
        } case RECORDING_WAIT_TO_REDO_RECORDING: {
            [self setMoveToNextRecordStateTitle:@"Cychwyn Recordio"];
            [self.lblOutletRecordingStatus setHidden:YES];
            [self.btnOutletRedoRecording setHidden:YES];
            
            currentRecordingStatus=RECORDING_WAIT_TO_START;
            break;
            
            
        } case RECORDING_WAIT_TO_GOTO_NEXT: {
            [[UTIDataStore sharedDataStore] http_uploadAudio:uid
                                                  identifier:self.currentPrompt.identifier
                                                      sender:self];
            
            [self gotoNextPrompt];
            
            [self updateSessionProgress];
            
            [self setMoveToNextRecordStateTitle:@"Cychwyn Recordio"];
            [self.lblOutletRecordingStatus setHidden:YES];
            [self.btnOutletRedoRecording setHidden:YES];
            
            currentRecordingStatus=RECORDING_WAIT_TO_START;
            break;
            
            
        } case RECORDING_SESSION_END: {
            [self.btnOutletMoveToNextRecordingState setHidden:YES];
            [self.btnOutletRedoRecording setHidden:YES];
            
            [self.lblOutletSessionProgress setHidden:YES];
            
            NSString* userName=[[UTIDataStore sharedDataStore] activeUser].name;
            
            NSString* userGreeting = [NSString stringWithFormat:@"Diolch yn fawr iawn am gyfrannu dy lais %@!", userName];
            
            [[self lblOutletProfileName] setText:userGreeting];
            [self.btnOutletBackToHome setHidden:NO];
            break;
        }
            
            
        default:
            break;
    }
    
}

- (IBAction)unwindToHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)btnRedoRecording:(id)sender {
    currentRecordingStatus=RECORDING_WAIT_TO_REDO_RECORDING;
    [self btnMoveToNextRecordingState:(self)];
}

- (void) updateSessionProgress {
    
    
    NSString* progressString = [NSString stringWithFormat:@"%ld / %ld testun ar ôl",
                                (long)[prompts getRemainingCount],
                                (long)[prompts getInitialCount]
                                ];
    
    [self.lblOutletSessionProgress setText:progressString];
    
}


- (void) setMoveToNextRecordStateTitle:(NSString *)titleString {
    [self.btnOutletMoveToNextRecordingState setTitle:titleString forState:(UIControlStateNormal) ];
}


-(void) setRecordStatusText:(NSString *) statusText {
    [self.lblOutletRecordingStatus setText:statusText];
}


-(void) setRedoRecordingText:(NSString *) redoText {
    [self.btnOutletRedoRecording setTitle:redoText forState:(UIControlStateNormal)];
}


-(void) recordAudio {
    
    [self startRecordingStatusTimerWithString:@"Yn recordio…"];
    
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

}


-(void) stopRecording {
    
    [self removeRecordingStatus];
    [self.audioRecorder stop];
    [self.audioPlayer stop];
    
    [_timerRecordingMetering invalidate];
    _timerRecordingMetering=nil;
    
    NSURL *audioFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"audioRecording.wav"]];
    
    // copy the file to a new location
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:nil];
    [self.audioPlayer setDelegate:self];
    
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
    
    float peakDecibelPowerLevel = powf(10.f,maximumDbLevel/ 20.f);
    float averageDecibelPowerLevel = powf(10.f,lastAverageDbLevel/ 20.f);
    
    NSString *message = [NSString stringWithFormat:@"Chwarae yn ôl (average: %f, peak: %f)", averageDecibelPowerLevel, peakDecibelPowerLevel];
    
    [self startRecordingStatusTimerWithString:message];//@"Chwarae yn ôl…"];
    
}


-(BOOL) gotoNextPrompt {
    
    [prompts promptHasBeenRecorded:self.currentPrompt];
    self.currentPrompt = [prompts getNextPromptToRecord];
    
    if (self.currentPrompt==nil) {
        
        self.lblOutletNextPrompt.text=@"Dim byd ar ôl";
        currentRecordingStatus = RECORDING_SESSION_END;
        [self btnMoveToNextRecordingState:self];
        return NO;
        
    } else {
        NSString* displayedPrompt=[self.currentPrompt.text stringByReplacingOccurrencesOfString:@" " withString:@"  "];
        
        self.lblOutletNextPrompt.text=displayedPrompt;
    }
    
    return YES;
}


//If user does not do anything by the end of the sound go to secondWindow
- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) player
                        successfully: (BOOL) flag {
    
    currentRecordingStatus=RECORDING_LISTENING_END;
    [self removeRecordingStatus];
    [self btnMoveToNextRecordingState:self];
    
}


#pragma mark Recording label animations

#define kStatusFlashTime 0.6
-(void) startRecordingStatusTimerWithString:(NSString *)string {
    if (!self.lblOutletRecordingStatusTimer) {
        self.lblOutletRecordingStatus.hidden = NO;
        self.lblOutletRecordingStatus.alpha = 1;
        [self setRecordStatusText:string];
        self.lblOutletRecordingStatusTimer=[NSTimer scheduledTimerWithTimeInterval:kStatusFlashTime
                                                                            target:self
                                                                          selector:@selector(toggleLabelRecordingStatus)
                                                                          userInfo:nil
                                                                           repeats:YES];
    }

}

- (void)toggleLabelRecordingStatus {
    [UIView animateWithDuration:kStatusFlashTime animations:^{
        self.lblOutletRecordingStatus.alpha = !self.lblOutletRecordingStatus.alpha;
    }];
}


- (void)removeRecordingStatus {
    [self.lblOutletRecordingStatusTimer invalidate];
    self.lblOutletRecordingStatusTimer = nil;
    [self.lblOutletRecordingStatus setHidden:YES];
}

#pragma mark NSURLConnectionDelegate methods
// Used to keep track of the progress bar

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
    if (![self.currentUploadConnections containsObject:connection]) {
        [self.currentUploadConnections addObject:connection];
    }
    self.uploadProgressBar.hidden = NO;
    self.lblUploadingFilesInfo.text = [NSString stringWithFormat:@"Llwytho i fyny ffeil 1 o %lu…", (unsigned long)[self.currentUploadConnections count]];
    self.lblUploadingFilesInfo.hidden = NO;
    if (connection == [self.currentUploadConnections firstObject]) {
        self.uploadProgressBar.hidden = NO;
        CGFloat t = (CGFloat)totalBytesExpectedToWrite;
        self.uploadProgressBar.progress += bytesWritten/t;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self removeConnection:connection];
}

- (void)removeConnection:(NSURLConnection *)connection {
    [self.currentUploadConnections removeObject:connection];
    if ([self.currentUploadConnections count] == 0) {
        self.lblUploadingFilesInfo.hidden = YES;
        self.uploadProgressBar.hidden = YES;
        self.uploadProgressBar.progress = 0;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self removeConnection:connection];
}


-(void)handleInternetReachable:(NSNotification *)notification {
    
    // try to upload any outstanding wav files.
    [[UTIDataStore sharedDataStore] http_uploadOutstandingAudio:uid];
    
    [self.lblOutletNextPrompt setEnabled:YES];
    [self.lblOutletRecordingStatus setEnabled:YES];
    [self.btnOutletMoveToNextRecordingState setEnabled:YES];
    [self.btnOutletRedoRecording setEnabled:YES];
    [self.lblOutletProfileName setEnabled:YES];
    [self.lblOutletSessionProgress setEnabled:YES];
    
}


-(void)handleInternetUnreachable:(NSNotification *)notification {
    
    [self.lblOutletNextPrompt setEnabled:NO];
    [self.lblOutletRecordingStatus setEnabled:NO];
    [self.btnOutletMoveToNextRecordingState setEnabled:NO];
    [self.btnOutletRedoRecording setEnabled:NO];
    [self.lblOutletProfileName setEnabled:NO];
    [self.lblOutletSessionProgress setEnabled:NO];
    
}


/*
-(void)handlePaldaruoServerApplicationError:(NSNotification *)notification {
    [self.lblOutletNextPrompt setEnabled:NO];
    [self.lblOutletRecordingStatus setEnabled:NO];
    [self.btnOutletMoveToNextRecordingState setEnabled:NO];
    [self.btnOutletRedoRecording setEnabled:NO];
    [self.lblOutletProfileName setEnabled:NO];
    [self.lblOutletSessionProgress setEnabled:NO];
}
*/

@end

