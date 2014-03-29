//
//  UTIWelcomeViewController.m
//  Paldaruo
//
//  Created by Apiau on 20/01/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIWelcomeViewController.h"
#import "UTIDataStore.h"

@interface UTIWelcomeViewController ()

@end

@implementation UTIWelcomeViewController


- (void)viewDidLoad
{
    //self.dataStore=[[UTIDataStore alloc] init];

	// Do any additional setup after loading the view.
    self.picklistOutletExistingUsers.delegate = self;
    self.picklistOutletExistingUsers.dataSource = self;
    self.picklistOutletExistingUsers.showsSelectionIndicator=YES;
    
    if ([[[UTIDataStore sharedDataStore] allProfilesArray] count] == 0) {
        [self.btnOutletStartSession setHidden:YES];
        [self.noProfilesLabel setHidden:NO];
        [self.picklistOutletExistingUsers setHidden:YES];
    }
    
    UTIDataStore *d = [UTIDataStore sharedDataStore];
    [d addObserver:self forKeyPath:@"allProfilesArray" options:0 context:nil];
    
    [self.btnOutletStartSession setEnabled:([d.allProfilesArray count] > 0)];
    
    [super viewDidLoad];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"allProfilesArray"]) {
        NSUInteger count = [((UTIDataStore *)object).allProfilesArray count];
        [self.btnOutletStartSession setEnabled:(count > 0)];
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [[[UTIDataStore sharedDataStore] allProfilesArray] count];
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    UTIUser *user = [[UTIDataStore sharedDataStore] userAtIndex:row];
    return user.name;
}

- (IBAction)btnStartSession:(id)sender {
    
    NSInteger row;
    
    row = [self.picklistOutletExistingUsers selectedRowInComponent:0];
    UTIUser *user = [[UTIDataStore sharedDataStore] userAtIndex:row];
    [[UTIDataStore sharedDataStore] setActiveUser:user];
    
}


- (IBAction)btnCreateNewProfile:(id)sender {
    
    /*
    NSString* newUserId = [[UTIDataStore sharedDataStore] http_createUser];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Llwytho i fyny"
                                                    message: newUserId
                                                   delegate: nil
                                          cancelButtonTitle: @"Iawn"
                                          otherButtonTitles: nil];
    [alert show];
    */
}


@end
