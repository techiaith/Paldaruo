//
//  UTINewProfileViewController.m
//  Paldaruo
//
//  Created by Apiau on 31/01/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTINewProfileViewController.h"
#import "UTIDataStore.h"

@interface UTINewProfileViewController () 

@property (weak, nonatomic) IBOutlet UIButton *btnOutletCreateUser;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletStartSession;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletNextQuestion;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletPreviousQuestion;

@property (weak, nonatomic) IBOutlet UILabel *lblOutletNewProfileNameFieldDescription;

@property (weak, nonatomic) IBOutlet UILabel *lblOutletMetaDataField_Title;
@property (weak, nonatomic) IBOutlet UILabel *lblOutletMetaDataField_Question;
@property (weak, nonatomic) IBOutlet UILabel *lblOutletMetaDataField_Explanation;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerViewOutletMetaDataOption;
@property (weak, nonatomic) IBOutlet UITextField *textFieldOutletMetaDataFreeText;

- (IBAction)btnActionNextQuestion:(id)sender;
- (IBAction)btnActionCreateUser:(id)sender;
- (IBAction)btnActionStartSession:(id)sender;
- (IBAction)btnActionPreviousQuestion:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *txtBoxNewProfileName;

@end

@implementation UTINewProfileViewController

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
    [self.btnOutletStartSession setHidden:YES];
    
    currentMetaDataFieldIndex=0;
    
    [self.lblOutletMetaDataField_Title setHidden:YES];
    [self.lblOutletMetaDataField_Question setHidden:YES];
    [self.lblOutletMetaDataField_Explanation setHidden:YES];
    [self.pickerViewOutletMetaDataOption setHidden:YES];
    [self.textFieldOutletMetaDataFreeText setHidden:YES];
    
    self.textFieldOutletMetaDataFreeText.delegate = self;
    
    self.pickerViewOutletMetaDataOption.delegate = self;
    self.pickerViewOutletMetaDataOption.dataSource = self;
    self.pickerViewOutletMetaDataOption.showsSelectionIndicator=YES;

    // first form presentation is the text box for the profilename
    // select the text box and show the keyboard.
    
    [self.txtBoxNewProfileName becomeFirstResponder];
    
    [self.btnOutletNextQuestion setHidden:YES];
    [self.btnOutletPreviousQuestion setHidden:YES];
    
    //[self.lblOutletMetaDataField_Explanation sizeToFit];
    
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
}


