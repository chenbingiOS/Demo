//
//  CBWeChatFloatingBtn.m
//  WeChatFloatingView
//
//  Created by 陈冰 on 2018/8/21.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import "CBWeChatFloatingBtn.h"
#import "CBSemiCircleView.h"
#import "CBNextVC.h"

#define kCircleWidth 150

@interface CBWeChatFloatingBtn () {
    CGPoint _lastPointByWindow;
    CGPoint _pointBySelf;
}

@end

@implementation CBWeChatFloatingBtn
static CBWeChatFloatingBtn *floationBtn;
static CBSemiCircleView *semiCircleView;
#pragma mark - Public
+ (void)show {
    // 全局初始化一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        floationBtn = [[CBWeChatFloatingBtn alloc] initWithFrame:CGRectMake(10.f, 100.f, 60.f, 60.f)];
        semiCircleView = [[CBSemiCircleView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height, kCircleWidth, kCircleWidth)];
        semiCircleView.backgroundColor = [UIColor redColor];
    });
    floationBtn.frame = CGRectMake(10.f, 100.f, 60.f, 60.f);
    
    // 显示在最顶层
    if (!semiCircleView.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:semiCircleView];
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:semiCircleView];
    }
    if (!floationBtn.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:floationBtn];
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:floationBtn];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 浮窗按钮背景图片
        self.layer.contents = (__bridge id)[UIImage imageNamed:@"floatingBtn"].CGImage;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    // 相对于父视图 Window
    _lastPointByWindow = [touch locationInView:self.superview];
    // 相对于自身容器
    _pointBySelf = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"触发移动");
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.superview];

    // 四分之一圆显示
    if (CGRectEqualToRect(CGRectMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height, kCircleWidth, kCircleWidth), semiCircleView.frame)) {
        [UIView animateWithDuration:0.2f animations:^{
            semiCircleView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - kCircleWidth, [UIScreen mainScreen].bounds.size.height - kCircleWidth, kCircleWidth, kCircleWidth);
        }];
    }
    
    // 计算 floatingBtn 的 center 坐标
    CGFloat centerX = currentPoint.x + (self.frame.size.width/2 - _pointBySelf.x);
    CGFloat centerY = currentPoint.y + (self.frame.size.width/2 - _pointBySelf.y);
    // 限制 center的左边范围值在屏幕内部
    // 30.f <= x <= [UIScreen maniScreen].bounds.size.width - 30.f
    // 30.f <= x <= [UIScreen maniScreen].bounds.size.height - 30.f
    CGFloat x = MAX(30.f, MIN([UIScreen mainScreen].bounds.size.width - 30.f, centerX));
    CGFloat y = MAX(30.f, MIN([UIScreen mainScreen].bounds.size.height - 30.f, centerY));
    self.center = CGPointMake(x, y);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.superview];

    if (CGPointEqualToPoint(_lastPointByWindow, currentPoint)) {
        // 判断为手机点击事件
        NSLog(@"触发点击");
        UINavigationController *navc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        CBNextVC *vc = [CBNextVC new];
        [navc pushViewController:vc animated:YES];
    }
    
    // 四分之一圆隐藏
    if (CGRectEqualToRect(CGRectMake([UIScreen mainScreen].bounds.size.width - kCircleWidth, [UIScreen mainScreen].bounds.size.height - kCircleWidth, kCircleWidth, kCircleWidth), semiCircleView.frame)) {
        [UIView animateWithDuration:0.2f animations:^{
            // 判断 floatingBtn 有没有进入 semiCircleView 范围内
            // 两个圆心的距离 <= 两个半径之差 说明 floatingBtn 在 semiCircleView 范围内，可以移除 floatingBtn
            CGFloat distacne = sqrt(pow([UIScreen mainScreen].bounds.size.width - self.center.x, 2) + pow([UIScreen mainScreen].bounds.size.height - self.center.y, 2));
            if (distacne <= kCircleWidth - 30.f) {
                [self removeFromSuperview];
            }
            semiCircleView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height, kCircleWidth, kCircleWidth);
        }];
    }
    
    // 离两边的距离
    CGFloat leftMargin = self.center.x;
    CGFloat rightMargin = [UIScreen mainScreen].bounds.size.width - leftMargin;
    if (leftMargin < rightMargin) {
        [UIView animateWithDuration:0.2f animations:^{
            self.center = CGPointMake(40.f, self.center.y);
        }];
    } else {
        [UIView animateWithDuration:0.2f animations:^{
            self.center = CGPointMake([UIScreen mainScreen].bounds.size.width - 40.f, self.center.y);
        }];
    
    }
}

@end
