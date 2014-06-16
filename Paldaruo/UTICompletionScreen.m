//
//  UTICompletionScreen.m
//  Paldaruo
//
//  Created by Dewi Bryn Jones on 16.6.2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTICompletionScreen.h"
#import "UTIDataStore.h"

@interface UTICompletionScreen ()

@property (weak, nonatomic) IBOutlet UILabel *lblOutletContributorName;
- (IBAction)btnActionReturnToHomeScreen:(id)sender;

@end

@implementation UTICompletionScreen

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
    
    NSString* userName=[[UTIDataStore sharedDataStore] activeUser].name;
    [self.lblOutletContributorName setText:userName];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnActionReturnToHomeScreen:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
