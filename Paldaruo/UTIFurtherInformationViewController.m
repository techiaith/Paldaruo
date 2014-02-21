//
//  UTIFurtherInformationViewController.m
//  Paldaruo
//
//  Created by Apiau on 20/02/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIFurtherInformationViewController.h"

@interface UTIFurtherInformationViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *uiWebViewOutletContent;
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
    
	// Do any additional setup after loading the view.
    NSString *urlAdress=@"http://techiaith.bangor.ac.uk/gallu";
    
    NSURL *url = [NSURL URLWithString:urlAdress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [self.uiWebViewOutletContent loadRequest:requestObj];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
