//
//  UTIViewController.m
//  Paldaruo
//
//  Created by Dewi Bryn Jones on 27.12.2013.
//  Copyright (c) 2013 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIViewController.h"
#import "UTIPromptsTracker.h"

@interface UTIViewController ()

- (IBAction)btnStopRecording:(id)sender;
- (IBAction)btnStartRecording:(id)sender;
- (IBAction)btnPlay:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnOutletPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletStartRecording;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletStopRecording;
@property (weak, nonatomic) IBOutlet UILabel *lblOutletNextPrompt;

@property (strong, nonatomic) UTIPromptsTracker *prompts;
@property (weak) UTIPrompt *currentPrompt;

@end


@implementation UTIViewController


- (void)viewDidLoad
{
    
    self.prompts = [[UTIPromptsTracker alloc] init];
    
    
    //Audio Recording Setup
    //NSURL *audioFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"audioRecording.m4a"]];
    
    NSURL *audioFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"audioRecording.wav"]];
    
    
//    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   [NSNumber numberWithFloat:44100],AVSampleRateKey,
//                                   [NSNumber numberWithInt: kAudioFormatAppleLossless],AVFormatIDKey,
//                                   [NSNumber numberWithInt: 1],AVNumberOfChannelsKey,
//                                   [NSNumber numberWithInt:AVAudioQualityMedium],AVEncoderAudioQualityKey,nil];
    
    
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
    
    self.btnOutletStartRecording.enabled=NO;
    self.btnOutletPlay.enabled=NO;
    self.btnOutletStopRecording.enabled=NO;
    
    self.uploadQueue = [[NSOperationQueue alloc] init];
    
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnStopRecording:(id)sender {
    
    // mae hwn wedi newid i'r botwm 'Nesaf >'
    [self uploadAudio];
    
    self.lblOutletNextPrompt.text=@"Cynefin y carlwm a'r cadno";
    
    self.btnOutletPlay.enabled=NO;
    self.btnOutletStopRecording.enabled=NO;
}


- (IBAction)btnStartRecording:(id)sender {
    
    if ([self.audioRecorder isRecording]){
        
        [self.audioPlayer stop];
        [self.audioRecorder stop];
        
        [_btnOutletStartRecording setTitle:@"Recordio" forState:(UIControlStateNormal) ];
        self.btnOutletPlay.enabled=YES;
        
        //NSURL *audioFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"audioRecording.m4a"]];
        
        
        NSURL *audioFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"audioRecording.wav"]];
        
        // copy the file to a new location
        
        
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:nil];

    } else {
        
        [self.audioRecorder record];
        
        [_btnOutletStartRecording setTitle:@"Gorffen" forState:(UIControlStateNormal) ];
        
        _btnOutletPlay.enabled=NO;
        _btnOutletStopRecording.enabled=NO;
    }
    
}


- (IBAction)btnPlay:(id)sender {
    
    [self.audioPlayer play];
    
    self.btnOutletStartRecording.titleLabel.text=@"Recordio";
    self.btnOutletStopRecording.enabled=YES;
    
}


-(void) uploadAudio {
    
    NSURL *audioFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"audioRecording.wav"]];
    
    NSData *file1Data = [[NSData alloc] initWithContentsOfURL:audioFileURL];
    NSString *urlString = @"http://techiaith.bangor.ac.uk/gallu/upload/upload.php";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"audioRecording.wav\"\r\n"]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:file1Data]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // send asynchronous
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:self.uploadQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [self handleUploadAudioResponse:data error:error];
     }
     
    ];
    
    // send synchronous
    //NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    //NSLog(@"Return String= %@",returnString);
    
}


-(void) handleUploadAudioResponse:(NSData *)data error:(NSError *)error {

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    //
    if ([data length] >0 && error == nil){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Llwytho i fyny"
                                                        message: @"Llwythwyd i fyny yn lwyddianus"
                                                       delegate: nil
                                              cancelButtonTitle: @"Iawn"
                                              otherButtonTitles: nil];
        [alert show];
        
    } else if ([data length] == 0 && error == nil){
        
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

-(void) downloadPrompts {
    
    NSURL *url = [NSURL URLWithString:@"http://techiaith.bangor.ac.uk/gallu/prompts-json.php"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse*r, NSData*d, NSError*e) {
        [self handleDownloadPromptsResponse:d error:e];
    }];
    
    
}

-(void) handleDownloadPromptsResponse : (NSData *) data error:(NSError *) errorData {
    
    //
    NSArray *jsonArray
        = (NSArray*)[NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingMutableContainers
                                                      error:nil];
    
    //
    if (errorData == nil) {
        
        for (int x = 0; x < jsonArray.count; x++)
        {
            
            UTIPrompt* newPrompt=[[UTIPrompt alloc] init];
            
            newPrompt->text = [[jsonArray objectAtIndex:x] objectForKey:@"text"];
            newPrompt->identifier = [[jsonArray objectAtIndex:x] objectForKey:@"identifier"];
            
            [self.prompts addPromptForRecording:newPrompt];
            
        }
        
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Llwytho i lawr"
                                                        message: @"Gwall cyffredinol"
                                                       delegate: nil
                                              cancelButtonTitle: @"Iawn"
                                              otherButtonTitles: nil];
        [alert show];
        
    }
    
}

@end

