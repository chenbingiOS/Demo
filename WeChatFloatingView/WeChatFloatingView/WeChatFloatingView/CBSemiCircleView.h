//
//  CBSemiCircleView.h
//  WeChatFloatingView
//
//  Created by hxbjt on 2018/8/21.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SemiCircleViewType) {
    SemiCircleViewTypeDefault,
    SemiCircleViewTypeCancel
};

// 四分之一圆
@interface CBSemiCircleView : UIView

- (instancetype)initWithFrame:(CGRect)frame semiCircleViewType:(SemiCircleViewType)semiCircleViewType;
    
@end
