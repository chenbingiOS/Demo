//
//  CBInteractiveTransition.m
//  WeChatFloatingView
//
//  Created by 陈冰 on 2018/8/21.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import "CBInteractiveTransition.h"
#import "CBAnimationImageView.h"

@interface CBInteractiveTransition () {
    UIViewController *presentedViewController;
    BOOL shouldComplete;
    CGFloat transitionX;
}

@end

@implementation CBInteractiveTransition

- (void)transtionToViewController:(UIViewController *)toViewController {
    presentedViewController = toViewController;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(actionPanGesture:)];
    [toViewController.view addGestureRecognizer:panGesture];
}

- (void)actionPanGesture:(UIPanGestureRecognizer *)gesture {
    UIView *floatingBtn = [UIApplication sharedApplication].keyWindow.subviews.lastObject;
    UINavigationController *navc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            _isInteractive = YES;
            [navc popViewControllerAnimated:YES];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            // 监听当前页面的滑动距离
            CGPoint transitionPoint = [gesture translationInView:presentedViewController.view];
            CGFloat ratio = transitionPoint.x / [UIScreen mainScreen].bounds.size.width;
            transitionX = transitionPoint.x;
            
            // 获得 floationBtn，修改它的alpha的值
            floatingBtn.alpha = ratio;
            if (ratio >= 0.5) {
                shouldComplete = YES;
            } else {
                shouldComplete = NO;
            }
            
            [self updateInteractiveTransition:ratio];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (shouldComplete) {
                // 截图
                UIView *fromView = presentedViewController.view;
                CBAnimationImageView *theView = [[CBAnimationImageView alloc] initWithFrame:fromView.bounds];
                UIGraphicsBeginImageContext(fromView.bounds.size);
                [fromView.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                theView.image = image;
                UIGraphicsEndImageContext();
                fromView.frame = CGRectZero;
                [fromView.superview addSubview:theView];
                
                // 缩小动画
                CGRect fromRect = fromView.frame;
                fromRect.origin.x = transitionX;
                fromRect.origin.y = 0.f;
                CGRect toRect = CGRectMake(_curPoint.x, _curPoint.y, 60.f, 60.f);
                [theView startAnimateWithView:theView fromRect:fromRect toRect:toRect];
                
                [self finishInteractiveTransition];
                navc.delegate = nil; //这个需要设置，而且只能在这里设置，不能在外面设置
            } else {
                floatingBtn.alpha = 0.f;
                [self cancelInteractiveTransition];
            }
            _isInteractive = NO;
        }
            break;
        default:
            break;
    }
}

@end
