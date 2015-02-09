//
//  BYLoginViewController.h
//  vkMusiс
//
//  Created by George on 09.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BYAccessToken.h"

typedef void(^BYCompletionBlock)(BYAccessToken* token);

@interface BYLoginViewController : UIViewController

- (instancetype)initWithCompletionBlock:(BYCompletionBlock) completion;

@end