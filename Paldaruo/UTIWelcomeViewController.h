//
//  UTIWelcomeViewController.h
//  Paldaruo
//
//  Created by Apiau on 20/01/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UTIWelcomeViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *noProfilesLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *picklistOutletExistingUsers;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletStartSession;

- (IBAction)btnStartSession:(id)sender;
- (IBAction)btnCreateNewProfile:(id)sender;


@end
