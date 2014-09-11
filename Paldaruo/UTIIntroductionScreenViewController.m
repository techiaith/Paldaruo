//
//  UTIIntroductionScreenViewController.m
//  Paldaruo
//
//  Created by Apiau on 25/02/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIIntroductionScreenViewController.h"

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
