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
    /// transitionContext: fromView fromViewController toView toViewController containerVier
    /// A控制器 跳转的 B控制器
    UIView *containerView = transitionContext.containerView;
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    [containerView addSubview:toView];
    
    CBAnimationImageView *animationView = [[CBAnimationImageView alloc] initWithFrame:toView.bounds];
    [containerView addSubview:animationView];
    
    // 截屏
    UIGraphicsBeginImageContext(toView.frame.size);
    [toView.layer renderInContext:UIGraphicsGetCurrentContext()];
    animationView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    toView.hidden = YES;
    
    /// animationView 是从 floatingBtn 当前frame 展开到 toView.frame
    [animationView startAnimateWithView:toView fromRect:_curFrame toRect:toView.frame];

    // 展开完后移除
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [transitionContext completeTransition:YES]; /// 移除fromView，fromViewController
    });
}

@end
