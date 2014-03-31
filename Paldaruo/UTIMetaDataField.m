//
//  UTIMetaDataField.m
//  Paldaruo
//
//  Created by Apiau on 03/02/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIMetaDataField.h"

@implementation UTIMetaDataField

@synthesize value = _value;

-(id) init {
    
    if ((self = [super init]) != nil) {
        
        _fieldId=nil;
        _title=nil;
        _question=nil;
        _explanation=nil;
        _value=nil;

        _optionKey=[[NSMutableArray alloc] init];
        _optionValue=[[NSMutableArray alloc] init];
        
        _selectedOptionIndex=-1;
        
    }
    
    return self;
    
}

-(void) addOptionWithId: (NSString*)idValue text:(NSString*)textValue {
    [self.optionKey addObject:idValue];
    [self.optionValue addObject:textValue];
}

-(void)setValue:(NSString *) textValue {
    _value = textValue;
}

- (NSString *)value {
    
    if (self.isText==YES){
        return _value;
    } else {
        return (NSString *)[self.optionKey objectAtIndex:self.selectedOptionIndex];
    }
    
}

@end
