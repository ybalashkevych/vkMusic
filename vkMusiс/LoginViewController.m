//
//  BYLoginViewController.m
//  vkMusiс
//
//  Created by George on 09.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "LoginViewController.h"
#import "AccessToken.h"

@interface LoginViewController () <UIWebViewDelegate>

@property (copy, nonatomic) CompletionBlock completion;
@property (strong, nonatomic) NSURLRequest* request;
@property (strong, nonatomic) UIWebView*    webView;

@end

@implementation LoginViewController

#pragma mark - Designated Initializer

- (instancetype)initWithCompletionBlock:(CompletionBlock)completion {
    self = [super init];
    if (self) {
        self.completion = completion;
    }
    return self;
}

#pragma mark - View Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    [self.webView loadRequest:self.request];
    
}

#pragma mark - Private Methods

- (AccessToken*)getTokenFromQuery:(NSString*)query {

    NSArray*  pairs = [query componentsSeparatedByString:@"&"];
    AccessToken* accessToken = [[AccessToken alloc] init];
    
    for(NSString* pair in pairs){
        NSArray* pairAr = [pair componentsSeparatedByString:@"="];
        NSString* value = [pairAr lastObject];
        
        if ([[pairAr firstObject] isEqualToString:@"access_token"]) {
            accessToken.token = value;
        }
        else if ([[pairAr firstObject] isEqualToString:@"expires_in"]) {
            accessToken.expirationDate = [NSDate dateWithTimeIntervalSinceNow:[value doubleValue]];
        }
        else if ([[pairAr firstObject] isEqualToString:@"user_id"]) {
            accessToken.user_id = value;
        }
    }
    
    NSData* encodedToken = [NSKeyedArchiver archivedDataWithRootObject:accessToken];
    [[NSUserDefaults standardUserDefaults] setObject:encodedToken forKey:@"accessToken"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return accessToken;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"%@", request);
    NSString* path = [request.URL path];
    if ([path rangeOfString:@"blank"].location != NSNotFound) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        NSString* query = [request.URL fragment];
        AccessToken* accessToken = [self getTokenFromQuery:query];
        
        if (self.completion) {
            self.completion(accessToken);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    return YES;
}








#pragma mark - Getters and Setters
- (NSURLRequest*)request {
    if (!_request) {
        NSURL* url = [NSURL URLWithString:@"https://oauth.vk.com/authorize?"
                      "client_id=4772994&"
                      "scope=audio&"
                      "redirect_uri=https://oauth.vk.com/blank.html&"
                      "display=mobile&"
                      "v=5.28&"
                      "response_type=token&"];
        _request = [[NSURLRequest alloc] initWithURL:url];
        
    }
    return _request;
}


- (UIWebView*)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_webView];
        _webView.delegate = self;
    }
    return _webView;
}

@end









