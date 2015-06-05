//
//  BYLoginViewController.h
//  vkMusiс
//
//  Created by George on 09.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccessToken.h"

typedef void(^CompletionBlock)(AccessToken* token);

@interface LoginViewController : UIViewController

- (instancetype)initWithCompletionBlock:(CompletionBlock) completion;

@end