//
//  CWFinishedView.h
//  CloudWalkFaceForDev
//
//  Created by DengWuPing on 15/7/17.
//  Copyright (c) 2015年 dengwuping. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWFinishedView : UIView
//顶部的成功、失败 View
@property(nonatomic,retain) UIView  * errorView;
//subTitleLabel 成功、失败的描述
@property(nonatomic,retain) UILabel  * failedLabel;
//标题Label成功、失败
@property(nonatomic,retain) UILabel  * titleLabel;
//返回按钮
@property(nonatomic,retain) UIButton  * backButton;
//重新检测按钮
@property(nonatomic,retain) UIButton  * redoButton;
//确定按钮
@property(nonatomic,retain) UIButton  * suerButton;

@property(nonatomic,retain)  UIView*failedView;   //失败的view

@property(nonatomic,retain)  UIView*SucessView;  //成功的view

@property(nonatomic,assign)BOOL isHideStatuesBar;

/**
 *  @brief 禁用init方法 改用 initWithNibName:bundle
 *
 *  @return
 */
-(id)init NS_DEPRECATED_IOS(6_0,6_0,"Use -initWithFrame:WithIsSuccessed: instead");

//显示外面画的那个圆圈
-(void)showAnimation:(UIColor *)color;

//重写初始化方法 ,根据BOOL显示 成功还是失败
-(id)initWithFrame:(CGRect)frame WithIsSuccessed:(bool)isSuccessed;
@end
