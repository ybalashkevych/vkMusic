//
//  BYLoginViewController.m
//  vkMusiс
//
//  Created by George on 09.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "BYLoginViewController.h"
#import "BYAccessToken.h"

@interface BYLoginViewController () <UIWebViewDelegate>

@property (copy, nonatomic) BYCompletionBlock completion;
@property (strong, nonatomic) NSURLRequest* request;
@property (strong, nonatomic) UIWebView*    webView;

@end

@implementation BYLoginViewController

#pragma mark - Designated Initializer

- (instancetype)initWithCompletionBlock:(BYCompletionBlock)completion {
    self = [super init];
    if (self) {
        self.completion = completion;
    }
    return self;
}

#pragma mark - View Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem* rigthBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(actionDone:)];
    self.navigationItem.rightBarButtonItem = rigthBarButton;
    rigthBarButton.enabled = NO;
    self.webView.delegate = self;
    [self.webView loadRequest:self.request];
    
    
}

#pragma mark - Private Methods

- (BYAccessToken*)getTokenFromPath:(NSString*)path {
    
    NSArray* components = [path componentsSeparatedByString:@"#"];
    NSString* parameters = [components lastObject];
    NSArray*  pairs = [parameters componentsSeparatedByString:@"&"];
    BYAccessToken* accessToken = [[BYAccessToken alloc] init];
    
    for(NSString* pair in pairs){
        NSArray* pairAr = [pair componentsSeparatedByString:@"="];
        NSString* value = [pairAr lastObject];
        
        if ([value isEqualToString:@"access_token"]) {
            accessToken.token = value;
        }
        else if ([value isEqualToString:@"expires_in"]) {
            accessToken.expirationDate = [NSDate dateWithTimeIntervalSinceNow:[value doubleValue]];
        }
        else if ([value isEqualToString:@"user_id"]) {
            accessToken.user_id = value;
        }
    }
    
    if (self.completion) {
        self.completion(accessToken);
    }
    
    return nil;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString* path = [request.URL path];
    if ([path rangeOfString:@"blank"].location != NSNotFound) {
        [self getTokenFromPath:path];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return NO;
    }
    NSLog(@"%@", request);
    return YES;
}


#pragma mark - Actions

- (void)actionDone {
    [self dismissViewControllerAnimated:YES completion:nil];
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
                      "response_type=token&"
                      "revoke=1"];
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









