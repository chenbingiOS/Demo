//
//  CBInteractiveTransition.h
//  WeChatFloatingView
//
//  Created by 陈冰 on 2018/8/21.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import <UIKit/UIKit.h>

// 侧滑手势拦截，到1/2做判断
@interface CBInteractiveTransition : UIPercentDrivenInteractiveTransition

@property (nonatomic, assign) BOOL isInteractive;
@property (nonatomic, assign) CGPoint curPoint;

- (void)transtionToViewController:(UIViewController *)toViewController;

@end
