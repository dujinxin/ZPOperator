//
//  CWCaptureController.h
//  CloudwalkBankCardOCR
//
//  Created by DengWuPing on 16/11/16.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudwalkBankCardOCR.h"

@protocol cwDetectCardEdgesDelegate <NSObject>

/**
 卡片对齐检测代理方法
 
 @param score     图像质量阈值
 @param cardImage 抠取的卡片图片
 */

-(void)cwCardEdgesDetect:(UIImage *)cardImage imageScore:(double)score;

@end

@interface CWBankCardCaptureController : UIViewController

//授权码 必须传入从云从科技获取的授权码
@property (nonatomic, strong) NSString  *  authCodeStr;

//预览Rect 预览大小默认是横屏全屏区域
@property (nonatomic, assign) CGRect previewRect;

//图像清晰度阈值 默认为0.65 推荐阈值为0.65-0.7
@property(nonatomic,assign)float qualityScore;

//银行卡类型 当前版本只支持银行卡
@property (nonatomic, assign) CWBankCardType cardType;

@property(nonatomic,assign)id<cwDetectCardEdgesDelegate>delegate;

@end
