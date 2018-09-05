//
//  CBFloatingManager.h
//  WeChatFloatingView
//
//  Created by 陈冰 on 2018/8/23.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CBFloatingManager : NSObject

+ (instancetype)sharedManager;

- (void)pushViewController:(UIViewController *)vc;
- (void)pushViewController:(UIViewController *)vc navCtrl:(UINavigationController *)navc;

@end
