//
//  UTIUser.m
//  Paldaruo
//
//  Created by Patrick Robertson on 25/03/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIUser.h"


@implementation UTIUser

/**
 *  Convenience method for creating a new UTIUser
 *
 *  @param name Name of the user (e.g. 'Bob')
 *  @param uid  UID of the user, as set by the server
 *
 *  @return A new UTIUser instance
 */
+ (instancetype)userWithName:(NSString *)name uid:(NSString *)uid {
    UTIUser *u = [UTIUser new];
    u.name = name;
    u.uid = uid;
    return u;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.uid forKey:@"uid"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _uid = [aDecoder decodeObjectForKey:@"uid"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"User: %@, uid: %@", self.name, self.uid];
}

@end
