//
//  CBFloatingManager.m
//  WeChatFloatingView
//
//  Created by 陈冰 on 2018/8/23.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import "CBFloatingManager.h"
#import "CBFloatingView.h"
#import "CBQuarterCircleView.h"

#define kfixSpace 145.f

@interface CBFloatingManager () <UINavigationControllerDelegate, UIGestureRecognizerDelegate> {
    BOOL isShowFloatingBtn;
    BOOL shouldComplete;
}
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgePan;
@property (nonatomic, strong) UIViewController *containerVC;
@property (nonatomic, strong) UINavigationController *naVC;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) CBFloatingView *floatingView; ///< 浮窗
@property (nonatomic, strong) CBQuarterCircleView *openQuarterCircleView; /// < 开启浮窗
@property (nonatomic, strong) CBQuarterCircleView *closeQuarterCircleView; /// < 关闭浮窗

@end

@implementation CBFloatingManager

+ (instancetype)sharedManager {
    static CBFloatingManager *floatingManger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        floatingManger = [[super allocWithZone:nil] init];
        [floatingManger setupWindow];
    });
    return floatingManger;
}

- (void)setupWindow {
    if (!self.closeQuarterCircleView.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.closeQuarterCircleView];
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.closeQuarterCircleView];
    }
    if (!self.openQuarterCircleView.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.openQuarterCircleView];
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.openQuarterCircleView];
    }
    if (!self.floatingView.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.floatingView];
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.floatingView];
    }
}

#pragma mark - layz
- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkActionEdgePan:)];
    }
    return _displayLink;
}

- (CBQuarterCircleView *)openQuarterCircleView {
    if (!_openQuarterCircleView) {
        _openQuarterCircleView = [[CBQuarterCircleView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height, kfixSpace, kfixSpace) quarterCircleViewType:CBQuarterCircleViewTypeDefault];
    }
    return _openQuarterCircleView;
}

- (CBQuarterCircleView *)closeQuarterCircleView {
    if (!_closeQuarterCircleView) {
        _closeQuarterCircleView = [[CBQuarterCircleView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height, kfixSpace, kfixSpace) quarterCircleViewType:CBQuarterCircleViewTypeCancel];
    }
    return _closeQuarterCircleView;
}

- (CBFloatingView *)floatingView {
    if (!_floatingView) {
        _floatingView = [[CBFloatingView alloc] initWithFrame:CGRectMake(15.f, [UIScreen mainScreen].bounds.size.height/2-30.f, 60.f, 60.f)];
    }
    return _floatingView;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (self.naVC.viewControllers.count == 1) {
        return NO;
    } else {
        {
            NSLog(@"侧滑手势拦截");
            NSString *className = NSStringFromClass([self.containerVC class]);
            if ([className isEqualToString:@"SecondViewController"]) {
                self.edgePan = (UIScreenEdgePanGestureRecognizer *)gestureRecognizer;
                [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            }
        }
        return YES;
    }
}


#pragma mark - UINavigationControllerDelegate

//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
//    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        navigationController.interactivePopGestureRecognizer.enabled = YES;
//    }
//    //使navigationcontroller中第一个控制器不响应右滑pop手势
//    if (navigationController.viewControllers.count == 1) {
//        navigationController.interactivePopGestureRecognizer.enabled = NO;
//        navigationController.interactivePopGestureRecognizer.delegate = nil;
//    }
//}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    
    if (operation == UINavigationControllerOperationPush) {
        NSLog(@"拦截 UINavigationControllerOperationPush");
    }
    if (operation == UINavigationControllerOperationPop) {
        NSLog(@"拦截 UINavigationControllerOperationPop");
    }
    if (operation == UINavigationControllerOperationNone) {
        NSLog(@"拦截 UINavigationControllerOperationNone");
    }
    return nil;
}

//- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
//                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
//    return nil;
//}

- (void)displayLinkActionEdgePan:(CADisplayLink *)displayLink {
    NSLog(@"%s",__func__);
    if (self.edgePan.state == UIGestureRecognizerStateBegan) {
    }
    else if (self.edgePan.state == UIGestureRecognizerStateChanged) {
        
        // 浮窗未显示时
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        CGPoint tPoint = [self.edgePan translationInView:keyWindow];
        CGFloat x = MAX([UIScreen mainScreen].bounds.size.width + 30 - tPoint.x, [UIScreen mainScreen].bounds.size.width - kfixSpace);
        CGFloat y = MAX([UIScreen mainScreen].bounds.size.height + 30 - tPoint.x, [UIScreen mainScreen].bounds.size.height - kfixSpace);
        CGRect rect = CGRectMake(x, y, kfixSpace, kfixSpace);
        self.openQuarterCircleView.frame = rect;
        
        // 做坐标转化，当手指移入到 openQuarterCircleView 范围内部为正值
        CGPoint pointByWindow = [self.edgePan locationInView:keyWindow];
        CGPoint touchPoint = [keyWindow convertPoint:pointByWindow toView:self.openQuarterCircleView];
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
        
        // 获得 floationBtn，修改它的alpha的值
        CGFloat ratio = tPoint.x / [UIScreen mainScreen].bounds.size.width;
        self.floatingView.alpha = ratio;
        if (ratio >= 0.5) {
            shouldComplete = YES;
        } else {
            shouldComplete = NO;
        }
        
    }
    else if (self.edgePan.state == UIGestureRecognizerStatePossible) {
        // 关闭定时器
        [self.displayLink invalidate];
        self.displayLink = nil;
        
        if (shouldComplete) {
            // 出栈
//            [self popViewController:nil];
            [self.naVC popViewControllerAnimated:NO];

        }
        else  // 取消关闭
        {
            self.floatingView.alpha = 0.f;
        }
        
        // 关闭浮窗
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.3f animations:^{
            weakSelf.openQuarterCircleView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height, kfixSpace, kfixSpace);
        }];
    }
}

#pragma mark - Public

- (void)pushViewController:(UIViewController *)vc navCtrl:(UINavigationController *)navc {
//    self.containerVC = vc;
    self.naVC = navc;
    self.naVC.delegate = self;
    self.naVC.interactivePopGestureRecognizer.delegate = self;
    [navc pushViewController:vc animated:YES];
}


- (void)pushViewController:(UIViewController *)vc {
    self.containerVC = vc;

    UINavigationController *navc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [navc pushViewController:self.containerVC animated:YES];
}

- (void)popViewController:(UIViewController *)vc {
    self.containerVC = nil;
}

@end
