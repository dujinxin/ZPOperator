//
//  CloudwalkProgressView.h
//  CloudwalkProgressView
//
//  Created by DengWuPing on 15/7/17.
//  Copyright (c) 2015年 dengwuping. All rights reserved.

#import <UIKit/UIKit.h>

@interface CWProgressView : UIView

@property (nonatomic) double progress;

@property (nonatomic) NSInteger showText UI_APPEARANCE_SELECTOR;

@property (nonatomic) NSInteger roundedHead UI_APPEARANCE_SELECTOR;

@property (nonatomic) NSInteger showShadow UI_APPEARANCE_SELECTOR;

@property (nonatomic) NSInteger progressText UI_APPEARANCE_SELECTOR;

@property (nonatomic) CGFloat thicknessRatio UI_APPEARANCE_SELECTOR;
//内部背景颜色
@property (nonatomic, strong) UIColor *innerBackgroundColor UI_APPEARANCE_SELECTOR;
//外围圆背景颜色
@property (nonatomic, strong) UIColor *outerBackgroundColor UI_APPEARANCE_SELECTOR;
//文字颜色
@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
//倒计时文字字体
@property (nonatomic, strong) UIFont *font UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *progressFillColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *progressTopGradientColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *progressBottomGradientColor UI_APPEARANCE_SELECTOR;

@end
