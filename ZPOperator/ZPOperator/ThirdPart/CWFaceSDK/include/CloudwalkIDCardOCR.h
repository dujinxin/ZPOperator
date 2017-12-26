//
//  CWIDCardOCR.h
//  CWIDCardOCR
//
//  Created by DengWuPing on 16/11/7.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CloudwalkCardUtil.h"

@interface CloudwalkIDCardOCR : NSObject

//横竖版扫描（默认为横版扫描模式）
@property(nonatomic,assign)CWDeviceOrientation deviceOrientaion;

/**
 单例方法
 @return 返回该对象的实例
 */

+(id _Nullable)sharInstance;

/**
 创建检测句柄

 @return 返回身份证检测句柄
 */
-(NSInteger)cwCreateIdCardRecog:(NSString * _Nonnull)lisence;

/**
 设置卡片类型 (需在调用cwCreateCardHandle之后调用该方法)
 
 @param cardType 卡片类型（身份证正反面）
 @return 0成功非0错误码
 */
-(NSInteger)cwSetCardType:(CWIDCardType)cardType;

/**
 销毁身份证识别句柄

 @return 返回释放结果
 */
-(NSInteger)cwDestroyIdCardRecog;

/**
 身份证图像帧检测
 
 @param sampleBuffer 采集的身份证图像帧
 @param bufferType   图像帧格式BGRA或者YUV420
 @param block        检测结果返回
 */
-(void)cwDetectIdCard:(CMSampleBufferRef _Nonnull)sampleBuffer bufferType:(CWCardAliginBufferType)bufferType  beginPoint:(CGPoint)begainPoint  endPoint:(CGPoint)endPoint completionBlock:(CWDetectCardEdgesBlock _Nullable)block;

/**
 获取对齐的卡片图像    该函数应在调用cwDetectCardEdges并且卡片四边都找到的情况下调用，否则会返回失败。
 @param block        结果返回
 */
-(void)cwGetAlignCardImage:(CWCardQualityBlock _Nullable)block;

/**
 获取身份证识别SDK版本号

 @return 返回版本号
 */
+(NSString * _Nullable)cwGetIdCardVersion;

@end
