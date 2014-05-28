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

-(void)viewDidLoad{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInternetReachable:)
                                                 name:@"InternetReachable"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInternetUnreachable:)
                                                 name:@"InternetUnreachable"
                                               object:nil];
    
    [UTIReachability instance];
    
}

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

- (void) dealloc {
    
    // view did load
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"InternetReachable"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"InternetUnreachable"
                                                  object:nil];
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

-(void)handleInternetReachable:(NSNotification *)notification {
    [self.btnOutletAccept setEnabled:YES];
    [self.btnOutletReject setEnabled:YES];
}


-(void)handleInternetUnreachable:(NSNotification *)notification {
    [self.btnOutletAccept setEnabled:NO];
    [self.btnOutletReject setEnabled:NO];
}


@end
