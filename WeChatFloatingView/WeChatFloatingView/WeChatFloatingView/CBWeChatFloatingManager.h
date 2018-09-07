//
//  CBWeChatFloatingManager.h
//  WeChatFloatingView
//
//  Created by hxbjt on 2018/8/22.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 仿微信浮窗功能
 
 1. 浮窗的展示：浮窗按钮和右下角四分之一圆的实现和布局
 2. 浮窗的拖动效果：上下拖动可以到屏幕边缘。
 左右拖动过程中，根据左右两边的距离，回弹到最近的一边。
 浮窗点击能够跳转页面。
 拖动过程中右下方四分之一圆能够动画展示出来。
 浮窗拖动到右下方四分之一圆范围后松手，浮窗消失。
 3. 点击浮窗，进入浮窗页面的展开动画效果
 4. 关闭浮窗页面的收缩动画效果
 5. 浮窗也没买手势往右边侧滑，超过1/2页面后松开，收缩动画效果
 */

@interface CBWeChatFloatingManager : NSObject 

+ (instancetype)sharedManager;
/** 添加需要显示浮窗的类，事先定义 */
- (void)addShowFloatingVCClass:(NSArray <NSString *> *)vcClasses;
/** 显示浮窗 */
+ (void)showWithViewController:(UIViewController *)vc;

@end
