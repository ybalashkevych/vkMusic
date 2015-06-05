//
//  BYAccessToken.m
//  vkMusiс
//
//  Created by George on 09.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "AccessToken.h"

@implementation AccessToken

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.token forKey:@"token"];
    [aCoder encodeObject:self.user_id forKey:@"user_id"];
    [aCoder encodeObject:self.expirationDate forKey:@"expirationDate"];
    
 }

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    
    if (self) {
        self.user_id = [aDecoder decodeObjectForKey:@"user_id"];
        self.token = [aDecoder decodeObjectForKey:@"token"];
        self.expirationDate = [aDecoder decodeObjectForKey:@"expirationDate"];
    }
    
    return self;
}

@end
