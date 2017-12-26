//
//  CWCaptureController.h
//  CloudwalkBankCardOCR
//
//  Created by DengWuPing on 16/11/16.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudwalkIDCardOCR.h"
#import "CloudwalkCardUtil.h"

@protocol cwIdCardRecoDelegate <NSObject>

/**
 身份证识别代理方法
 
 @param cardImage   身份证矫正图片
 @param score  获取的卡片质量分数
 */
-(void)cwIdCardDetectionCardImage:(UIImage *)cardImage imageScore:(double)score;

@end

@interface CWIDCardCaptureController : UIViewController

//预览显示大小
@property (nonatomic, assign) CGRect previewRect;

//授权码 必须传入从云从科技获取的授权码
@property(nonatomic,strong)NSString  * lisenceStr;

//身份证人像面和国徽面  人像面为CWIDCardTypeFront 国徽面为CWIDCardTypeBack 在检测时需要传入对应的type
@property(nonatomic,assign)CWIDCardType  type;

//图像清晰度阈值 默认为0.65 推荐阈值为0.65-0.7
@property(nonatomic,assign)float cardQualityScore;

//扫描对齐检测获取图片之后的代理
@property(nonatomic,assign)id<cwIdCardRecoDelegate>  delegate;

@end
