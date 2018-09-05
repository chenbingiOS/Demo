//
//  CBQuarterCircleView.h
//  WeChatFloatingView
//
//  Created by 陈冰 on 2018/8/23.
//  Copyright © 2018年 ChenBing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CBQuarterCircleViewType) {
    CBQuarterCircleViewTypeDefault,
    CBQuarterCircleViewTypeCancel
};

@interface CBQuarterCircleView : UIView

- (instancetype)initWithFrame:(CGRect)frame quarterCircleViewType:(CBQuarterCircleViewType)quarterCircleViewType;

@end
