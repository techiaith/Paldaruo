//
//  UTINewProfileViewController.h
//  Paldaruo
//
//  Created by Apiau on 31/01/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UTIRequest.h"
#import "UTIDataStore.h"

@interface UTINewProfileViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UTIErrorReporter, NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    int currentMetaDataFieldIndex;
}

@end


