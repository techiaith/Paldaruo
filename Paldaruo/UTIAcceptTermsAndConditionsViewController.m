//
//  UTIAcceptTermsAndConditionsViewController.m
//  Paldaruo
//
//  Created by Apiau on 05/03/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIAcceptTermsAndConditionsViewController.h"

@interface UTIAcceptTermsAndConditionsViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webViewOutletTermsAndConditionsText;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Do any additional setup after loading the view.
    NSString *urlAdress=@"http://paldaruo.techiaith.bangor.ac.uk/telerau_v1.0.html";
    
    NSURL *url = [NSURL URLWithString:urlAdress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [self.webViewOutletTermsAndConditionsText loadRequest:requestObj];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
