//
//  BYServerManager.m
//  vkMusiс
//
//  Created by George on 09.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "BYServerManager.h"
#import "BYLoginViewController.h"

@interface BYServerManager()

@property (strong, nonatomic) NSURL*            baseURL;
@property (strong, nonatomic) UIViewController* mainVC;

@end

@implementation BYServerManager

#pragma mark - Singleton

+ (BYServerManager*)sharedManager {
    static BYServerManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BYServerManager alloc] init];
    });
    return manager;
}

#pragma mark - Private Methods

- (void)authorize {
    
    BYLoginViewController* vc = [[BYLoginViewController alloc] initWithCompletionBlock:^(BYAccessToken *token) {
        self.token = token;
    }];

    UINavigationController* navC = [[UINavigationController alloc] initWithRootViewController:vc];

    UIApplication* app = [UIApplication sharedApplication];
    NSArray* windows = [app windows];
    UIViewController* mainVC = [[windows firstObject] rootViewController];

    self.mainVC = mainVC;
    [self.mainVC presentViewController:navC animated:YES completion:nil];
    
}

#pragma mark - Getters and Setters

- (AFHTTPRequestOperationManager*)requestManager {
    
    if (_requestManager) {
        _requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.baseURL];
    }
    
    return _requestManager;

}

- (NSURL*)baseURL {
    if (_baseURL) {
        _baseURL = [NSURL URLWithString:@"https://api.vk.com/method/"];
    }
    return _baseURL;
}

@end











