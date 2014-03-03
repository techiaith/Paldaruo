//
//  UTIPrompt.h
//  Paldaruo
//
//  Created by Apiau on 09/01/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UTIPrompt : NSObject

@property (strong) NSString *identifier;
@property (strong) NSString *text;
@property (getter = isRecorded) BOOL recorded;
@property NSInteger index;
@end
