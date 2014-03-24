//
//  UTIUser.h
//  Paldaruo
//
//  Created by Patrick Robertson on 25/03/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UTIUser : NSObject

@property NSString *name;
@property NSString *uid;

+ (instancetype)userWithName:(NSString *)name uid:(NSString *)uid;

@end
