//
//  RKRollCrawl.h
//  testLine
//
//  Created by Roman Kotov on 18.01.15.
//  Copyright (c) 2015 Roman Kotov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    RKRollCrawlAligmentTop,
    RKRollCrawlAligmentCenter,
    RKRollCrawlAligmentBottom,
} RKRollCrawlAligment;

@interface RKRollCrawl : UIScrollView

@property (nonatomic, strong) NSString* text;
@property (nonatomic, strong) UIFont* font;
@property (nonatomic, strong) UIColor* textColor;

@property (nonatomic, assign) RKRollCrawlAligment aligmentText;

/// По умолчанию 5
@property (nonatomic, assign) NSUInteger durationAnimationScroll;
/// По умолчанию 2
@property (nonatomic, assign) NSUInteger delayBetweenAnimationScroll;

@end
