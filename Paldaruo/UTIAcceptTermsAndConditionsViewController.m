//
//  UTIAcceptTermsAndConditionsViewController.m
//  Paldaruo
//
//  Created by Apiau on 05/03/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIAcceptTermsAndConditionsViewController.h"
#import "Reachability.h"
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
    [self.btnOutletAccept setHidden:NO];
    [self.btnOutletReject setHidden:NO];
    
    // Disable the buttons until the T&Cs have fully loaded
    [self.btnOutletAccept setEnabled:NO];
    [self.btnOutletReject setEnabled:NO];

    [self.backButton setHidden:YES];
    NSString *urlAdress=@"http://paldaruo.techiaith.bangor.ac.uk/telerau_v1.0.html";
    
    NSURL *url = [NSURL URLWithString:urlAdress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [DejalActivityView activityViewForView:self.webViewOutletTermsAndConditionsText withLabel:nil];
    [self.webViewOutletTermsAndConditionsText loadRequest:requestObj];
    
}

#pragma mark WebView Delegate methods

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [DejalActivityView removeView];
#ifdef DEBUG
    [self.webViewOutletTermsAndConditionsText loadHTMLString:@"<p style='color:#ff0000;font-family:helvetica;text-align:center;vertical-align:middle;padding-top:20px'>DEBUG</p>" baseURL:nil];

    [self.btnOutletAccept setEnabled:YES];
    [self.btnOutletReject setEnabled:YES];
    return;
#endif
    
    [self.btnOutletAccept setHidden:YES];
    [self.btnOutletReject setHidden:YES];
    [self.backButton setHidden:NO];
    [self.webViewOutletTermsAndConditionsText loadHTMLString:@"<p style='color:#ff0000;font-family:helvetica;text-align:center;vertical-align:middle;padding-top:20px'>Mae angen cysylltiad i'r we er mwyn parhau</p>" baseURL:nil];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [DejalActivityView removeView];
    [self.btnOutletAccept setEnabled:YES];
    [self.btnOutletReject setEnabled:YES];
}

- (IBAction)unwindToSegue:(id)sender {
    if (sender == self.backButton) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
