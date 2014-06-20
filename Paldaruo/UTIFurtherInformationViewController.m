//
//  UTIFurtherInformationViewController.m
//  Paldaruo
//
//  Created by Apiau on 20/02/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIFurtherInformationViewController.h"
#import <MediaPlayer/MediaPlayer.h>

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)

@interface UTIFurtherInformationViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageOutletBangorLogo;
@property (weak, nonatomic) IBOutlet UILabel *labelOutletCanolfanBedwyr;
@property (weak, nonatomic) IBOutlet UILabel *labelOutletUnedTechnolegauIaith;
@property (weak, nonatomic) IBOutlet UIImageView *imageOutletTechiaithLogo;
@property (weak, nonatomic) IBOutlet UIImageView *imageOutletPaldaruoIcon;
@property (weak, nonatomic) IBOutlet UIWebView *uiWebViewOutletContent;

- (IBAction)btnVideoPlay:(id)sender;

@property (strong, nonatomic) MPMoviePlayerViewController *moviePlayerController;


- (IBAction)unwindToHome:(id)sender;

@end


@implementation UTIFurtherInformationViewController


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
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"about" withExtension:@"html"];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [self.uiWebViewOutletContent loadRequest:requestObj];
    self.uiWebViewOutletContent.delegate = self;

}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
    
}

- (IBAction)unwindToHome:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



- (IBAction)btnVideoPlay:(id)sender {
    
    
    if ([[UTIReachability instance] isPaldaruoServerReachable]){
        
        [YTVimeoExtractor fetchVideoURLFromURL:@"https://vimeo.com/98728429"
                                       quality:YTVimeoVideoQualityMedium
                             completionHandler:^(NSURL *videoURL, NSError *error, YTVimeoVideoQuality quality)
         {
             if (error) {
                 
                 // handle error
                 NSLog(@"Video URL: %@", [videoURL absoluteString]);
                 
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Fideo Paldaruo"
                                                                 message: @"Mae problem gyda'r wasanaeth fideo."
                                                                delegate: nil
                                                       cancelButtonTitle: @"Iawn"
                                                       otherButtonTitles: nil];
                 [alert show];

                 
             } else {
                 // run player
                 self.moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
                 [self.moviePlayerController.moviePlayer prepareToPlay];
                 [self presentViewController:self.moviePlayerController animated:YES completion:nil];
             }
         }];
        
    } else {
        [[UTIReachability instance] showAppServerUnreachableAlert];
    }
    
    /*
    //NSURL *movieURL = [[NSBundle mainBundle] URLForResource:@"sarah_yn_paldaruo_llai" withExtension:@".m4v"];
    NSURL *movieURL = [[NSBundle mainBundle] URLForResource:@"paldaruo_20140620_480_ipad" withExtension:@".m4v"];
    _moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];

    
    // Remove the movie player view controller from the "playback did finish" notification observers
    [[NSNotificationCenter defaultCenter] removeObserver:_moviePlayerController
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:_moviePlayerController.moviePlayer];
    
    // Register this class as an observer instead
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_moviePlayerController.moviePlayer];
    
    
    // Set the modal transition style of your choice
    _moviePlayerController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    // Present the movie player view controller
    [self presentViewController:_moviePlayerController animated:YES completion:Nil];
    
    // Start playback
    [_moviePlayerController.moviePlayer prepareToPlay];
    [_moviePlayerController.moviePlayer play];
    */
    
}

- (void)movieFinishedCallback:(NSNotification*)aNotification
{
    // Obtain the reason why the movie playback finished
    NSNumber *finishReason = [[aNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    // Dismiss the view controller ONLY when the reason is not "playback ended"
    if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded)
    {
        MPMoviePlayerController *moviePlayer = [aNotification object];
        
        // Remove this class from the observers
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:moviePlayer];
        
        // Dismiss the view controller
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
