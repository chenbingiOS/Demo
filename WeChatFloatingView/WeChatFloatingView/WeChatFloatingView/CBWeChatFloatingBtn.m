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
    CGPoint lastPointBySelf;
    ;
}

@property (nonatomic, strong) UIViewController *containerVC;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, strong) CBAnimator *animator;
@property (nonatomic, strong) CBInteractiveTransition *interactiveTransition;

@end

@implementation CBWeChatFloatingBtn

#define kfixSpace 160.f
#define kleftSpace 15.f
static CBWeChatFloatingBtn *floatingBtn;
static CBSemiCircleView *semiCircleView;

#pragma mark - Public
+ (void)showWithViewController:(UIViewController *)vc {
    // 展示前判断
    UINavigationController *navc = vc.navigationController;
    if (!navc) {
        NSLog(@"展示浮窗只能显示 UINavigationController 管理的视图控制器上");
        return;
    }
    
    // 全局初始化一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        floatingBtn = [[CBWeChatFloatingBtn alloc] initWithFrame:CGRectMake(kleftSpace, 100.f, 60.f, 60.f)];
        semiCircleView = [[CBSemiCircleView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height, kfixSpace, kfixSpace)];
    });
    
    // 显示在最顶层，两者顺序不能颠倒
    if (!semiCircleView.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:semiCircleView];
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:semiCircleView];
    }
    if (!floatingBtn.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:floatingBtn];
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:floatingBtn];
    }
    
    floatingBtn.containerVC = vc;
    floatingBtn.isShowing = YES;
    
    navc.delegate = floatingBtn;
    [navc popViewControllerAnimated:YES];
}

+ (void)remove {
    [floatingBtn removeForWindow];
}

+ (BOOL)isShowingWithViewController:(UIViewController *)vc {
    if (!floatingBtn) {
        return NO;
    }
    if (floatingBtn.containerVC != vc) {
        return NO;
    }
    return floatingBtn.isShowing;
}

- (void)removeForWindow {
    [self removeFromSuperview];
    self.isShowing = NO;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
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
    lastPointBySelf = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.superview];
    
    /// 判断 end 和 begin 两种状态之间是否有移动，如果移动，展开视图
    if (!CGPointEqualToPoint(lastPointByWindow, currentPoint)) {
        // 四分之一圆动画展开显示，出现移动才展开
        CGRect rect = CGRectMake([UIScreen mainScreen].bounds.size.width - kfixSpace, [UIScreen mainScreen].bounds.size.height - kfixSpace, kfixSpace, kfixSpace);
        if (!CGRectEqualToRect(semiCircleView.frame, rect)) {
            [UIView animateWithDuration:0.3f animations:^{
                semiCircleView.frame = rect;
            }];
        }
    }
    
    // 计算 floatingBtn 的 center 坐标
    CGFloat centerX = currentPoint.x + (self.frame.size.width/2 - lastPointBySelf.x);
    CGFloat centerY = currentPoint.y + (self.frame.size.height/2 - lastPointBySelf.y);
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
        [self toContainerVC];
    } else {
        // 四分之一圆隐藏
        CGRect rect = CGRectMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height, kfixSpace, kfixSpace);
        if (!CGRectEqualToRect(semiCircleView.frame, rect)) {
            [UIView animateWithDuration:0.3f animations:^{
                semiCircleView.frame = rect;
                // 判断 floatingBtn 有没有进入 semiCircleView 范围内
                // 两个圆心的距离 <= 两个半径之差 说明 floatingBtn 在 semiCircleView 范围内，可以移除 floatingBtn
                CGFloat distacne = sqrt(pow([UIScreen mainScreen].bounds.size.width - self.center.x, 2) + pow([UIScreen mainScreen].bounds.size.height - self.center.y, 2));
                if (distacne <= kfixSpace - 30.f) {
                    [CBWeChatFloatingBtn remove];
                }
            }];
        }
        
        // 离两边的距离
        CGFloat leftMargin = self.center.x;
        CGFloat rightMargin = [UIScreen mainScreen].bounds.size.width - leftMargin;
        if (leftMargin < rightMargin) {
            [UIView animateWithDuration:0.3f animations:^{
                self.center = CGPointMake(kleftSpace+self.frame.size.width/2, self.center.y);
            }];
        } else {
            [UIView animateWithDuration:0.3f animations:^{
                self.center = CGPointMake([UIScreen mainScreen].bounds.size.width - (kleftSpace+self.frame.size.width/2), self.center.y);
            }];
        }
    }
}

// 跳转
- (void)toContainerVC {
    self.interactiveTransition.curPoint = self.frame.origin;
    
    // 判断为手机点击事件
    UINavigationController *navc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if (!navc) {
        NSLog(@"展示浮窗只能显示 UINavigationController 管理的视图控制器上");
        return;
    }
    navc.delegate = self;   /// 添加代理，拦截为自定义转场动画
    [self.interactiveTransition transtionToViewController:self.containerVC];
    [navc pushViewController:self.containerVC animated:YES];
}

- (CBAnimator *)animator {
    if (!_animator) {
        _animator = [CBAnimator new];
    }
    return _animator;
}

- (CBInteractiveTransition *)interactiveTransition {
    if (!_interactiveTransition) {
        _interactiveTransition = [CBInteractiveTransition new];
    }
    return _interactiveTransition;
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
    self.animator.operation = operation;
    self.animator.curPoint = self.frame.origin;
    self.animator.isInteractive = self.interactiveTransition.isInteractive;
    return self.animator;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    return self.interactiveTransition.isInteractive ? self.interactiveTransition : nil;
}

@end
