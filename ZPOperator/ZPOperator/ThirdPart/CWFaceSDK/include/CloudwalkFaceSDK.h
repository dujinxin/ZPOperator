//
//  CloudwalkFaceSDK.h
//  CloudwalkFaceSDK
//
//  Created by DengWuPing on 16/5/10.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CloudwalkFaceSDKDef.h"
#import "CloudwalkCardUtil.h"

//人脸检测和活体检测的代理方法

@protocol cwDelegate <NSObject>

/**
 *  活体检测代理方法
 *  @param contextType        活体动作通过与否的编码
 *  @param imageData          活体通过时的人脸图片数据 JPG格式的
 *  @param message      当前动作通过与否的提示信息
 */

@optional
-(void)cwLivessInfoCallBack:(CW_LivenessCode)contextType liveImage:( NSData  * __nullable)imageData message:(NSString * __nullable)message;

/**
 *  人脸信息返回代理方法
 *  @param personsArry    人脸信息字典
 */

@optional
-(void)cwFaceInfoCallBack:(NSArray *__nullable)personsArry;

@end


@interface CloudwalkFaceSDK : NSObject


@property(nonatomic,weak)id  <cwDelegate> delegate;

/**
 *  单例方法
 *
 *  @return 返回CloudwalkFaceSDK的一个单例
 */

+(instancetype __nonnull)shareInstance;

#pragma mark
#pragma mark-----------cwInit SDK初始化

/**
 *  人脸SDK初始化
 *  @param AuthCodeStr  授权码
 *  @return       0成功 非0失败 错误码
 */
-(NSInteger)cwInit:(NSString * __nonnull)AuthCodeStr;

#pragma mark
#pragma mark-----------cwSetParamMaxFaceNumber 算法参数设置
/**
 *  @brief 算法参数设置
 *
 *  @param maxFaceNumber 设置最大检测人脸个数
 *  @param minSize       检测的最小人脸框 默认设置为100
 *  @param maxSize       检测最大人脸框   默认设置为400
 *  @param perfmonLevel  效率等级1-5，默认值为2
 *  @return       0成功，非0错误码
 */

-(NSInteger)cwSetParamMaxFaceNumber:(int)maxFaceNumber minFaceSize:(int)minSize maxFaceSize:(int)maxSize   perfmonLevel:(int)perfmonLevel; //建议使用默认参数

/**
 *  @brief 重置参数
 */
-(void)cwresetParam;

#pragma mark
#pragma mark-----------cwDestroy 释放资源
/**
 *  @brief 释放资源（在退出页面时调用销毁，和cwinit配套使用）
 *
 */

-(void)cwDestroy;


#pragma mark
#pragma mark-----------cwPushFrame push摄像头获取的每一帧图片
/**
 *  push摄像头获取的每一帧图片
 *  @param bufferType   视频流格式 CWFaceBufferBGRA,// BGRA    kCVPixelFormatType_32BGRA
 *  @param sampleBuffer   视频流数据
 *  @param direction   屏幕方向
 *  @return 返回0成功
 */

-(NSInteger)cwPushFrame:(CWFaceBufferType)bufferType screenDirection:(CWScreenDirection)direction  frameBuffer:(__nonnull CMSampleBufferRef)sampleBuffer;


#pragma mark
#pragma mark-----------cwGetBestFaceImage 获取最佳人脸和最佳人脸下一帧
/**
 获取最佳人脸Block
 
 @param originalData 最佳人脸原始图片
 @param bestFaceData 最佳人脸裁剪图片
 @param keyPointArray 最佳人脸原始图片关键点数组
 @param headPoseArray 最佳人脸图片头部角度数组、pitch俯仰角、yaw水平角度 roll偏转角度
 */
typedef void(^BestFaceBlock )(NSData * __nullable originalData,NSData  * __nullable bestFaceData,NSArray   * __nullable keyPointArray, NSArray  * __nullable headPoseArray);

/**
 *  获取最佳人脸
 */

-(void)cwGetBestFaceImage:(BestFaceBlock __nullable)block;

/**
 *  获取最佳人脸下一帧 以及关键点角度 用作后端防攻击 （需要在cwGetBestFaceImage之后调用）
 */
-(void)cwGetBestFaceNextFrame:(BestFaceBlock __nullable)block;


#pragma mark
#pragma mark-----------cwStartLiveDetect 启动活体检测

/**
 *  启动活体检测
 *  @param detectType     传入活体动作的类型
 */

-(NSInteger)cwStartLivess:(CWLiveDetectType)detectType;

#pragma mark
#pragma mark-----------cwStoptLiveDetect 停止活体检测
/**
 *  停止活体检测
 */
-(void)cwStoptLivess;


-(NSInteger)cwGetHackerInfoByBestImage;

#pragma mark
#pragma mark-----------cwFaceImageQuality 图片人脸检测
/**
 *  @brief 图片人脸检测
 *  @param score 图片质量分数
 *  @param idImage 抠取的人脸图像
 */

typedef void(^cwFaceImageQualityBlock)(double score,UIImage *  __nullable idImage,CGRect  rect);

/**
 *  @brief 图片检测
 *  @param faceImage 人脸图片JPG
 *  @param block  图片质量检测结果返回
 */

-(void)cwFaceImageQuality:(UIImage * __nonnull)faceImage completion:(cwFaceImageQualityBlock __nullable)block;

#pragma mark
#pragma mark-----------cwGetVersion 获取人脸SDK版本信息
/**
 *  @brief 获取SDK版本信息
 *
 *  @return 返回算法SDK版本信息
 */
-(NSString * __nullable)cwGetVersion;



@end

