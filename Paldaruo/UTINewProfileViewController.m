//
//  UTINewProfileViewController.m
//  Paldaruo
//
//  Created by Apiau on 31/01/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTINewProfileViewController.h"
#import "UTIDataStore.h"
#import "DejalActivityView.h"
#import "Reachability.h"

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
@property (weak, nonatomic) IBOutlet UILabel *lblOutletError;

@property (weak, nonatomic) IBOutlet UITextField *txtBoxNewProfileName;

- (IBAction)btnActionNextQuestion:(id)sender;
- (IBAction)btnActionCreateUser:(id)sender;
- (IBAction)btnActionStartSession:(id)sender;
- (IBAction)btnActionPreviousQuestion:(id)sender;


@end

@implementation UTINewProfileViewController

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
        return localCopyMetaDataField.optionKey.count;
    } else {
        return 0;
    }
    
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSArray *localCopyMetaDataFields=[[UTIDataStore sharedDataStore] metaDataFields];
    
    if (localCopyMetaDataFields.count>0) {
        UTIMetaDataField *localCopyMetaDataField=[localCopyMetaDataFields objectAtIndex:currentMetaDataFieldIndex];
        
        return [localCopyMetaDataField.optionValue objectAtIndex:row];
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
    self.lblOutletError.hidden = YES;
    NSString *newUserName=[_txtBoxNewProfileName text];
    
    NSString __block *errorText = nil;
    if ([newUserName length] > 0){
        // The new user (if created) is automatically made the active user
        [self.txtBoxNewProfileName resignFirstResponder];
        [[UTIDataStore sharedDataStore] http_createUser_completionBlock:^(NSData *data, NSError *error) {
            [DejalBezelActivityView removeView];
            NSDictionary *json = nil;
            if (data) {
                json = [NSJSONSerialization JSONObjectWithData:data
                                                       options:kNilOptions
                                                         error:nil];
            }
            
            if (!json) {
                errorText = @"Problem gyda'r gweinydd";
            } else if (error) {
                switch (error.code) {
                    case -1001: {
                        errorText = @"Terfyn Amser Gweinydd";
                        break;
                    }
                    default: {
                        errorText = error.localizedDescription;
                        break;
                    }
                }
            } else if (!data) {
                errorText = @"Problem gyda'r gweinydd";
            }
            
            if (errorText) {
                [self showErrorText:errorText];
                return;
            }
            NSDictionary *jsonResponse = json[@"response"];
            NSString *uid = jsonResponse[@"uid"];
            
            if (uid) {
                [[UTIDataStore sharedDataStore] addNewUser:newUserName uid:uid];
                [[UTIDataStore sharedDataStore] http_getMetadata:uid sender:self];
            }
        }];
        [DejalBezelActivityView activityViewForView:self.view withLabel:@"Llwytho…"];
        
    } else {
        errorText = @"Rhaid rhoi enw i'r proffil";
    }
    
    if (errorText) {
        [self showErrorText:errorText];
    }
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
    
    if (localCopyCurrentMetaDataField.isText==YES){
        
        self.textFieldOutletMetaDataFreeText.text = localCopyCurrentMetaDataField.value;
        
    } else {
        
        NSInteger selected = localCopyCurrentMetaDataField.selectedOptionIndex;
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
        
        if (localCopyCurrentMetaDataField.isText==YES){
            localCopyCurrentMetaDataField.value = [self.textFieldOutletMetaDataFreeText text];
            [self.textFieldOutletMetaDataFreeText setText:@""];
        } else {
            NSInteger row = [self.pickerViewOutletMetaDataOption selectedRowInComponent:0];
            localCopyCurrentMetaDataField.selectedOptionIndex = row;
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
        
        [self.lblOutletMetaDataField_Title setText:localCopyNextMetaDataField.title];
        [self.lblOutletMetaDataField_Question setText:localCopyNextMetaDataField.question];
        [self.lblOutletMetaDataField_Explanation setText:localCopyNextMetaDataField.explanation];
        
        [self.lblOutletMetaDataField_Title setHidden:NO];
        [self.lblOutletMetaDataField_Question setHidden:NO];
        [self.lblOutletMetaDataField_Explanation setHidden:NO];
        
        //
        if (localCopyNextMetaDataField.isText==YES){
            
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
        
        [self.lblOutletMetaDataField_Title setHidden:YES];
        [self.lblOutletMetaDataField_Question setHidden:YES];
        [self.lblOutletMetaDataField_Explanation setHidden:YES];
        [self.textFieldOutletMetaDataFreeText setHidden:YES];
        [self.pickerViewOutletMetaDataOption setHidden:YES];
        
        NSString *uid = [[UTIDataStore sharedDataStore] activeUser].uid;
        
        BOOL success = [[UTIDataStore sharedDataStore] http_saveMetadata:uid];
        
        if (success){
            [self.btnOutletStartSession setHidden:NO];
            [self.btnOutletPreviousQuestion setHidden:YES];
        }
        
    }
    
}

#pragma mark NSURLConnectionDelegate methods

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    NSArray *prevViewControllers = [self.navigationController viewControllers];
//    if ([prevViewControllers count] > 2) {
//        [self.navigationController popToViewController:[prevViewControllers objectAtIndex:1] animated:YES];
//    } else {
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self showError:error];
}

#pragma mark UTIErrorReporter protocol

- (void)showError:(NSError *)error {
    [self showErrorText:error.localizedDescription];
}

- (void)showErrorText:(NSString *)errorText {
    self.lblOutletError.text = errorText;
    self.lblOutletError.hidden = NO;
    [self.txtBoxNewProfileName becomeFirstResponder];
}

@end
