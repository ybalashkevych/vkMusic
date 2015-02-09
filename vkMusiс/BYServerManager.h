//
//  BYServerManager.h
//  vkMusiс
//
//  Created by George on 09.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "BYAccessToken.h"

@interface BYServerManager : NSObject

@property (strong, nonatomic) AFHTTPRequestOperationManager*    requestManager;
@property (strong, nonatomic) BYAccessToken*                    token;

- (void)authorize;

+ (BYServerManager*)sharedManager;


@end
