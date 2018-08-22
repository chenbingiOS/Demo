//
//  CBAnimator.m
//  WeChatFloatingView
//
//  Created by 陈冰 on 2018/8/21.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import "CBAnimator.h"
#import "CBAnimationImageView.h"

@implementation CBAnimator

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 1.f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = transitionContext.containerView;

    // 正常Push进入，使用
    if (_operation == UINavigationControllerOperationPush)
    {
        /// transitionContext: fromView fromViewController toView toViewController containerVier
        /// A控制器 跳转的 B控制器
        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        [containerView addSubview:toView];

        CBAnimationImageView *theView = [[CBAnimationImageView alloc] initWithFrame:toView.bounds];
        [containerView addSubview:theView];
        // 截屏
        UIGraphicsBeginImageContext(toView.frame.size);
        [toView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        theView.screenImage = image;
        UIGraphicsEndImageContext();

        toView.hidden = YES;

        /// animationView 是从 floatingBtn 当前frame 展开到 toView.frame
        CGRect fromRect = CGRectMake(_curPoint.x, _curPoint.y, 60.f, 60.f);
        __block id <UIViewControllerContextTransitioning> tc = transitionContext;
        [theView startAnimationForView:toView fromRect:fromRect toRect:toView.frame completionBlock:^{
            // 展开完后移除
            [tc completeTransition:YES]; /// 移除fromView，fromViewController
        }];
    }
    // 弹出
    else if (_operation == UINavigationControllerOperationPop)
    {
        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        [containerView addSubview:toView];  // 容器底部
        UIView *fromView =[transitionContext viewForKey:UITransitionContextFromViewKey];
        [containerView bringSubviewToFront:fromView];   // 容器顶部
        UIView *floatingBtn = [UIApplication sharedApplication].keyWindow.subviews.lastObject;
        
        // 可交互动画
        if (_isInteractive) {
            [UIView animateWithDuration:0.3f animations:^{
                fromView.frame = CGRectOffset(fromView.frame, [UIScreen mainScreen].bounds.size.width, 0.f);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                if (!transitionContext.transitionWasCancelled) {
                    floatingBtn.alpha = 1.f;
                }
            }];
        }
        else // 非交互动画，缩小
        {
            CBAnimationImageView *theView = [[CBAnimationImageView alloc] initWithFrame:fromView.bounds];
            [containerView addSubview:theView];
            
            // 截屏
            UIGraphicsBeginImageContext(fromView.frame.size);
            [fromView.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            theView.screenImage = image;
            UIGraphicsEndImageContext();
            
            CGRect fromRect = fromView.frame;
            CGRect toRect = CGRectMake(_curPoint.x, _curPoint.y, 60.f, 60.f);
            [theView startAnimationForView:theView fromRect:fromRect toRect:toRect];
            
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            floatingBtn.alpha = 1.f;
        }
    }
    
}

@end
