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
    UIImageView *screenImageView;
}
@property (nonatomic, copy) void(^completionBlock)(void);
@end

@implementation CBAnimationImageView

- (void)startAnimationForView:(UIView *)theView fromRect:(CGRect)fromRect toRect:(CGRect)toRect completionBlock:(void(^)(void))completionBlock {
    _completionBlock = completionBlock;
    [self startAnimationForView:theView fromRect:fromRect toRect:toRect];
}

- (void)startAnimationForView:(UIView *)theView fromRect:(CGRect)fromRect toRect:(CGRect)toRect {
    toView = theView;
    
    ///mask  和 floatingBtn 大小一致的mask
    shaperLayer = [CAShapeLayer layer];
    shaperLayer.path = [UIBezierPath bezierPathWithRoundedRect:fromRect cornerRadius:30.f].CGPath;
    shaperLayer.fillColor = [UIColor lightGrayColor].CGColor;
    screenImageView.layer.mask = shaperLayer;
    
    // 执行动画
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.toValue = (__bridge id)[UIBezierPath bezierPathWithRoundedRect:toRect cornerRadius:30.f].CGPath;
    anim.duration = 0.3f;
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    anim.delegate = self;
    [shaperLayer addAnimation:anim forKey:@"CBAnimationImageViewKey"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    toView.hidden = NO;
    [self removeFromSuperview];
    if (_completionBlock) {
        _completionBlock();
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        screenImageView = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:screenImageView];
    }
    return self;
}

- (void)setScreenImage:(UIImage *)screenImage {
    _screenImage = screenImage;
    screenImageView.image = screenImage;
}

@end
