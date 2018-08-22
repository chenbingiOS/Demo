//
//  CBWeChatFloatingManager.m
//  WeChatFloatingView
//
//  Created by hxbjt on 2018/8/22.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import "CBWeChatFloatingManager.h"
#import "CBSemiCircleView.h"
#import "CBWeChatFloatingBtn.h"
#import "CBAnimator.h"
#import "CBInteractiveTransition.h"
#import "CBAnimationImageView.h"

#define kfixSpace 145.f

@interface CBWeChatFloatingManager () <UINavigationControllerDelegate, UIGestureRecognizerDelegate, CBWeChatFloatingBtnDelegate> {
    UIScreenEdgePanGestureRecognizer *edgePan;
    BOOL isShowFloatingBtn;
    BOOL shouldComplete;
    CGFloat transitionX;
}
@property (nonatomic, strong) NSMutableArray <NSString *> *floatingVCClass;
@property (nonatomic, strong) UIViewController *containerVC;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) CBWeChatFloatingBtn *floatingBtn; ///< 浮窗
@property (nonatomic, strong) CBSemiCircleView *semiCircleView; /// < 开启浮窗
@property (nonatomic, strong) CBAnimator *animator;
@property (nonatomic, strong) CBInteractiveTransition *interactiveTransition;

@end

@implementation CBWeChatFloatingManager

+ (instancetype)sharedManager {
    static CBWeChatFloatingManager *floatingManger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        floatingManger = [[super allocWithZone:nil] init];
        floatingManger.floatingVCClass = [NSMutableArray array];
        UINavigationController *navc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        navc.interactivePopGestureRecognizer.delegate = floatingManger;
        navc.delegate = floatingManger;
    });
    return floatingManger;
}

+ (void)showWithViewController:(UIViewController *)vc {
    // 展示前判断
    UINavigationController *navc = vc.navigationController;
    if (!navc) {
        NSLog(@"展示浮窗只能显示 UINavigationController 管理的视图控制器上");
        return;
    }
    [CBWeChatFloatingManager sharedManager].containerVC = vc;
}

- (void)addShowFloatingVCClass:(NSArray <NSString *> *)vcClasses {
    __block NSMutableArray *floatingVCClassBlock = self.floatingVCClass;
    [vcClasses enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![floatingVCClassBlock containsObject:obj]) {
            [floatingVCClassBlock addObject:obj];
        }
    }];
}

#pragma mark - Private
// 拦截屏幕策划手势
- (void)beginScreenEdgePanGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    // 实现定义需要拦截的类才拦截
    UINavigationController *navc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    self.containerVC = navc.visibleViewController;
    if ([self.floatingVCClass containsObject:NSStringFromClass([self.containerVC class])]) {
        edgePan = (UIScreenEdgePanGestureRecognizer *)gestureRecognizer;
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        // 显示在最顶层，两者顺序不能颠倒
        if (!self.semiCircleView.superview) {
            [[UIApplication sharedApplication].keyWindow addSubview:self.semiCircleView];
            [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.semiCircleView];
        }
    }
}

