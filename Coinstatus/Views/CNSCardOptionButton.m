//
//  CNSCardOptionButton.m
//  Coinstatus
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import "CNSCardOptionButton.h"

@implementation CNSCardOptionButton {
    CAShapeLayer *_backgroundLayer;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setup];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setup];
    
    return self;
}

- (void)setup {
    _backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.fillColor = [UIColor colorWithRed:0.93 green:0.33 blue:0.40 alpha:1.00].CGColor;
    
    self.adjustsImageWhenHighlighted = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _backgroundLayer.frame = self.bounds;
    _backgroundLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:6].CGPath;
    [_backgroundLayer removeFromSuperlayer];
    [self.layer insertSublayer:_backgroundLayer atIndex:0];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL superRet = [super beginTrackingWithTouch:touch withEvent:event];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:0 animations:^{
        self.transform = CGAffineTransformMakeScale(0.9, 0.9);
        self.alpha = 0.8;
    } completion:nil];
    
    return superRet;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    
    [self _touchesReleased];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
    
    [self _touchesReleased];
}

- (void)_touchesReleased {
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:0 animations:^{
        self.transform = CGAffineTransformIdentity;
        self.alpha = 1;
    } completion:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
