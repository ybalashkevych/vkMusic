//
//  BYServerManager.h
//  vkMusiс
//
//  Created by George on 09.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "AccessToken.h"
#import "DataManager.h"

@class Song;

@interface ServerManager : NSObject

@property (strong, nonatomic) AFHTTPRequestOperationManager*    requestManager;
@property (strong, nonatomic) AccessToken*                    token;
@property (strong, nonatomic) AFURLSessionManager*              sessionManager;
@property (strong, nonatomic) DataManager*                    dataManager;
@property (strong, nonatomic) NSURL*                            baseURL;



- (void)authorizeWithCompletionBlock:(void(^)())completion;

+ (ServerManager*)sharedManager;

- (void)getSongsWithParameters:(NSDictionary*)params onSuccess:(void(^)())success andFailure:(void(^)(NSError* error))failure;

- (void)getContentAndCoverImageForSong:(Song*)song withParameters:(NSDictionary*)params onSuccess:(void(^)(NSString* imagePath))success andFailure:(void(^)(NSError* error))failure;

- (void)getLyricsWithParameters:(NSDictionary*)params onSuccess:(void(^)(NSString* text))success andFailure:(void(^)(NSError* error))failure;

- (void)postDeleteSongWithParameters:(NSDictionary*)params onSuccess:(void(^)())success andFailure:(void(^)(NSError* error))failure;

@end





















