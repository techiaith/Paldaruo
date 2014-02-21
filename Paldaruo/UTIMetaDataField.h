//
//  UTIMetaDataField.h
//  Paldaruo
//
//  Created by Apiau on 03/02/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UTIMetaDataField : NSObject
{

    @public

        NSString *fieldId;
        NSString *title;
        NSString *question;
        NSString *explanation;
    
        BOOL    isText;
    
        // if isText==false
        NSMutableArray  *optionKey;
        NSMutableArray  *optionValue;
        NSInteger selectedOptionIndex;
    
        // if isText==true
        NSString *value;
    
}

-(void) addOptionWithId: (NSString*)idValue text:(NSString*)textValue;

-(void) setSelectedOptionWithIndex: (NSInteger)selectedIndex;
-(NSInteger) getSelectedOptionIndex;

-(void) setTextValue:(NSString *) textValue;
-(NSString *) getTextValue;

-(NSString *) getValue;
-(NSString *) getKey;

@end
