//
//  UTIWelcomeViewController.m
//  Paldaruo
//
//  Created by Apiau on 20/01/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIWelcomeViewController.h"
#import "UTIDataStore.h"
#import "UTIReachability.h"

@interface UTIWelcomeViewController ()

- (IBAction)btnStartSession:(id)sender;

@end

@implementation UTIWelcomeViewController

-(void) viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInternetReachable:)
                                                 name:@"InternetReachable"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInternetUnreachable:)
                                                 name:@"InternetUnreachable"
                                               object:nil];
    
    [UTIReachability instance];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    //self.dataStore=[[UTIDataStore alloc] init];

	// Do any additional setup after loading the view.
    self.picklistOutletExistingUsers.delegate = self;
    self.picklistOutletExistingUsers.dataSource = self;
    self.picklistOutletExistingUsers.showsSelectionIndicator=YES;
    
    BOOL hasNoProfiles = ([[[UTIDataStore sharedDataStore] allProfilesArray] count] == 0);
    [self.btnOutletStartSession setHidden:hasNoProfiles];
    [self.noProfilesLabel setHidden:!hasNoProfiles];
    [self.picklistOutletExistingUsers setHidden:hasNoProfiles];
    
    UTIDataStore *d = [UTIDataStore sharedDataStore];
    [d addObserver:self forKeyPath:@"allProfilesArray" options:0 context:nil];
    
    [self.btnOutletStartSession setEnabled:([d.allProfilesArray count] > 0)];
    
    [super viewWillAppear:animated];
    
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"allProfilesArray"]) {
        NSUInteger count = [((UTIDataStore *)object).allProfilesArray count];
        [self.btnOutletStartSession setEnabled:(count > 0)];
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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
    NSInteger row = [self.picklistOutletExistingUsers selectedRowInComponent:0];
    UTIUser *user = [[UTIDataStore sharedDataStore] userAtIndex:row];
    [[UTIDataStore sharedDataStore] setActiveUser:user];
    
    //[self performSegueWithIdentifier:@"id_start" sender:self];
}

-(void)handleInternetReachable:(NSNotification *)notification {
    [self.btnOutletStartSession setEnabled:YES];
    [self.btnOutletAddProfile setEnabled:YES];
}

-(void)handleInternetUnreachable:(NSNotification *)notification {
    [self.btnOutletStartSession setEnabled:NO];
    [self.btnOutletAddProfile setEnabled:NO];
}

@end
