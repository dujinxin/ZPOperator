//
//  LiveDetectViewController.h
//  CloudwalkFaceSDKDemo
//
//  Created by DengWuPing on 16/5/12.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudwalkFaceSDK.h"
#import "CWCamera.h"
//活体检测代理
@protocol cwIntegrationLivessDelegate <NSObject>

/**
 *  @brief 活体检测代理方法
 *
 *  @param isAlive 是否是活体 (活体检测是否通过的盘班)
 *  @param code 返回当前步骤状态码
 *  @param bestFaceData 获取的最佳人脸图片
 *  @param jsonStr    后端防hack攻击加密字符串（此字符串已按照接口文档封装好，调用后端防攻击接口时直接post该字符串即可）
 
 */
-(void)cwIntergrationLivess:(BOOL)isAlive   errorCode:(NSInteger)code BestFaceImage:(NSData  * _Nullable)bestFaceData encryptJson:(NSString * _Nullable)jsonStr;

@end

@interface CWLivessViewController : UIViewController
/**
 *  @brief 代理
 */
@property(nonatomic,weak) id <cwIntegrationLivessDelegate> _Nullable delegate;

/**
 *  @brief SDK授权码 （必须传入正确的授权码）
 */
@property(nonatomic,strong)NSString *  _Nonnull authCodeString;

/**
 *  @brief 总的活体动作数组
 */
@property(nonatomic,strong)NSArray  * _Nullable allActionArry;

/**
 *  @brief 活体个数
 */
@property(nonatomic,assign)NSInteger livessNumber;

/**
 *  @brief 是否显示结果页面（检测成功、失败的View）
 */
@property(nonatomic,assign)BOOL isShowResultView;

/**
 *  @brief 是否在活体检测的过程中录制视频  默认为NO 
 */
@property(nonatomic,assign)BOOL isRecord;

/**
 *  @brief 视频存储地址 默认地址为  [NSString stringWithFormat:@"%@/Documents/cwLivessDetect.mp4",NSHomeDirectory()];
 */
@property(nonatomic,strong)NSString * _Nullable videoPath;

/**
 *  @brief 视频尺寸大小 默认为480 *640 如果要求小一点则可以设置成240 *320
 */
@property(nonatomic,assign)CWVideoSizeMode videoSizeMode;

#pragma mark
#pragma mark-------------  setLivessParam  设置活体检测参数
/**
 *  @brief 设置活体检测参数
 *
 *  @param authCode       SDK授权码   
  （必须传入从云从科技获取的正确的授权码）
 
 *  @param activeNumber   活体动作个数 
 （可设置1-6个活体动作  默认为3个动作）
 
 *  @param isShowResult   是否显示结果页面  
 （检测成功、失败的View）
   */

-(void)setLivessParam:(NSString * _Nonnull)authCode livessNumber:(NSInteger)activeNumber  isShowResultView:(BOOL)isShowResult ;

@end
