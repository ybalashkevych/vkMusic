//
//  TrackLineSlider.m
//  vkMusiс
//
//  Created by Yuri Balashkevych on 09.05.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "TrackLineSlider.h"

@interface TrackLineSlider ()


@end

@implementation TrackLineSlider

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
}






#pragma mark - Slider Tracing

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGFloat maxX = CGRectGetWidth(self.bounds)*self.progress;
    CGFloat currentX = [touch locationInView:self].x;
    
    if (currentX > maxX) {
            return NO;
    }
    
    [super beginTrackingWithTouch:touch withEvent:event];
    return YES;
    
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGFloat maxX = CGRectGetWidth(self.bounds)*self.progress;
    CGFloat currentX = [touch locationInView:self].x;
    
    if (currentX > maxX) {
        return NO;
    
    }

    [super continueTrackingWithTouch:touch withEvent:event];
    return YES;
    
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    [super endTrackingWithTouch:touch withEvent:event];
    
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    
    [super cancelTrackingWithEvent:event];
    
}







#pragma mark - Customizing

- (CGRect)trackRectForBounds:(CGRect)bounds {
    
    CGRect trackRect = bounds;
    CGFloat x = CGRectGetMinX(trackRect);
    CGFloat y = CGRectGetMinY(trackRect);
    CGFloat w = CGRectGetWidth(trackRect);
    CGFloat h = 10;
    
    return CGRectMake(x, y, w, h);
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    
    return [super thumbRectForBounds:bounds trackRect:rect value:value];
}






#pragma mark - Getters and Setters



@end
























