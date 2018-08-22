//
//  CBWeChatFloatingManager.m
//  WeChatFloatingView
//
//  Created by hxbjt on 2018/8/22.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import "CBWeChatFloatingManager.h"
#import "CBSemiCircleView.h"

#define kfixSpace 160.f

@interface CBWeChatFloatingManager () <UINavigationControllerDelegate, UIGestureRecognizerDelegate> {
    UIScreenEdgePanGestureRecognizer *edgePan;
}
@property (nonatomic, strong) NSMutableArray <NSString *> *floatingVCClass;
@property (nonatomic, strong) UIViewController *containerVC;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) CBSemiCircleView *semiCircleView;

@end

@implementation CBWeChatFloatingManager

+ (instancetype)sharedManager {
    static CBWeChatFloatingManager *floatingManger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        floatingManger = [[super allocWithZone:nil] init];
        floatingManger.floatingVCClass = [NSMutableArray array];
        UINavigationController *navc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        navc.delegate = floatingManger;
        navc.interactivePopGestureRecognizer.delegate = floatingManger;
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
    UIViewController *vc = navc.visibleViewController;
    if ([self.floatingVCClass containsObject:NSStringFromClass([vc class])]) {
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
    if (edgePan.state == UIGestureRecognizerStateChanged) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        CGPoint tPoint = [edgePan translationInView:keyWindow];
        CGFloat x = MAX([UIScreen mainScreen].bounds.size.width + 30 - tPoint.x, [UIScreen mainScreen].bounds.size.width - kfixSpace);
        CGFloat y = MAX([UIScreen mainScreen].bounds.size.height + 30 - tPoint.x, [UIScreen mainScreen].bounds.size.height - kfixSpace);
        CGRect rect = CGRectMake(x, y, kfixSpace, kfixSpace);
        self.semiCircleView.frame = rect;
        
//        CGPoint touchPoint = [kWindow convertPoint:[self.edgePan locationInView:kWindow] toView:self.floatArea];
//
//        if (touchPoint.x > 0 && touchPoint.y > 0) {
//            if (!self.showFloatBall) {
//                if (pow((kFloatAreaR - touchPoint.x), 2) + pow((kFloatAreaR - touchPoint.y), 2) <= pow((kFloatAreaR), 2)) {
//                    self.showFloatBall = YES;
//                } else {
//                    if (self.showFloatBall) {
//                        self.showFloatBall = NO;
//                    }
//                }
//            }
//        } else {
//            if (self.showFloatBall) {
//                self.showFloatBall = NO;
//            }
//        }
    }
    else if (edgePan.state == UIGestureRecognizerStatePossible) {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.3f animations:^{
            weakSelf.semiCircleView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height, kfixSpace, kfixSpace);
        } completion:^(BOOL finished) {
            [weakSelf.semiCircleView removeFromSuperview];
            weakSelf.semiCircleView = nil;
            [weakSelf.displayLink invalidate];
            weakSelf.displayLink = nil;
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
        _semiCircleView.backgroundColor = [UIColor redColor];
    }
    return _semiCircleView;
}
@end
