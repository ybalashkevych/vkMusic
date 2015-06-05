//
//  RKRollCrawl.m
//  testLine
//
//  Created by Roman Kotov on 18.01.15.
//  Copyright (c) 2015 Roman Kotov. All rights reserved.
//

#import "RKRollCrawl.h"

@implementation RKRollCrawl {
    UILabel *labelWithText;
    UILabel *copyLableWithText;
    
    BOOL isScrolling;
}

#pragma mark -
#pragma mark init

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initLabel];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initLabel];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initLabel];
    }
    
    return self;
}

#pragma mark -
#pragma mark Label init
- (void)initLabel {
    
    self.delayBetweenAnimationScroll = 2;
    self.durationAnimationScroll = 5;
    
    self.aligmentText = RKRollCrawlAligmentTop;
    
    labelWithText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    labelWithText.text = @"";
    [self addSubview:labelWithText];
    
    
    copyLableWithText = [[UILabel alloc] initWithFrame:CGRectMake(labelWithText.frame.origin.x + labelWithText.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
    copyLableWithText.text = labelWithText.text;
    [self addSubview:copyLableWithText];
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.scrollEnabled = NO;
    
    isScrolling = NO;
}

#pragma mark -
#pragma mark update
- (void)updateContentSize {
    if (labelWithText.frame.size.width > self.frame.size.width) {
        copyLableWithText.hidden = NO;
        self.contentSize = CGSizeMake(copyLableWithText.frame.origin.x + copyLableWithText.frame.size.width, self.frame.size.height);
    } else {
        copyLableWithText.hidden = YES;
        self.contentSize = CGSizeMake(labelWithText.frame.size.width, self.frame.size.height);
    }
}

#pragma mark -
#pragma mark getters // setters
- (void)setText:(NSString *)text {
    copyLableWithText.text =
    labelWithText.text = text;
    
    [labelWithText sizeToFit];
    
    copyLableWithText.frame = CGRectMake(labelWithText.frame.origin.x + labelWithText.frame.size.width + 20,
                                         0,
                                         self.frame.size.width,
                                         self.frame.size.height);
    [copyLableWithText sizeToFit];
    
    [self updateContentSize];
    
    if (!isScrolling) {
        isScrolling = YES;
        [self scrolling];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    super.scrollEnabled = NO;
}

- (NSString *)text {
    return labelWithText.text;
}

- (void)setTextColor:(UIColor *)textColor {
    labelWithText.textColor =
    copyLableWithText.textColor = textColor;
}

- (UIColor *)textColor {
    return labelWithText.textColor;
}

- (void)setFont:(UIFont *)font {
    // Устанавливаем шрифт для первого поля
    labelWithText.font = font;
    [labelWithText sizeToFit];
    
    // Устанавливаем шрифт для второго поля
    copyLableWithText.font = font;
    [copyLableWithText sizeToFit];
    
    // Получаем высоту шрифта
    CGFloat fontSize = font.pointSize + 3;
    
    // Получаем фреймы всех элементов
    CGRect rectLabel = labelWithText.frame;
    CGRect rectCopyLabel = copyLableWithText.frame;
    CGRect rectScroll = self.frame;
    
    // Высоту изменяем на высоту шрифта
    rectLabel.size.height =
    rectCopyLabel.size.height =
    rectScroll.size.height = fontSize;
    
    // Устанавливаем Х координату копии на 20 точек правее конца обычного текста
    rectCopyLabel.origin.x = rectLabel.origin.x + rectLabel.size.width + 20;
    
    // Присваиваем фреймы обратно
    labelWithText.frame = rectLabel;
    copyLableWithText.frame = rectCopyLabel;
    self.frame = rectScroll;
    
    // Проверяем, если ширина основого поля не больше ширины self, то скрываем копию и скролить не будем
    [self updateContentSize];
}

- (UIFont *)font {
    return labelWithText.font;
}

- (void)setAligmentText:(RKRollCrawlAligment)aligmentText {
    _aligmentText = aligmentText;
    
    switch (_aligmentText) {
        case RKRollCrawlAligmentTop: {
            CGRect rectLabel = labelWithText.frame;
            CGRect rectCopyLabel = copyLableWithText.frame;
            
            rectLabel.origin.y =
            rectCopyLabel.origin.y = 0;
            
            labelWithText.frame = rectLabel;
            copyLableWithText.frame = rectCopyLabel;
            break;
        }
        case RKRollCrawlAligmentCenter: {
            CGPoint centerLabel = labelWithText.center;
            CGPoint centerCopyLabel = copyLableWithText.center;
            
            centerLabel.y =
            centerCopyLabel.y = self.center.y;
            
            labelWithText.center = centerLabel;
            copyLableWithText.center = centerCopyLabel;
            break;
        }
        case RKRollCrawlAligmentBottom: {
            CGRect rectLabel = labelWithText.frame;
            CGRect rectCopyLabel = copyLableWithText.frame;
            
            rectLabel.origin.y =
            rectCopyLabel.origin.y = self.frame.size.height - labelWithText.frame.size.height;
            
            labelWithText.frame = rectLabel;
            copyLableWithText.frame = rectCopyLabel;
            break;
        }
        default:
            break;
    }
}

- (void)setFrame:(CGRect)frame {
    super.frame = frame;
    
    [self updateContentSize];
}

#pragma mark -
#pragma mark Scrolling
- (void)scrolling {
    // Если текст полностью помещается, то скролить не будем
    if (self.contentSize.width <= self.frame.size.width) {
        isScrolling = NO;
    }
    __block typeof(self) __self = self;
    [UIView animateWithDuration:self.durationAnimationScroll
                     animations:^{
                         // Скролим до копии
                         [__self scrollRectToVisible:CGRectMake(copyLableWithText.frame.origin.x, copyLableWithText.frame.origin.y, self.frame.size.width, self.frame.size.height) animated:NO];
                     }
                     completion:^(BOOL finished) {
                         // Без анимации скролим в начало
                         [__self scrollRectToVisible:CGRectMake(labelWithText.frame.origin.x, labelWithText.frame.origin.y, self.frame.size.width, self.frame.size.height) animated:NO];
                         
                         // Через определенное время повторяем
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, self.delayBetweenAnimationScroll * NSEC_PER_SEC);
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             if (isScrolling) {
                                 [__self scrolling];
                             }
                         });
                     }];
}

#pragma mark -
#pragma mark dealloc
- (void)dealloc {
    isScrolling = NO;
}

@end
