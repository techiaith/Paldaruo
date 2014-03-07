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

@property (weak) UTIPrompt *currentPrompt;

@property (weak, nonatomic) IBOutlet UILabel *lblOutletNextPrompt;
@property (weak, nonatomic) IBOutlet UILabel *lblOutletRecordingStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletMoveToNextRecordingState;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletRedoRecording;
@property (weak, nonatomic) IBOutlet UILabel *lblOutletProfileName;
@property (weak, nonatomic) IBOutlet UILabel *lblOutletSessionProgress;

@property (strong, nonatomic) NSTimer *lblOutletRecordingStatusTimer;

@end



@implementation UTIViewController


- (void)viewDidLoad
{
    
    NSInteger userIndex=[[UTIDataStore sharedDataStore] activeUserIndex];
    uid=[[[[UTIDataStore sharedDataStore] allProfilesArray] objectAtIndex:userIndex] objectForKey:@"uid"];
    
    currentRecordingStatus=DOWNLOADING_PROMPTS;
    [self btnMoveToNextRecordingState:self];
    
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
    [self btnMoveToNextRecordingState:(self)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInternetReachable:)
                                                 name:@"InternetReachable"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInternetUnreachable:)
                                                 name:@"InternetUnreachable"
                                               object:nil];
    
    [UTIReachability instance];
    

    [super viewDidLoad];
    
}

- (void) dealloc {
    
    // view did load
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"InternetReachable"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"InternetUnreachable"
                                                  object:nil];
}

-(void) toggleLabelRecordingStatus{
    [self.lblOutletRecordingStatus setHidden:(!self.lblOutletRecordingStatus.hidden)];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnMoveToNextRecordingState:(id)sender {
    
    if (currentRecordingStatus==DOWNLOADING_PROMPTS){
        
        NSInteger userIndex=[[UTIDataStore sharedDataStore] activeUserIndex];
        
        NSString* userName=[[[[UTIDataStore sharedDataStore] allProfilesArray] objectAtIndex:userIndex] objectForKey:@"name"];
        NSString* userGreeting=[NSString stringWithFormat:@"Helo %@!", userName];
        
        [[self lblOutletProfileName] setText:userGreeting];
        
        [self.lblOutletNextPrompt setText:@"Estyn testunau i'w recordio...."];
        [self.btnOutletMoveToNextRecordingState setHidden:YES];
        [self.lblOutletRecordingStatus setHidden:YES];
        [self.lblOutletSessionProgress setHidden:YES];
        [self.btnOutletRedoRecording setHidden:YES];
        
    }
    else if (currentRecordingStatus==RECORDING_SESSION_START){
        
        [self gotoNextPrompt];
        
        [self setMoveToNextRecordStateTitle:@"Cychwyn Recordio"];
        
        [self.lblOutletSessionProgress setHidden:NO];
        [self.btnOutletMoveToNextRecordingState setHidden:NO];
        [self.btnOutletRedoRecording setHidden:YES];
        
        [self updateSessionProgress];
        
        currentRecordingStatus=RECORDING_WAIT_TO_START;
        
    }
    else if (currentRecordingStatus==RECORDING_WAIT_TO_START) {
        
        [self setMoveToNextRecordStateTitle:@"Gorffen Recordio"];
        
        //[self.lblOutletRecordingStatus setHidden:NO];
        [self.btnOutletRedoRecording setHidden:YES];
        [self startRecordingStatusTimer];
        [self setRecordStatusText:@"Yn recordio...."];
        
        [self recordAudio];
        
        currentRecordingStatus=RECORDING;
        
    } else if (currentRecordingStatus==RECORDING) {
        
        [self stopRecording];
        
        [self stopRecordingStatusTimer];
        [self.lblOutletRecordingStatus setHidden:YES];
        [self.btnOutletRedoRecording setHidden:YES];
        
        if (IS_IPHONE)
            [self setMoveToNextRecordStateTitle:@"Gwrando"];
        else
            [self setMoveToNextRecordStateTitle:@"Cliciwch i wrando ar eich recordiad"];
        
        [self setRedoRecordingText:@"Recordio eto"];
        [self.btnOutletRedoRecording setHidden:NO];
        
        currentRecordingStatus=RECORDING_FINISHED;

    } else if (currentRecordingStatus==RECORDING_FINISHED){
        
        [self setMoveToNextRecordStateTitle:@""];
        [self.btnOutletMoveToNextRecordingState setHidden:YES];
        [self.btnOutletRedoRecording setHidden:YES];
        [self playAudio];
        
        // status will change to RECORDING_LISTENING_END when audio will finish playing.
    
    } else if (currentRecordingStatus==RECORDING_LISTENING_END) {
    
        [self setMoveToNextRecordStateTitle:@"Nesaf"];
        [self.btnOutletMoveToNextRecordingState setHidden:NO];
        
        [self setRedoRecordingText:@"Recordio eto"];
        [self.btnOutletRedoRecording setHidden:NO];
        
        currentRecordingStatus=RECORDING_WAIT_TO_GOTO_NEXT;
        
    } else if (currentRecordingStatus==RECORDING_WAIT_TO_REDO_RECORDING){
        
        [self setMoveToNextRecordStateTitle:@"Cychwyn Recordio"];
        [self.lblOutletRecordingStatus setHidden:YES];
        [self.btnOutletRedoRecording setHidden:YES];
        
        currentRecordingStatus=RECORDING_WAIT_TO_START;
        
    } else if (currentRecordingStatus==RECORDING_WAIT_TO_GOTO_NEXT) {
        
        //[self uploadAudio];
        [[UTIDataStore sharedDataStore] http_uploadAudio:uid
                                              identifier:self.currentPrompt->identifier];
        
        [self gotoNextPrompt];
        
        [self updateSessionProgress];
        
        [self setMoveToNextRecordStateTitle:@"Cychwyn Recordio"];
        [self.lblOutletRecordingStatus setHidden:YES];
        [self.btnOutletRedoRecording setHidden:YES];
        
        currentRecordingStatus=RECORDING_WAIT_TO_START;
        
    } else if (currentRecordingStatus==RECORDING_SESSION_END) {
        
        [self.btnOutletMoveToNextRecordingState setHidden:YES];
        [self.btnOutletRedoRecording setHidden:YES];
        
        [self.lblOutletSessionProgress setHidden:YES];
        
        NSInteger userIndex=[[UTIDataStore sharedDataStore] activeUserIndex];
        NSString* userName=[[[[UTIDataStore sharedDataStore] allProfilesArray] objectAtIndex:userIndex] objectForKey:@"name"];
        
        NSString* userGreeting=[NSString stringWithFormat:@"Diolch yn fawr iawn am gyfrannu dy lais %@!", userName];
        
        [[self lblOutletProfileName] setText:userGreeting];

    }
    
}


- (IBAction)btnRedoRecording:(id)sender {
    currentRecordingStatus=RECORDING_WAIT_TO_REDO_RECORDING;
    [self btnMoveToNextRecordingState:(self)];
}

- (void) updateSessionProgress {
    
    
    NSString* progressString = [NSString stringWithFormat:@"%ld / %ld testun ar \xc3\xb4l",
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
    [self.audioRecorder record];
}


-(void) stopRecording {
    
    [self.audioRecorder stop];
    [self.audioPlayer stop];
    
    NSURL *audioFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"audioRecording.wav"]];
    
    // copy the file to a new location
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:nil];
    [self.audioPlayer setDelegate:self];

}


