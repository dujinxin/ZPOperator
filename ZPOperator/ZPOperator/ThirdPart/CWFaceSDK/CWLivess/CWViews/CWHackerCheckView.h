//
//  CWHackerCheckView.h
//  CloudwalkFaceSDKDemo
//
//  Created by DengWuPing on 16/12/9.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import <UIKit/UIKit.h>

//颜色
#define CWHacker_ColorFromRGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

@interface CWHackerCheckView : UIView

/**
 *  @brief 确定按钮
 */
@property(nonatomic,strong) UIButton  * suerButton;

/**
 *  @brief 前端检测提示label
 */
@property(nonatomic,strong) UILabel  * topLabel;

/**
 *  @brief 后端防hack攻击检测label
 */
@property(nonatomic,strong) UILabel  * bottomLabel;

/**
 *  @brief 前端检测imageView
 */
@property(nonatomic,strong) UIImageView  * topImageView;

/**
 *  @brief 后端防hack攻击检测imageView
 */
@property(nonatomic,strong) UIImageView  * bottomImageView;


/**
 初始化方法

 @param frame frame
 @return 返回 CWHackerCheckView实例
 */
-(id)initWithFrame:(CGRect)frame;


/**
 设置检测成功、失败的图和提示语

 @param isDetectFaild 前端检测是否成功
 @param isHackerFailed 后端防hack攻击是否成功
 */
-(void)cwSetFrontDetectFailed:(BOOL)isDetectFaild  hackerDetect:(BOOL)isHackerFailed;

@end
