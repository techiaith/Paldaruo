//
//  UTIAcceptTermsAndConditionsViewController.m
//  Paldaruo
//
//  Created by Apiau on 05/03/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIAcceptTermsAndConditionsViewController.h"
#import "UTIReachability.h"

@interface UTIAcceptTermsAndConditionsViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webViewOutletTermsAndConditionsText;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletAccept;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletReject;

@end

@implementation UTIAcceptTermsAndConditionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Do any additional setup after loading the view.
    NSString *urlAdress=@"http://paldaruo.techiaith.bangor.ac.uk/telerau_v1.0.html";
    
    NSURL *url = [NSURL URLWithString:urlAdress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [self.webViewOutletTermsAndConditionsText loadRequest:requestObj];
    
    
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
