//
//  CBWeChatFloatingManager.h
//  WeChatFloatingView
//
//  Created by hxbjt on 2018/8/22.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CBWeChatFloatingManager : NSObject 

+ (instancetype)sharedManager;
/** 添加需要显示浮窗的类，事先定义 */
- (void)addShowFloatingVCClass:(NSArray <NSString *> *)vcClasses;
/** 显示浮窗 */
+ (void)showWithViewController:(UIViewController *)vc;

@end
