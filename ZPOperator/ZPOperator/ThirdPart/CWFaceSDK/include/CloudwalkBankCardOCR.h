//
//  CWBankCardOCR.h
//  CWBankCardOCR
//
//  Created by DengWuPing on 16/11/7.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "CloudwalkCardUtil.h"


@interface CloudwalkBankCardOCR : NSObject

//横竖版扫描（默认为横版扫描模式）
@property(nonatomic,assign)CWDeviceOrientation deviceOrientaion;

/**
 单例方法
 @return 返回该对象的实例
 */

+(id _Nullable )sharInstance;

/**
 创建检测句柄
 
 @return 返回检测句柄
 */
-(NSInteger)cwCreateCardHandle:(NSString * _Nonnull)lisence;

/**
 设置卡片类型 (需在调用cwCreateCardHandle之后调用该方法)
 
 @param cardType 卡片类型（支持身份证正反面和银行卡正面）
 @return 0成功非0错误码
 */
-(NSInteger)cwSetCardType:(CWBankCardType)cardType;

/**
 销毁卡片对齐句柄
 
 @return 返回释放结果
 */
-(NSInteger)cwDestroyCardHandle;

/**
 卡片边对齐检测
 @param sampleBuffer 视频帧
 @param bufferType   视频帧格式
 @param begainPoint  起点坐标
 @param endPoint     终点坐标（通过起点和终点确定4条边）
 @param block        对齐结果block返回
 */
-(void)cwDetectCardEdges:(CMSampleBufferRef _Nonnull)sampleBuffer bufferType:(CWCardAliginBufferType)bufferType beginPoint:(CGPoint)begainPoint  endPoint:(CGPoint)endPoint completionBlock:(CWDetectCardEdgesBlock _Nullable)block;

/**
 获取对齐的卡片图像    该函数应在调用cwDetectCardEdges并且卡片四边都找到的情况下调用，否则会返回失败。
 @param block        结果返回
 */
-(void)cwGetAlignCardImage:(CWCardQualityBlock _Nullable)block;

/**
 获取卡片对齐SDK版本号
 
 @return 返回版本号
 */
+(NSString * _Nullable)cwGetCardFrontVersion;

@end
