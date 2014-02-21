//
//  UTIMetaDataField.m
//  Paldaruo
//
//  Created by Apiau on 03/02/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIMetaDataField.h"

@implementation UTIMetaDataField

-(id) init {
    
    if ((self = [super init]) != nil) {
        
        fieldId=nil;
        title=nil;
        question=nil;
        explanation=nil;
        value=nil;

        optionKey=[[NSMutableArray alloc] init];
        optionValue=[[NSMutableArray alloc] init];
        
        selectedOptionIndex=-1;
        
    }
    
    return self;
    
}

-(void) addOptionWithId: (NSString*)idValue text:(NSString*)textValue {
    [optionKey addObject:idValue];
    [optionValue addObject:textValue];
}

-(void) setSelectedOptionWithIndex:(NSInteger)selectedIndex {
    selectedOptionIndex=selectedIndex;
}

-(NSInteger) getSelectedOptionIndex {
    return selectedOptionIndex;
}

-(void) setTextValue:(NSString *) textValue {
    value=textValue;
}

-(NSString *) getTextValue {
    return value;
}

-(NSString *) getValue {
    
    if (isText==YES){
        return value;
    } else {
        return (NSString *)[optionKey objectAtIndex:selectedOptionIndex];
    }
    
}

-(NSString *) getKey {
    return fieldId;
}

@end
