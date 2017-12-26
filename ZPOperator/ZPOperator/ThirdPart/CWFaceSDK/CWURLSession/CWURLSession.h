
//
//  NSURLConnectionClient.h
//  SmallCloudCheck
//
//  Created by DengWuPing on 15/12/7.
//  Copyright © 2015年 DengWuPing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark
#pragma mark-----------Block定义

/**
 *  @brief 人脸比对Block
 *  @param result 返回结果0成功 非0失败
 *  @param score  比对分数
 *  @param info   返回详细信息
 */
typedef void(^FaceCompareBlock)(NSInteger result,double score,NSString * __nullable info);

/**
 *  @brief 删除人脸Block
 *
 *  @param result 返回结果0成功 非0错误码
 *  @param info   返回详细信息
 */
typedef void(^FaceDeleteBlock)(NSInteger result,NSString * __nullable info);

/**
 *  @brief 人脸属性分析Block
 *
 *  @param result 返回结果0成功 非0失败
 *  @param info   返回详细信息
 *  @param faces  返回检测到的人脸 包括人脸坐标和年龄
 */
typedef void(^FaceAttributeBlock)(NSInteger result,NSString * __nullable info,NSArray *__nullable faces);


/**
 *  @brief 创建人脸Block
 *
 *  @param result 返回结果0成功 非0失败
 *  @param info   返回详细信息
 *  @param faceId   人脸ID（创建组时为组ID）
 */
typedef void(^FaceCrateBlock)(NSInteger result,NSString * __nullable info,NSString * __nullable faceId);

/**
 *  @brief 添加人脸到组Block
 *
 *  @param result 返回结果0成功 非0失败
 *  @param info   返回详细信息
 */
typedef void(^AddFaceToGropBlock)(NSInteger result,NSString * __nullable info);

/**
 *  @brief OCR识别Block
 *
 *  @param cardInfo 身份证或银行卡信息字典
 */
typedef void(^cardOCRBlock)(NSDictionary *__nullable cardInfo);


/**
 *  @brief 网络请求block回调
 *
 *  @param data  请求结果数据
 *  @param error 错误信息
 */
typedef void(^NSurlSessionFinishedBlock)(NSData * __nonnull data,NSError * __nonnull error);




@interface CWURLSession : NSObject<NSURLSessionDataDelegate>
{
    NSMutableURLRequest  * request;
    NSURLSession     * mainSession;
}

+ (__nonnull instancetype)sharedClient;

#pragma mark--
#pragma mark  cancelRequest 取消请求
-(void)cancelRequest;

/**
 *  @brief post字符串到服务端
 *
 *  @param url     URL接口地址
 *  @param postStr post字符串
 *  @param block   数据返回
 */
-(void)postStrToServer:(NSURL * __nonnull)url postStr:(NSString * __nonnull)postStr block:(NSurlSessionFinishedBlock __nonnull)block;



#pragma mark
#pragma mark-----------cwFaceCompareByTwoImages 人脸相似度比较
/**
 *  @brief 人脸相似度比较
 *
 *  @param serverIp        服务器ip地址
 *  @param apiKey     授权apiKey
 *  @param secretKey  授权secretkey
 *  @param imageAStr  图片A
 *  @param imageBStr 图片B
 *  @param completion      结果返回
 */

-(void)cwFaceCompare:(NSString *__nonnull)serverIp apiKey:(NSString *__nonnull)apiKey  secretKey:(NSString *__nonnull)secretKey imageA:(NSString *__nonnull)imageAStr  imageB:(NSString *__nonnull)imageBStr block:(__nullable FaceCompareBlock)completion;


#pragma mark
#pragma mark-----------cwIDCardRecoginise 身份证OCR识别
/**
 *  身份证OCR识别
 *  @param serverIp     OCR服务器地址
 *  @param apiKey        云从科技获取的apikey
 *  @param secretKey   云从科技获取的secretkey
 *  @param idCardImageData     身份证图片二进制数据
 *  @param completion              返回身份证信息字典
 */
-(void)cwIDOcr:(NSString * __nonnull)serverIp apiKey:(NSString *__nonnull)apiKey  secretKey:(NSString *__nonnull)secretKey cardImageData:(NSString *__nonnull)idCardBaseStr  block:(__nullable cardOCRBlock)completion;


#pragma mark
#pragma mark-----------cwBankCardOcr 银行卡图片OCR识别
/**
 *  银行卡OCR识别
 *  @param serverIp      OCR服务器地址
 *  @param apiKey        云从科技获取的apikey
 *  @param secretKey   云从科技获取的secretkey
 *  @param bankCardImageData    银行卡图片二进制数据
 *  @param completion              返回银行卡信息字典
 */
