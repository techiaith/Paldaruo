//
//  UTIIntroductionScreenViewController.m
//  Paldaruo
//
//  Created by Apiau on 25/02/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIIntroductionScreenViewController.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)

@interface UTIIntroductionScreenViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageOutletBangorLogo;
@property (weak, nonatomic) IBOutlet UILabel *labelOutletUnedTechnolegauIaith;
@property (weak, nonatomic) IBOutlet UILabel *labelOutletCanolfanBedwyr;
@property (weak, nonatomic) IBOutlet UIImageView *imageOutletTechiaithLogo;
@property (weak, nonatomic) IBOutlet UIImageView *imageOutletPaldaruoIcon;

@property (weak, nonatomic) IBOutlet UIButton *btnOutletStart;

@end

@implementation UTIIntroductionScreenViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInternetReachable:)
                                                 name:@"InternetReachable"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInternetUnreachable:)
                                                 name:@"InternetUnreachable"
                                               object:nil];
    
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    /*
    if (IS_IPHONE_5==YES){
        
        // 4 inch
        
        // Bangor logo
        //
        CGRect newBangorLogoFrame = CGRectMake(250, 495, 65, 50);
        self.imageOutletBangorLogo.frame = newBangorLogoFrame;
        
        CGRect newTechiaithLogoFrame = CGRectMake(15, 490, 50, 65);
        self.imageOutletTechiaithLogo.frame = newTechiaithLogoFrame;
        
        CGRect newTechIaithLabelFrame = CGRectMake(65, 505, 135, 20);
        self.labelOutletUnedTechnolegauIaith.frame=newTechIaithLabelFrame;
        
        CGRect newCanolfanBedwyrLabelFrame = CGRectMake(65, 520, 110, 20);
        self.labelOutletCanolfanBedwyr.frame = newCanolfanBedwyrLabelFrame;
        
        CGRect paldaruoIcon = self.imageOutletPaldaruoIcon.frame;
        
        CGRect newPaldaruoIconFrame = CGRectMake(paldaruoIcon.origin.x,
                       paldaruoIcon.origin.y,
                       50,50);
        
        self.imageOutletPaldaruoIcon.frame=newPaldaruoIconFrame;
        
    } else {
        
        // 3.5 inch
        
        // Bangor logo
        //
        CGRect newBangorLogoFrame = CGRectMake(250, 420, 65, 50);
        self.imageOutletBangorLogo.frame = newBangorLogoFrame;
        
        CGRect newTechiaithLogoFrame = CGRectMake(15, 415, 50, 65);
        self.imageOutletTechiaithLogo.frame = newTechiaithLogoFrame;

        CGRect newTechIaithLabelFrame = CGRectMake(65, 430, 135, 20);
        self.labelOutletUnedTechnolegauIaith.frame=newTechIaithLabelFrame;
        
        CGRect newCanolfanBedwyrLableFrame = CGRectMake(65, 445, 110, 20);
        self.labelOutletCanolfanBedwyr.frame = newCanolfanBedwyrLableFrame;
        
    }
     */
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)handleInternetReachable:(NSNotification *)notification {
    [self.btnOutletStart setEnabled:YES];
}

-(void)handleInternetUnreachable:(NSNotification *)notification {
    [self.btnOutletStart setEnabled:NO];
}

@end