-(void) playAudio {
    
    [self.audioPlayer play];
    
}


-(void) gotoNextPrompt {
 
    [prompts promptHasBeenRecorded:self.currentPrompt];
    self.currentPrompt = [prompts getNextPromptToRecord];
 
    if (self.currentPrompt==nil) {
        
        self.lblOutletNextPrompt.text=@"Diolch yn fawr.";
        currentRecordingStatus=RECORDING_SESSION_END;
        [self btnMoveToNextRecordingState:self];
        
    } else {
        NSString* displayedPrompt=[self.currentPrompt->text stringByReplacingOccurrencesOfString:@" "
                                                                                      withString:@"  "];
        
        self.lblOutletNextPrompt.text=displayedPrompt;//self.currentPrompt->text;
    }
 
}


//If user does not do anything by the end of the sound go to secondWindow
- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) player
                        successfully: (BOOL) flag {
    
    currentRecordingStatus=RECORDING_LISTENING_END;
    [self btnMoveToNextRecordingState:self];
    
}



-(void) startRecordingStatusTimer {
    
    if (self.lblOutletRecordingStatusTimer==nil){
        
        self.lblOutletRecordingStatusTimer=[NSTimer scheduledTimerWithTimeInterval:0.6
                                                                            target:self
                                                                          selector:@selector(toggleLabelRecordingStatus)
                                                                          userInfo:nil
                                                                           repeats:YES];
    }

}


-(void) stopRecordingStatusTimer {
    
    if (self.lblOutletRecordingStatusTimer!=nil){
        [self.lblOutletRecordingStatusTimer invalidate];
        self.lblOutletRecordingStatusTimer=nil;
    }
    
}


-(void)handleInternetReachable:(NSNotification *)notification {
    
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


@end

