//
//  UTIFurtherInformationViewController.m
//  Paldaruo
//
//  Created by Apiau on 20/02/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIFurtherInformationViewController.h"

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



@end
