//
//  CBAnimationImageView.h
//  WeChatFloatingView
//
//  Created by hxbjt on 2018/8/21.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import <UIKit/UIKit.h>

// 转场
@interface CBAnimationImageView : UIImageView

- (void)startAnimateWithView:(UIView *)theView fromRect:(CGRect)fromRect toRect:(CGRect)toRect;

@end