- (void)displayLinkActionEdgePan:(CADisplayLink *)dispalyLink {
    NSLog(@"%s",__func__);
    NSLog(@"%@", @(edgePan.state));
    if (edgePan.state == UIGestureRecognizerStateChanged) {        
        if (isShowFloatingBtn)
        {
        }
        else
        {
            // 浮窗未显示时
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            CGPoint tPoint = [edgePan translationInView:keyWindow];
            CGFloat x = MAX([UIScreen mainScreen].bounds.size.width + 30 - tPoint.x, [UIScreen mainScreen].bounds.size.width - kfixSpace);
            CGFloat y = MAX([UIScreen mainScreen].bounds.size.height + 30 - tPoint.x, [UIScreen mainScreen].bounds.size.height - kfixSpace);
            CGRect rect = CGRectMake(x, y, kfixSpace, kfixSpace);
            self.semiCircleView.frame = rect;
            
            /// 做坐标转化，当手指移入到 semiCircleView 范围内部为正值
            CGPoint pointByWindow = [edgePan locationInView:keyWindow];
            CGPoint touchPoint = [keyWindow convertPoint:pointByWindow toView:self.semiCircleView];
            if (touchPoint.x > 0 && touchPoint.y > 0) {
                if (!isShowFloatingBtn) {
                    if (pow((kfixSpace - touchPoint.x), 2) + pow((kfixSpace - touchPoint.y), 2) <= pow((kfixSpace), 2)) {
                        isShowFloatingBtn = YES;
                    } else {
                        if (isShowFloatingBtn) isShowFloatingBtn = NO;
                    }
                }
            } else {
                if (isShowFloatingBtn) isShowFloatingBtn = NO;
            }
        }
    }
    else if (edgePan.state == UIGestureRecognizerStateEnded || edgePan.state == UIGestureRecognizerStateCancelled) {
        
    }
    else if (edgePan.state == UIGestureRecognizerStatePossible) {
        // 关闭定时器
        [self.displayLink invalidate];
        self.displayLink = nil;

        if (isShowFloatingBtn) {
            if (!self.floatingBtn.superview) {
                [[UIApplication sharedApplication].keyWindow addSubview:self.floatingBtn];
                [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.floatingBtn];
            }
            
            if (shouldComplete) {
                
//                // 截图
//                UIView *fromView = self.containerVC.view;
//
//                CBAnimationImageView *theView = [[CBAnimationImageView alloc] initWithFrame:fromView.bounds];
//                UIGraphicsBeginImageContext(fromView.bounds.size);
//                [fromView.layer renderInContext:UIGraphicsGetCurrentContext()];
//                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//                theView.screenImage = image;
//                UIGraphicsEndImageContext();
//
//                // 缩小动画
//                CGRect fromRect = fromView.frame;   /// 复制窗体大小
//                fromRect.origin.x = transitionX;
//                fromRect.origin.y = 0.f;
//                CGRect toRect = CGRectMake(self.floatingBtn.frame.origin.x, self.floatingBtn.frame.origin.y, 60.f, 60.f);
//                [theView startAnimationForView:theView fromRect:fromRect toRect:toRect];
//
//                // 置于顶部
//                fromView.frame = CGRectZero;
//                [fromView.superview addSubview:theView];
//
//                // 完成场景转换
                UINavigationController *navc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                [navc popViewControllerAnimated:NO];
//                //            navc.delegate = nil; //这个需要设置，而且只能在这里设置，不能在外面设置
            }
            else  // 取消关闭
            {
                //            self.floatingBtn.alpha = 0.f;
            }
        }

        // 关闭浮窗
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.3f animations:^{
            weakSelf.semiCircleView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height, kfixSpace, kfixSpace);
        } completion:^(BOOL finished) {
            [weakSelf.semiCircleView removeFromSuperview];
            weakSelf.semiCircleView = nil;
        }];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    UINavigationController *navc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if (navc.viewControllers.count >= 1) {
        [self beginScreenEdgePanGestureRecognizer:gestureRecognizer];
        return YES;
    }
    return NO;
}

#pragma mark - CBWeChatFloatingBtnDelegate

- (void)pushContainerVCWithWeChatFloatingBtn:(UIView *)floatingBtn {
    self.interactiveTransition.curPoint = self.floatingBtn.frame.origin;

    // 判断为手机点击事件
    UINavigationController *navc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if (!navc) {
        NSLog(@"展示浮窗只能显示 UINavigationController 管理的视图控制器上");
        return;
    }
    navc.delegate = self;   /// 添加代理，拦截为自定义转场动画
//    [self.interactiveTransition transtionToViewController:self.containerVC];
    [navc pushViewController:self.containerVC animated:YES];
}

#pragma mark - UINavigationControllerDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    if (isShowFloatingBtn)
    {
        if (operation == UINavigationControllerOperationPush) {
            self.floatingBtn.alpha = 0.f;
        }
        // 拦截使用自定义转场动画
        self.animator.operation = operation;
        self.animator.curPoint = self.floatingBtn.frame.origin;
        self.animator.isInteractive = self.interactiveTransition.isInteractive;
        return self.animator;
    }
    else
    {
        return nil;
    }
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    return self.interactiveTransition.isInteractive ? self.interactiveTransition : nil;
}

#pragma mark - layz
- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkActionEdgePan:)];
    }
    return _displayLink;
}

- (CBSemiCircleView *)semiCircleView {
    if (!_semiCircleView) {
        _semiCircleView = [[CBSemiCircleView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height, kfixSpace, kfixSpace) semiCircleViewType:SemiCircleViewTypeDefault];
    }
    return _semiCircleView;
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

- (CBWeChatFloatingBtn *)floatingBtn {
    if (!_floatingBtn) {
        _floatingBtn = [[CBWeChatFloatingBtn alloc] initWithFrame:CGRectMake(15.f, [UIScreen mainScreen].bounds.size.height/2-30.f, 60.f, 60.f)];
        _floatingBtn.delegate = self;
    }
    return _floatingBtn;
}
@end
