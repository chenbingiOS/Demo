//
//  CBAnimationImageView.m
//  WeChatFloatingView
//
//  Created by hxbjt on 2018/8/21.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import "CBAnimationImageView.h"

@interface CBAnimationImageView () <CAAnimationDelegate> {
    CAShapeLayer *shaperLayer;
    UIView *toView;
}

@end

@implementation CBAnimationImageView

- (void)startAnimateWithView:(UIView *)theView fromRect:(CGRect)fromRect toRect:(CGRect)toRect {
    toView = theView;
    ///mask  和 floatingBtn 大小一致的mask
    shaperLayer = [CAShapeLayer layer];
    shaperLayer.path = [UIBezierPath bezierPathWithRoundedRect:fromRect cornerRadius:30.f].CGPath;
    self.layer.mask = shaperLayer;
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.toValue = (__bridge id)[UIBezierPath bezierPathWithRoundedRect:toRect cornerRadius:30.f].CGPath;
    anim.duration = 0.5f;
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    anim.delegate = self;
    [shaperLayer addAnimation:anim forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    toView.hidden = YES;
    [shaperLayer removeAllAnimations];
    [self removeFromSuperview];
}

@end
