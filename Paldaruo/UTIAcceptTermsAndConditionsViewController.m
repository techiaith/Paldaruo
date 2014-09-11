//
//  UTIAcceptTermsAndConditionsViewController.m
//  Paldaruo
//
//  Created by Apiau on 05/03/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIAcceptTermsAndConditionsViewController.h"
#import "UTIReachability.h"
#import "DejalActivityView.h"

@interface UTIAcceptTermsAndConditionsViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webViewOutletTermsAndConditionsText;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletAccept;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletReject;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

- (IBAction)unwindToSegue:(id)sender;

@end

@implementation UTIAcceptTermsAndConditionsViewController


-(void)viewWillAppear:(BOOL)animated {
    
    /*
    [self.btnOutletAccept setHidden:NO];
    [self.btnOutletReject setHidden:NO];
    
    // Disable the buttons until the T&Cs have fully loaded
    [self.btnOutletAccept setEnabled:NO];
    [self.btnOutletReject setEnabled:NO];
    */
    [self.backButton setHidden:YES];
    
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"telerau" withExtension:@"html"];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [self.webViewOutletTermsAndConditionsText loadRequest:requestObj];
    self.webViewOutletTermsAndConditionsText.delegate = self;
    
}

- (IBAction)unwindToSegue:(id)sender {
    
    if (sender == self.backButton) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([[UTIReachability instance] isPaldaruoServerReachable]){
        return YES;
    } else {
        
        if ([identifier isEqual:@"segue_NewProfile"])
        {
            [[UTIReachability instance] showAppServerUnreachableAlert];
            return NO;
        } else {
            return YES;
        }
        
    }
    
}

@end
