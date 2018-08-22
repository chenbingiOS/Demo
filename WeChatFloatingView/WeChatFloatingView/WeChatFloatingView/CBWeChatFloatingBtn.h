//
//  CBWeChatFloatingBtn.h
//  WeChatFloatingView
//
//  Created by 陈冰 on 2018/8/21.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CBWeChatFloatingBtnDelegate <NSObject>

- (void)pushContainerVCWithWeChatFloatingBtn:(UIView *)floatingBtn;

@end

@interface CBWeChatFloatingBtn : UIView

@property (nonatomic, strong) id <CBWeChatFloatingBtnDelegate> delegate;

/** 显示浮窗 */
+ (void)showWithViewController:(UIViewController *)vc;
- (void)cshowWithViewController:(UIViewController *)vc;
/** 移除浮窗 */
+ (void)remove;

/** 判断浮窗是否展示 */
+ (BOOL)isShowingWithViewController:(UIViewController *)vc;

@end
