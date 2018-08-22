//
//  CBAnimator.h
//  WeChatFloatingView
//
//  Created by 陈冰 on 2018/8/21.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 转场动画工具类
@interface CBAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) CGPoint curPoint;
@property (nonatomic, assign) UINavigationControllerOperation operation;
@property (nonatomic, assign) BOOL isInteractive;

@end
