//
//  UTIAboutMyDataViewController.m
//  Paldaruo
//
//  Created by Apiau on 13/03/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIAboutMyDataViewController.h"


@interface UTIAboutMyDataViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelOutletMyUID;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletStartSession;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletTestBackgroundSound;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletUnwindToHome;

@property (strong, nonatomic) UTIAudioRecorderPlayer *audio;

- (IBAction)btnActionTestBackgroundSound:(id)sender;
- (IBAction)btnActionStartSession:(id)sender;
- (IBAction)btnActionUnwindToHome:(id)sender;


@end

@implementation UTIAboutMyDataViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    NSString *uid = [[UTIDataStore sharedDataStore] activeUser].uid;
    [self.labelOutletMyUID setText:uid];
    
    self.audio = [[UTIAudioRecorderPlayer alloc]init];
    self.audio.delegate=self;
    
    [self.btnOutletStartSession setEnabled:NO];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([[UTIReachability instance] isPaldaruoServerReachable]){
        return YES;
    } else {
        
        if ([identifier isEqual:@"segue_StartRecording"])
        {
            [[UTIReachability instance] showAppServerUnreachableAlert];
            return NO;
        } else {
            return YES;
        }
        
    }
    
}


#define BACKGROUND_TEST_DURATION 5.0

- (IBAction)btnActionTestBackgroundSound:(id)sender {
    
    [self.btnOutletTestBackgroundSound setEnabled:NO];
    [self.audio recordAudio];
    [self.btnOutletUnwindToHome setEnabled:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:BACKGROUND_TEST_DURATION
                                     target:self
                                   selector:@selector(testbackgroundSoundDidComplete)
                                   userInfo:nil
                                    repeats:NO];
    
}

- (IBAction)btnActionStartSession:(id)sender {
    NSString *uid = [[UTIDataStore sharedDataStore] activeUser].uid;
    
    [[UTIDataStore sharedDataStore] http_uploadSilenceAudioFile:uid
                                                         sender:self];
    
}


-(IBAction)btnActionUnwindToHome:(id)sender{
      [self.navigationController popToRootViewControllerAnimated:YES];
}


-(void) testbackgroundSoundDidComplete{
    
    [self.audio stopRecording];
    [self.btnOutletTestBackgroundSound setEnabled:YES];
    [self.btnOutletStartSession setEnabled:YES];
    [self.btnOutletUnwindToHome setEnabled:YES];
    
    NSString *message;
    
    if ([self.audio areLevelsTooQuiet]){
        message = [NSString stringWithFormat:@"\nGwych! Mae'r sŵn cefndir yn ddigon distaw ar gyfer recordio. \n\n Pwyswch ar Ymlaen i ddechrau recordio."];//,[self.audio getPeakPower]];
    } else {
        message = [NSString stringWithFormat:@"\nO diar. Mae gormod o sŵn cefndir i ni dderbyn recordiadau da. \n\n Symudwch i fan distawach cyn profi eto, neu pwyswch Ymlaen i recordio beth bynnag."];//,[self.audio getPeakPower]];
    }
    //@PRAWF
    UIAlertView *messageView = [[UIAlertView alloc] initWithTitle:@"Profi lefelau sŵn cefndir"
                                                          message:message
                                                         delegate:nil
                                                cancelButtonTitle:@"Iawn"
                                                otherButtonTitles:nil];

    [messageView show];
        
}

-(void) audioDidFinishPlaying:(BOOL)successful{
    // do nothing
}

-(void) audioRecordingDidTimeout {
    // do nothing
}


- (void)connection:(NSURLConnection *)connection
            didSendBodyData:(NSInteger)bytesWritten
          totalBytesWritten:(NSInteger)totalBytesWritten
  totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
}


- (void)removeConnection:(NSURLConnection *)connection {
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}


@end