-(void)cwBankCardOcr:(NSString * __nonnull)serverIp apiKey:(NSString *__nonnull)apiKey  secretKey:(NSString *__nonnull)secretKey  cardImageData:(NSData *__nonnull)bankCardImageData  block:(__nullable cardOCRBlock)completion;


#pragma mark
#pragma mark-----------cwBankCardOcr 银行卡图片Url OCR识别
/**
 *  银行卡OCR识别
 *  @param serverIp      OCR服务器地址
 *  @param apiKey        云从科技获取的apikey
 *  @param secretKey   云从科技获取的secretkey
 *  @param imageUrl    图片url地址
 *  @param completion              返回银行卡信息字典
 */
-(void)cwBankCardOcr:(NSString * __nonnull)serverUrl apiKey:(NSString * __nonnull)apiKey secretKey:(NSString * __nonnull)secretKey cardImageUrl:(NSString * __nonnull)imageUrl block:(cardOCRBlock __nullable)completion;


#pragma mark
#pragma mark-----------cwFaceAttribute 人脸属性分析

/**
 *  @brief 人脸属性分析
 *
 *  @param serverIp   服务端ip地址
 *  @param apiKey     授权apiKey
 *  @param secretKey  授权secretkey
 *  @param faceStr    人脸图片base64
 *  @param completion 结果返回
 */

-(void)cwFaceAttribute:(NSString *__nonnull)serverIp apiKey:(NSString * __nonnull)apiKey  secretKey:(NSString * __nonnull)secretKey  faceImageBase64Str:(NSString * __nonnull)faceStr    block:(__nullable FaceAttributeBlock)completion;

#pragma mark
#pragma mark
#pragma mark-----------cwFaceAddFace 添加人脸
/**
 *  @brief  添加人脸
 *
 *  @param serverIp      服务端ip地址
 *  @param apiKey     授权apiKey
 *  @param secretKey  授权secretkey
 *  @param faceId        人脸ID
 *  @param groupId       组ID
 *  @param faceBase64Str 人脸图片base64字符串
 *  @param tagInfo    额外信息 限128字节
 *  @param completion    结果返回
 */

-(void)cwCreateFace:(NSString *__nonnull)serverIp apiKey:(NSString *__nonnull)apiKey  secretKey:(NSString *__nonnull)secretKey faceId:(NSString *__nonnull)faceId  groupId:(NSString *__nonnull)groupId tag:(NSString *__nullable)tagInfo faceImageBase64:(NSString *__nonnull)faceBase64Str  block:(__nullable FaceCrateBlock)completion;

#pragma mark
#pragma mark-----------cwDeleteFaceSErverIp 删除人脸
/**
 *  @brief 删除人脸
 *
 *  @param serverIp      服务端ip地址
 *  @param apiKey     授权apiKey
 *  @param secretKey  授权secretkey
 *  @param faceId        人脸ID
 *  @param groupID       组ID
 *  @param completion    结果返回
 */
-(void)cwDeleteFaceSErverIp:(NSString * __nonnull)serverIp apiKey:(NSString *__nonnull)apiKey  secretKey:(NSString *__nonnull)secretKey faceId:(NSString *__nonnull)faceId groupID:(NSString *__nonnull)groupID block:(__nullable FaceDeleteBlock)completion;

#pragma mark
#pragma mark-----------cwFaceCreateGrop 创建组
/**
 *  @brief 创建组
 *
 *  @param serverIp   服务端ip地址
 *  @param apiKey     授权apiKey
 *  @param secretKey  授权secretkey
 *  @param gropID     组id
 *  @param tagInfo    额外信息 限128字节
 *  @param completion 结果返回
 */

-(void)cwCreateGrop:(NSString *__nonnull)serverIp apiKey:(NSString *__nonnull)apiKey  secretKey:(NSString *__nonnull)secretKey gropID:(NSString *__nonnull)gropID tag:(NSString *__nullable)tagInfo  block:(__nullable FaceCrateBlock)completion;

#pragma mark
#pragma mark-----------cwDeleteGrop 删除组
/**
 *  @brief 创建组
 *
 *  @param serverIp   服务端ip地址
 *  @param apiKey     授权apiKey
 *  @param secretKey  授权secretkey
 *  @param gropID     组id
 *  @param tagInfo    额外信息 限128字节
 *  @param completion 结果返回
 */

-(void)cwDeleteGrop:(NSString * __nonnull)serverIp apiKey:(NSString * __nonnull)apiKey secretKey:(NSString * __nonnull)secretKey gropID:(NSString * __nonnull)gropID;

#pragma mark
#pragma mark-----------cwFaceGropAddFace 添加人脸到组
/**
 *  @brief 添加人脸到组
 *
 *  @param serverIp   服务端ip地址
 *  @param apiKey     授权apiKey
 *  @param secretKey  授权secretkey
 *  @param gropID     组id
 *  @param faceId     人脸ID
 *  @param completion 结果返回
 */

