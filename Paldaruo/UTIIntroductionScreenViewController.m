//
//  UTIIntroductionScreenViewController.m
//  Paldaruo
//
//  Created by Apiau on 25/02/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIIntroductionScreenViewController.h"

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
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {

    if ([[UTIReachability instance] isPaldaruoServerReachable]){
        return YES;
    } else {
        if ([identifier isEqual:@"segue_ProfileSelect"])
        {
            [[UTIReachability instance] showAppServerUnreachableAlert];
            return NO;
        } else {
            return YES;
        }
    }

}

@end