-(BOOL) textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.textFieldOutletMetaDataFreeText) {
        [theTextField resignFirstResponder];
    }
    return YES;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSArray *localCopyMetaDataFields=[[UTIDataStore sharedDataStore] metaDataFields];
    
    if (localCopyMetaDataFields.count>0) {
        UTIMetaDataField *localCopyMetaDataField=[localCopyMetaDataFields objectAtIndex:currentMetaDataFieldIndex];
        return localCopyMetaDataField->optionKey.count;
    } else {
        return 0;
    }
    
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSArray *localCopyMetaDataFields=[[UTIDataStore sharedDataStore] metaDataFields];
    
    if (localCopyMetaDataFields.count>0) {
        UTIMetaDataField *localCopyMetaDataField=[localCopyMetaDataFields objectAtIndex:currentMetaDataFieldIndex];

        return [localCopyMetaDataField->optionValue objectAtIndex:row];
    }
    else {
        return Nil;
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnActionNextQuestion:(id)sender {
    [self goToNextMetaDataField:YES];
}


- (IBAction)btnActionCreateUser:(id)sender {
    
    NSString *newUserName=[_txtBoxNewProfileName text];
    
    if ([newUserName length]>0){
        
        // The new user (if created) is automatically made the active user
        UTIUser *user = [[UTIDataStore sharedDataStore] addNewUser:newUserName];
    
        if (user && user.uid) {
            [[self btnOutletCreateUser] setUserInteractionEnabled:NO];
            [[self btnOutletCreateUser]setHidden:YES];
            
            [[self txtBoxNewProfileName] setHidden:YES];
            [[self lblOutletNewProfileNameFieldDescription] setHidden:YES];
            
            [[UTIDataStore sharedDataStore] http_getMetadata:user.uid];
            
            [self.lblOutletMetaDataField_Title setHidden:NO];
            [self.lblOutletMetaDataField_Question setHidden:NO];
            [self.lblOutletMetaDataField_Explanation setHidden:NO];
            [self.pickerViewOutletMetaDataOption setHidden:NO];
            [self.btnOutletNextQuestion setHidden:NO];
        } else {
            // display some kind of error
            NSLog(@"OOPS");
        }
    }
}


- (IBAction)btnActionStartSession:(id)sender {
    
    NSString *uid=[[UTIDataStore sharedDataStore] activeUser].uid;
    
    [[UTIDataStore sharedDataStore] http_saveMetadata:uid];
    
}


- (IBAction)btnActionPreviousQuestion:(id)sender {
    [self goToPreviousMetaDataField];
}


-(void) goToPreviousMetaDataField {

    if (currentMetaDataFieldIndex>0)
        currentMetaDataFieldIndex=currentMetaDataFieldIndex-1;
    else
        return;
    
    NSArray *localCopyMetaDataFields=[[UTIDataStore sharedDataStore] metaDataFields];
    UTIMetaDataField *localCopyCurrentMetaDataField=[localCopyMetaDataFields objectAtIndex:currentMetaDataFieldIndex];
    
    if (localCopyCurrentMetaDataField->isText==YES){
        
        [self.textFieldOutletMetaDataFreeText setText:[localCopyCurrentMetaDataField getTextValue]];
        
    } else {
        
        NSInteger selected=[localCopyCurrentMetaDataField getSelectedOptionIndex];
        [self.pickerViewOutletMetaDataOption selectRow:selected inComponent:0 animated:NO];
        
    }
    
    
    [self showFormForCurrentMetaDataField];
    

}


-(void) goToNextMetaDataField:(BOOL) increment {

    //
    NSArray *localCopyMetaDataFields=[[UTIDataStore sharedDataStore] metaDataFields];
    
    //
    if (increment==YES){
        
        UTIMetaDataField *localCopyCurrentMetaDataField=[localCopyMetaDataFields objectAtIndex:currentMetaDataFieldIndex];
        
        if (localCopyCurrentMetaDataField->isText==YES){
            [localCopyCurrentMetaDataField setTextValue:[self.textFieldOutletMetaDataFreeText text]];
            [self.textFieldOutletMetaDataFreeText setText:@""];
        } else {
            NSInteger row = [self.pickerViewOutletMetaDataOption selectedRowInComponent:0];
            [localCopyCurrentMetaDataField setSelectedOptionWithIndex:row];
            //[self.pickerViewOutletMetaDataOption selectRow:0 inComponent:0 animated:NO];
        }
        currentMetaDataFieldIndex++;
        
    } else {
        
        [self.view endEditing:YES];
        
    }
    
    [self showFormForCurrentMetaDataField];
    
}

-(void) showFormForCurrentMetaDataField
{
    //
    NSArray *localCopyMetaDataFields=[[UTIDataStore sharedDataStore] metaDataFields];

    //
    if (currentMetaDataFieldIndex < localCopyMetaDataFields.count) {
        
        //
        UTIMetaDataField *localCopyNextMetaDataField=[localCopyMetaDataFields objectAtIndex:currentMetaDataFieldIndex];
        
        [self.lblOutletMetaDataField_Title setText:localCopyNextMetaDataField->title];
        [self.lblOutletMetaDataField_Question setText:localCopyNextMetaDataField->question];
        [self.lblOutletMetaDataField_Explanation setText:localCopyNextMetaDataField->explanation];
        
        [self.lblOutletMetaDataField_Title setHidden:NO];
        [self.lblOutletMetaDataField_Question setHidden:NO];
        [self.lblOutletMetaDataField_Explanation setHidden:NO];
        
        //
        if (localCopyNextMetaDataField->isText==YES){
            
            [self.pickerViewOutletMetaDataOption setHidden:YES];
            
            [self.textFieldOutletMetaDataFreeText setHidden:NO];
            [self.textFieldOutletMetaDataFreeText becomeFirstResponder];
            
            
        } else {
            
            [self.view endEditing:YES];
            [self.textFieldOutletMetaDataFreeText setHidden:YES];
            
            [self.pickerViewOutletMetaDataOption setHidden:NO];
            [self.pickerViewOutletMetaDataOption reloadAllComponents];
            
        }
        
        //
        if (currentMetaDataFieldIndex<1)
            [self.btnOutletPreviousQuestion setHidden:YES];
        else
            [self.btnOutletPreviousQuestion setHidden:NO];
        
        [self.btnOutletStartSession setHidden:YES];
        [self.btnOutletNextQuestion setHidden:NO];
        
    } else {
        
        [self.btnOutletNextQuestion setHidden:YES];
        //[self.btnOutletPreviousQuestion setHidden:YES];
        
        [self.lblOutletMetaDataField_Title setHidden:YES];
        [self.lblOutletMetaDataField_Question setHidden:YES];
        [self.lblOutletMetaDataField_Explanation setHidden:YES];
        [self.textFieldOutletMetaDataFreeText setHidden:YES];
        [self.pickerViewOutletMetaDataOption setHidden:YES];
        
        [self.btnOutletStartSession setHidden:NO];
        
    }

}


@end
