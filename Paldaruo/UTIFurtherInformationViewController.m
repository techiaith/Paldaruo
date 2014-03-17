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


- (void)viewDidAppear:(BOOL)animated
{
    // Do any additional setup after loading the view.
    //NSString *urlAdress=@"http://techiaith.bangor.ac.uk/gallu";
    
    
    /*
    CGRect paldaruoIcon = self.imageOutletPaldaruoIcon.frame;
    CGRect newPaldaruoIconFrame = CGRectMake(paldaruoIcon.origin.x,paldaruoIcon.origin.y,50,50);
    self.imageOutletPaldaruoIcon.frame=newPaldaruoIconFrame;
    
    if (IS_IPHONE_5==YES){
        
        // 4 inch
        
        CGRect newBangorLogoFrame = CGRectMake(250, 495, 65, 50);
        self.imageOutletBangorLogo.frame = newBangorLogoFrame;
        
        CGRect newTechiaithLogoFrame = CGRectMake(15, 490, 50, 65);
        self.imageOutletTechiaithLogo.frame = newTechiaithLogoFrame;
        
        CGRect newTechIaithLabelFrame = CGRectMake(65, 505, 135, 20);
        self.labelOutletUnedTechnolegauIaith.frame=newTechIaithLabelFrame;
        
        CGRect newCanolfanBedwyrLabelFrame = CGRectMake(65, 520, 110, 20);
        self.labelOutletCanolfanBedwyr.frame = newCanolfanBedwyrLabelFrame;
        
    } else if (IS_IPHONE==YES){
        
        // 3.5 inch
        
        CGRect newBangorLogoFrame = CGRectMake(250, 420, 65, 50);
        self.imageOutletBangorLogo.frame = newBangorLogoFrame;
        
        //CGRect newTechiaithLogoFrame = CGRectMake(15, 415, 50, 65);
        CGRect newTechiaithLogoFrame = CGRectMake(15,15, 50,65);
        self.imageOutletTechiaithLogo.frame = newTechiaithLogoFrame;
        
        CGRect newTechIaithLabelFrame = CGRectMake(65, 430, 135, 20);
        self.labelOutletUnedTechnolegauIaith.frame=newTechIaithLabelFrame;
        
        CGRect newCanolfanBedwyrLableFrame = CGRectMake(65, 445, 110, 20);
        self.labelOutletCanolfanBedwyr.frame = newCanolfanBedwyrLableFrame;
        
    }
     */
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
