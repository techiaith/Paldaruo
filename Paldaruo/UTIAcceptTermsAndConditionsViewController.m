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

@end

@implementation UTIAcceptTermsAndConditionsViewController

-(void)viewWillAppear:(BOOL)animated {
    [self.btnOutletAccept setHidden:NO];
    [self.btnOutletReject setHidden:NO];
    [self.backButton setHidden:YES];
    NSString *urlAdress=@"http://paldaruo.techiaith.bangor.ac.uk/telerau_v1.0.html";
    
    NSURL *url = [NSURL URLWithString:urlAdress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [DejalActivityView activityViewForView:self.webViewOutletTermsAndConditionsText withLabel:nil];
    [self.webViewOutletTermsAndConditionsText loadRequest:requestObj];
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [DejalActivityView removeView];
#ifdef DEBUG
    return;
#endif
    [self.btnOutletAccept setHidden:YES];
    [self.btnOutletReject setHidden:YES];
    [self.backButton setHidden:NO];
    [self.webViewOutletTermsAndConditionsText loadHTMLString:@"<p style='color:#ff0000;font-family:helvetica;text-align:center;vertical-align:middle;padding-top:20px'>Mae angen cysylltiad i'r we er mwyn parhau</p>" baseURL:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
