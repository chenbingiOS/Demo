//
//  CBWeChatFloatingBtn.m
//  WeChatFloatingView
//
//  Created by 陈冰 on 2018/8/21.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import "CBWeChatFloatingBtn.h"
#import "CBSemiCircleView.h"
#import "CBShowFloatingVC.h"
#import "CBAnimator.h"
#import "CBInteractiveTransition.h"

@interface CBWeChatFloatingBtn () <UINavigationControllerDelegate> {
    CGPoint lastPointByWindow;
    CGPoint pointBySelf;
    CBInteractiveTransition *interactiveTransition;
}

@end

@implementation CBWeChatFloatingBtn

#define kfixSpace 160.f
#define kleftSpace 15.f
static CBWeChatFloatingBtn *floatingBtn;
static CBSemiCircleView *semiCircleView;

#pragma mark - Public
+ (void)show {
    // 全局初始化一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        floatingBtn = [[CBWeChatFloatingBtn alloc] initWithFrame:CGRectMake(kleftSpace, 100.f, 60.f, 60.f)];
        semiCircleView = [[CBSemiCircleView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height, kfixSpace, kfixSpace)];
    });
    floatingBtn.frame = CGRectMake(kleftSpace, [UIScreen mainScreen].bounds.size.height/2, 60.f, 60.f);
    floatingBtn.alpha = 1.f;
    
    // 显示在最顶层，两者顺序不能颠倒
    if (!semiCircleView.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:semiCircleView];
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:semiCircleView];
    }
    if (!floatingBtn.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:floatingBtn];
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:floatingBtn];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 浮窗按钮背景图片
        self.layer.contents = (__bridge id)[UIImage imageNamed:@"FloatBtn"].CGImage;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    // 相对于父视图 Window
    lastPointByWindow = [touch locationInView:self.superview];
    // 相对于自身容器
    pointBySelf = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];

    // 四分之一圆动画展开显示
    CGRect rect = CGRectMake([UIScreen mainScreen].bounds.size.width - kfixSpace, [UIScreen mainScreen].bounds.size.height - kfixSpace, kfixSpace, kfixSpace);
    if (!CGRectEqualToRect(semiCircleView.frame, rect)) {
        [UIView animateWithDuration:0.2f animations:^{
            semiCircleView.frame = rect;
        }];
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.superview];
    // 计算 floatingBtn 的 center 坐标
    CGFloat centerX = currentPoint.x + (self.frame.size.width/2 - pointBySelf.x);
    CGFloat centerY = currentPoint.y + (self.frame.size.width/2 - pointBySelf.y);
    // 限制 center的左边范围值在屏幕内部
    // 30.f <= x <= [UIScreen maniScreen].bounds.size.width - 30.f
    // 30.f <= x <= [UIScreen maniScreen].bounds.size.height - 30.f
    CGFloat x = MAX(self.frame.size.width/2, MIN([UIScreen mainScreen].bounds.size.width - self.frame.size.width/2, centerX));
    CGFloat y = MAX(self.frame.size.width/2, MIN([UIScreen mainScreen].bounds.size.height - self.frame.size.width/2, centerY));
    // 移动的时候，图标也跟随移动
    self.center = CGPointMake(x, y);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.superview];
    
    /// 判断 end 和 begin 两种状态之间是否有移动，如果没有移动，响应跳转事件
    if (CGPointEqualToPoint(lastPointByWindow, currentPoint)) {
        interactiveTransition = [CBInteractiveTransition new];
        interactiveTransition.curPoint = self.frame.origin;
        
        // 判断为手机点击事件
        UINavigationController *navc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        navc.delegate = self;   /// 添加代理，拦截为自定义转场动画
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        CBShowFloatingVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"CBShowFloatingVC"];
        [interactiveTransition transtionToViewController:vc];
        [navc pushViewController:vc animated:YES];
    }
    
    // 四分之一圆隐藏
    CGRect rect = CGRectMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height, kfixSpace, kfixSpace);
    if (!CGRectEqualToRect(semiCircleView.frame, rect)) {
        [UIView animateWithDuration:0.2f animations:^{
            semiCircleView.frame = rect;
            // 判断 floatingBtn 有没有进入 semiCircleView 范围内
            // 两个圆心的距离 <= 两个半径之差 说明 floatingBtn 在 semiCircleView 范围内，可以移除 floatingBtn
            CGFloat distacne = sqrt(pow([UIScreen mainScreen].bounds.size.width - self.center.x, 2) + pow([UIScreen mainScreen].bounds.size.height - self.center.y, 2));
            if (distacne <= kfixSpace - 30.f) {
                [self removeFromSuperview];
            }
        }];
    }
    
    // 离两边的距离
    CGFloat leftMargin = self.center.x;
    CGFloat rightMargin = [UIScreen mainScreen].bounds.size.width - leftMargin;
    if (leftMargin < rightMargin) {
        [UIView animateWithDuration:0.2f animations:^{
            self.center = CGPointMake(kleftSpace+self.frame.size.width/2, self.center.y);
        }];
    } else {
        [UIView animateWithDuration:0.2f animations:^{
            self.center = CGPointMake([UIScreen mainScreen].bounds.size.width - (kleftSpace+self.frame.size.width/2), self.center.y);
        }];
    }
}

#pragma mark - UINavigationControllerDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush) {
        self.alpha = 0.f;
    }
    // 拦截使用自定义转场动画
    CBAnimator *animator = [CBAnimator new];
    animator.operation = operation;
    animator.curPoint = self.frame.origin;
    animator.isInteractive = interactiveTransition.isInteractive;
    return animator;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    return interactiveTransition.isInteractive ? interactiveTransition : nil;
}
@end
