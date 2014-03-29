//
//  UTIMetaDataField.h
//  Paldaruo
//
//  Created by Apiau on 03/02/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UTIMetaDataField : NSObject

@property (strong) NSString *fieldId;
@property (strong) NSString *title;
@property (strong) NSString *question;
@property (strong) NSString *explanation;
@property BOOL isText;
@property (strong) NSMutableArray *optionKey;
@property (strong) NSMutableArray *optionValue;
@property (strong) NSString *value;
@property NSInteger selectedOptionIndex;

-(void) addOptionWithId: (NSString*)idValue text:(NSString*)textValue;

@end
