//
//  CBAnimationImageView.h
//  WeChatFloatingView
//
//  Created by hxbjt on 2018/8/21.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import <UIKit/UIKit.h>

// 转场截图遮罩动画
@interface CBAnimationImageView : UIView

@property (nonatomic, strong) UIImage *screenImage;

- (void)startAnimationForView:(UIView *)theView fromRect:(CGRect)fromRect toRect:(CGRect)toRect;
- (void)startAnimationForView:(UIView *)theView fromRect:(CGRect)fromRect toRect:(CGRect)toRect completionBlock:(void(^)(void))completionBlock;
@end
