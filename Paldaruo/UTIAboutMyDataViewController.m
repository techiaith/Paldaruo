//
//  UTIAboutMyDataViewController.m
//  Paldaruo
//
//  Created by Apiau on 13/03/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIAboutMyDataViewController.h"

@interface UTIAboutMyDataViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelOutletMyUID;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletStartSession;

@end

@implementation UTIAboutMyDataViewController

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
    NSString *uid = [[UTIDataStore sharedDataStore] activeUser].uid;
    [self.labelOutletMyUID setText:uid];
    
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
        
        if ([identifier isEqual:@"segue_StartRecording"])
        {
            [[UTIReachability instance] showAppServerUnreachableAlert];
            return NO;
        } else {
            return YES;
        }
        
    }
    
}




@end
