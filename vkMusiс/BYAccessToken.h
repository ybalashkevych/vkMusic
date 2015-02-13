//
//  BYAccessToken.h
//  vkMusiс
//
//  Created by George on 09.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYAccessToken : NSObject <NSCoding>

@property (strong, nonatomic) NSString* token;
@property (strong, nonatomic) NSDate*   expirationDate;
@property (strong, nonatomic) NSString* user_id;


@end