-(void)cwAddFaceToGrop:(NSString *__nonnull)serverIp apiKey:(NSString *__nonnull)apiKey  secretKey:(NSString *__nonnull)secretKey gropId:(NSString *__nonnull)gropID faceId:(NSString *__nonnull)faceId block:(__nullable AddFaceToGropBlock)completion;

#pragma mark
#pragma mark-----------cwFaceGropIdentify 组内识别
/**
 *  组内识别
 *  @param serverIp     服务器地址
 *  @param apiKey        云从科技获取的apikey
 *  @param secretKey   云从科技获取的secretkey
 *  @param faceId        人脸id 唯一标示字符串
 *  @param faceBase64Str       人脸图片base64编码字符串
 *  @param topN       返回比对分数最高的N个人
 *  @param completion            result     返回结果 0成功 非0错误号          infoStr       返回详细信息   faceInfoArray人脸信息字典数组
 */

-(void)cwQureyFaceFromGrop:(NSString *__nonnull)serverIp apiKey:(NSString *__nonnull)apiKey  secretKey:(NSString *__nonnull)secretKey gropID:(NSString *__nonnull)gropID faceImageBase64:(NSString *__nonnull)faceBase64Str topN:(NSInteger)topN block:(__nullable FaceAttributeBlock)completion;


/**
 *  @brief 后端活体防hack攻击检测Block
 *
 *  @param result         返回结果0成功 0成功（接口调用）
 *  @param param          返回结果0成功 1为活体  其他未非活体
 *  @param info           返回详细信息
 */
typedef void(^LivessBlock)(NSInteger result,NSInteger param,NSString * __nullable info);

#pragma mark
#pragma mark-----------cwFaceLivess 后端活体防hack攻击检测
/**
 *  后端活体防hack攻击检测
 *  @param serverIp             服务器地址
 *  @param apiKey               云从科技获取的apikey
 *  @param secretKey            云从科技获取的secretkey
 *  @param encryptJsonStr       最佳人脸图片、关键点数组、头部角度数组、每个活体动作通过时的照片组成的json字符串加密之后的字符串
 *  @param completion           result     返回结果 0成功 非0错误号          infoStr       返回详细信息   img人脸图片
 */

-(void)cwFaceLivess:(NSString *_Nonnull)serverIp apiKey:(NSString *_Nonnull)apiKey  secretKey:(NSString *_Nonnull)secretKey  encryptJsonStr:(NSString * _Nonnull)encryptJsonStr  block:(_Nullable LivessBlock)completion;


#pragma mark
#pragma mark------------ cwAddWaterMarImage  添加图片水印
/**
 *  @brief 添加图片水印
 *
 *  @param serverIp         服务器ip地址
 *  @param watermarkImage   返回结果0成功 非0失败
 *  @param maskStr          文字水印
 *  @param block            验证结果Block
 */
-(void)cwAddWaterMarImage:(NSString * _Nonnull)serverIp  image:(UIImage * _Nonnull)originalImage maskImage:(UIImage * _Nonnull)maskImage completion:(cardOCRBlock _Nonnull)block;
/**
 *  @brief 验证水印Block
 *
 *  @param result         返回结果0成功 非0失败
 *  @param score          验证水印分数
 */
typedef void(^DigitalWaterMarkBlock)(NSInteger result,double score);

#pragma mark
#pragma mark------------ cwDigitalWaterMarkVerifyStrMask验证文字水印
/**
 *  @brief 验证文字水印
 *
 *  @param serverIp         服务器ip地址
 *  @param watermarkImage   返回结果0成功 非0失败
 *  @param maskStr          文字水印
 *  @param block            验证结果Block
 */
-(void)cwDigitalWaterMarkVerifyStrMask:(NSString * _Nonnull)serverIp  image:(UIImage * _Nonnull)watermarkImage strMask:(NSString * _Nonnull)maskStr completion:(DigitalWaterMarkBlock _Nonnull)block;

#pragma mark
#pragma mark------------ cwDigitalWaterMarkVerifyImageMask验证图片水印
/**
 *  @brief 验证图片水印
 *
 *  @param serverIp         服务器ip地址
 *  @param watermarkImage   返回结果0成功 非0失败
 *  @param maskImage        验证水印分数
 *  @param block            验证结果Block
 */
-(void)cwDigitalWaterMarkVerifyImageMask:(NSString * _Nonnull)serverIp image:(UIImage * _Nonnull)watermarkImage maskImage:(UIImage * _Nonnull)maskImage completion:(DigitalWaterMarkBlock _Nonnull)block;

@end
