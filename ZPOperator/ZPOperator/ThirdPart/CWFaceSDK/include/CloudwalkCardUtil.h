//
//  CWCardUtil.h
//  CloudwalkFaceSDK
//
//  Created by DengWuPing on 17/1/16.
//  Copyright © 2017年 DengWuPing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

/**
 视频帧格式
 */
typedef NS_ENUM(NSUInteger, CWCardAliginBufferType) {
    CWCardAliginBufferTypeBGRA =2, //BGRA格式
    CWCardAliginBufferTypeYUV, //YUV格式
};

/**
 身份证类型
 */
typedef NS_ENUM(NSUInteger, CWIDCardType) {
    CWIDCardTypeBack = 0, //身份证反面
    CWIDCardTypeFront, //身份证正面
    CWIDCardTypeError, //错误的身份证类型
};

/**
 银行卡类型
 */
typedef NS_ENUM(NSUInteger, CWBankCardType) {
    CWBankCardTypeFront = 2, //银行卡正面
    CWBankCardTypeBack = 3, //银行卡反面(当前版本不支持银行卡反面识别)
};

typedef NS_ENUM(NSInteger,CWDeviceOrientation){
    CWDeviceOrientationPotrait =0, //竖版扫描
    CWDeviceOrientationLandScape, //横版扫描 （默认使用横版扫描）
};


/**
 结果返回
 */
typedef NS_ENUM(NSInteger,CWCardDetectRet) {
    CWCardDetectRetUnKnownErr =-4, //-4：其他错误
    CWCardDetectRetImageTooSmall, //-3：图像模糊或卡片所占尺寸过小。要求图像中身份证、银行卡的长宽应大于400x350
    CWCardDetectRetParamIllegal,             //-2：参数不合法
    CWCardDetectRetAuthorizedErr,  //-1：授权失败
    CWCardDetectRetOk,           //0：成功
};


/**
 检测帧图片是否对齐的block
 
 @param ret           检测结果返回
 @param isTopAlign    顶部边是否对齐
 @param isBottomAlign 底部边是否对齐
 @param isLeftAlign   左边是否对齐
 @param isRightAlign  右边是否对齐
 */
typedef void(^CWDetectCardEdgesBlock)(CWCardDetectRet ret,BOOL isTopAlign,BOOL isBottomAlign,BOOL isLeftAlign,BOOL isRightAlign);

/**
 卡片质量检测返回Block
 @param ret           检测结果返回
 @param cardImage     卡片对齐图片
 @param score         图片质量分数 0-1 值越大表示越清晰
 */
typedef void(^CWCardQualityBlock)(CWCardDetectRet ret,double score,UIImage *  cardImage);


@interface CloudwalkCardUtil : NSObject


/**
 从sampleBuffer中提取帧图片
 @param frameData      帧图片数据
 @param width          图片宽
 @param height         图片高
 @param bytesPerRow    每一行的数据  宽*4
 */
typedef void(^CWSampleBufferBlock)(unsigned char * frameData,int width,int height,size_t bytesPerRow);

/**
 获取视频帧图像数据
 
 @param sampleBuffer 视频帧
 @param bufferType   视频帧格式
 @param block        结果返回
 */
+(void)cwGetFrameFromSampleBuffer:(CMSampleBufferRef)sampleBuffer bufferType:(CWCardAliginBufferType)bufferType completionBlock:(CWSampleBufferBlock)block;

#pragma mark
#pragma mark -----------getImageFromBGRA BGRA转uiimage
/**
 *  @brief BGRA转uiimage
 *
 *  @param sampleBuffer BGRA视频流
 *
 *  @return UIImage
 */

+(UIImage *)getImageFromBGRA:(CMSampleBufferRef)sampleBuffer bufferType:(CWCardAliginBufferType)bufferType;


#pragma mark
#pragma mark -----------getImageFromBGRA BGRA转uiimage
/**
 *  @brief BGRA转uiimage
 *
 *  @param sampleBuffer BGRA视频流
 *
 *  @return UIImage
 */

+(UIImage *)getImageFromBGRA:(UInt8 *)imageAddress width:(size_t)width height:(size_t)height bytesPerRow:(size_t)bytesPerRow;


+(unsigned char *)convertUIImageToBitmapRGBA8:(UIImage *) image;

#pragma mark
#pragma mark -----------convertBitmapRGBA8ToUIImage BGR转uiimage

/**
 BGR转成UIImage
 
 @param buffer BGR图像数据
 @param width  图像宽
 @param height 图像高
 
 @return 返回转换后的UIImage
 */
+(UIImage *)convertBitmapRGBA8ToUIImage:(unsigned char *) buffer  withWidth:(int) width withHeight:(int) height isBGRA:(BOOL)isBGRA;

#pragma mark
#pragma mark -----------cutImage 图片裁剪
/**
 *  图片裁剪
 *
 *  @param superImage   原始图片
 *  @param subImageRect 裁剪的区域
 *
 *  @return 裁剪之后的图片
 */

+(UIImage *)cutImage:(UIImage*)superImage  subImageRect:(CGRect)subImageRect;

//递归缩放图片
+(UIImage *)recureScaleImage:(UIImage *)oldImage;

+(UIImage *)fixOrientation:(UIImage *)aImage;

@end
