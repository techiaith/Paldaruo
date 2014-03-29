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
    NSInteger userIndex=[[UTIDataStore sharedDataStore] activeUserIndex];
    NSString *uid=[[[[UTIDataStore sharedDataStore] allProfilesArray] objectAtIndex:userIndex] objectForKey:@"uid"];
    
    [self.labelOutletMyUID setText:uid];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
