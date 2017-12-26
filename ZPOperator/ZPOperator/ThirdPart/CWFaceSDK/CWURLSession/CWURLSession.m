//
//  NSURLConnectionClient.m
//  SmallCloudCheck
//
//  Created by DengWuPing on 15/12/7.
//  Copyright © 2015年 DengWuPing. All rights reserved.
//

#import "CWURLSession.h"

@implementation CWURLSession

+ (instancetype)sharedClient{
    static CWURLSession *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[CWURLSession alloc]initSingle];
    });
    return _sharedClient;
}

-(id)initSingle{
    
    self = [super init];
    
    if(self){
        
        request = [[NSMutableURLRequest alloc]init];
        [request setHTTPMethod:@"POST"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        //超时时间
        [request setTimeoutInterval:20];
        
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        mainSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

-(id)init{
    return [self initSingle];
}

/**
 *  @brief post字符串到服务端
 *
 *  @param url     URL接口地址
 *  @param postStr post字符串
 *  @param block   数据返回
 */

-(void)postStrToServer:(NSURL *)url postStr:(NSString *)postStr block:(NSurlSessionFinishedBlock)block{
    
    request.URL = url;
    
    [request setHTTPBody:[postStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *task = [mainSession dataTaskWithRequest:request  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        block(data,error);
    }];
    [task resume];
    
}

/**
 *  @brief 取消请求
 */
-(void)cancelRequest{
    [mainSession invalidateAndCancel];
}


#pragma mark
#pragma mark-----------cwIDCardRecoginise 身份证OCR识别
/**
 *  身份证OCR识别
 *  @param serverIp     服务器地址
 *  @param apiKey        云从科技获取的apikey
 *  @param secretKey   云从科技获取的secretkey
 *  @param idCardImageData     身份证图片二进制数据
 *  @param completion              返回身份证信息字典
 */

-(void)cwIDOcr:(NSString *)serverIp apiKey:(NSString *)apiKey secretKey:(NSString *)secretKey cardImageData:(NSString *)idCardBaseStr block:(void (^)(NSDictionary * _Nullable))completion{
    
    NSURL  * url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/ocr",serverIp]];
    
    NSString * baseString = [self stringUrlEncodeing:idCardBaseStr];
    
    NSString  * postStr = [NSString stringWithFormat:@"app_id=%@&app_secret=%@&img=%@&getFace=1",apiKey,secretKey,baseString];
    
    [[CWURLSession sharedClient] postStrToServer:url postStr:postStr block:^(NSData *data, NSError *error) {
        
        if (data != nil) {
            NSDictionary  * dict =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            completion(dict);
        }else{
            completion(nil);
        }
    }];
}

#pragma mark
#pragma mark-----------cwBankCardRecoginise 银行卡OCR识别
/**
 *  @brief 银行卡OCR识别
 *
 *  @param serverIp     服务器地址
 *  @param apiKey        云从科技获取的apikey
 *  @param secretKey   云从科技获取的secretkey
 *  @param bankCardImageData 银行卡图片数据
 *  @param completion        返回银行卡识别信息字典
 */
-(void)cwBankCardOcr:(NSString *)serverIp apiKey:(NSString *)apiKey secretKey:(NSString *)secretKey cardImageData:(NSData *)bankCardImageData block:(cardOCRBlock)completion{
    
    NSString  * cardImageStr;  ;
    
#if  __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    cardImageStr = [bankCardImageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
#elif
    cardImageStr =  [bankCardImageData base64Encoding];
#endif
    NSString  * postStr = [NSString stringWithFormat:@"app_id=%@&app_secret=%@&img=%@",apiKey,secretKey,[self stringUrlEncodeing:cardImageStr]];
    
    NSURL *  url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/ocr/bankcard",serverIp]];
    
    [self postStrToServer:url postStr:postStr block:^(NSData *data, NSError *error) {
        if (data != nil) {
            NSDictionary  * dict =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            completion(dict);
        }else{
            NSDictionary * dict = @{@"result":@"4099",@"info":@"网络异常!"};
            completion(dict);
        }
    }];
}

#pragma mark
#pragma mark-----------cwBankCardRecoginise 银行卡OCR识别
/**
 *  @brief 银行卡OCR识别
 *
 *  @param serverUrl     服务器地址
 *  @param apiKey        云从科技获取的apikey
 *  @param secretKey   云从科技获取的secretkey
 *  @param imageUrl    银行卡图片地址
 *  @param completion        返回银行卡识别信息字典
 */
-(void)cwBankCardOcr:(NSString *)serverIp apiKey:(NSString *)apiKey secretKey:(NSString *)secretKey cardImageUrl:(NSString * _Nonnull)imageUrl block:(cardOCRBlock _Nullable)completion{
    
    NSString  * postStr = [NSString stringWithFormat:@"app_id=%@&app_secret=%@&url=%@",apiKey,secretKey,imageUrl];
    
    NSURL *  url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/ocr/bankcard",serverIp]];
    
    [self postStrToServer:url postStr:postStr block:^(NSData *data, NSError *error) {
        
        if (data != nil) {
            NSDictionary  * dict =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            completion(dict);
        }else{
            NSDictionary * dict = @{@"result":@"4099",@"info":@"网络异常!"};
            completion(dict);
        }
    }];
}


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

-(void)cwFaceAttribute:(NSString *)serverIp apiKey:(NSString *)apiKey secretKey:(NSString *)secretKey faceImageBase64Str:(NSString *)faceStr block:(FaceAttributeBlock)completion{
    
    NSURL  * url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/face/tool/attribute",serverIp]];
    
    NSString * baseString = [self stringUrlEncodeing:faceStr];
    
    NSString  * postStr =[NSString stringWithFormat:@"app_id=%@&app_secret=%@&img=%@",apiKey,secretKey,baseString];
    
    [[CWURLSession sharedClient] postStrToServer:url postStr:postStr block:^(NSData *data, NSError *error) {
        
        if(data != nil){
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if(dict != nil){
                completion([[dict objectForKey:@"result"] integerValue],[dict objectForKey:@"info"],[dict objectForKey:@"faces"]);
            }else{
                completion(0x1003,@"网络异常",nil);
            }
        }else{
            completion(0x1003,@"网络异常",nil);
        }
    }];
}

#pragma mark
#pragma mark-----------cwFaceCompare 人脸相似度比较
/**
 *  @brief 人脸相似度比较
 *
 *  @param serverIp        服务器ip地址
 *  @param apiKey     授权apiKey
 *  @param secretKey  授权secretkey
 *  @param imageAStr  图片A base64字符串
 *  @param imageBStr 图片B base64字符串
 *  @param completion      结果返回
 */

-(void)cwFaceCompare:(NSString *)serverIp apiKey:(NSString *)apiKey secretKey:(NSString *)secretKey imageA:(NSString *)imageAStr imageB:(NSString *)imageBStr block:(FaceCompareBlock)completion{
    
    NSURL  * url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/face/tool/compare",serverIp]];
    NSLog(@"url=====%@",url);
    
    NSString * imageABAse64 = [self stringUrlEncodeing:imageAStr];
    
    NSString * imageBBse64 = [self stringUrlEncodeing:imageBStr];
    
    NSString  * postStr =[NSString stringWithFormat:@"app_id=%@&app_secret=%@&imgA=%@&imgB=%@",apiKey,secretKey,imageABAse64,imageBBse64];
    
    [[CWURLSession sharedClient] postStrToServer:url postStr:postStr block:^(NSData *data, NSError *error) {
        //        NSString  * str  = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        //        NSLog(@"str === %@",str);
        if(data != nil){
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if(dict != nil){
                completion([[dict objectForKey:@"result"] integerValue],[[dict objectForKey:@"score"] doubleValue],[dict objectForKey:@"info"]);
            }else{
                completion(0x1003,0.f,@"网络异常");
            }
        }else{
            completion(0x1003,0.f,@"网络异常");
        }
    }];
}

#pragma mark
#pragma mark-----------cwCreateFace 创建人脸
/**
 *  @brief  添加人脸
 *
 *  @param serverIp      服务端ip地址
 *  @param apiKey     授权apiKey
 *  @param secretKey  授权secretkey
 *  @param faceId        人脸ID
 *  @param faceBase64Str 人脸图片base64字符串
 *  @param tagInfo    额外信息 限128字节
 *  @param completion    结果返回
 */

-(void)cwCreateFace:(NSString *)serverIp apiKey:(NSString *)apiKey secretKey:(NSString *)secretKey faceId:(NSString *)faceId groupId:(NSString *)groupId tag:(NSString *)tagInfo faceImageBase64:(NSString *)faceBase64Str block:(FaceCrateBlock)completion{
    
    NSURL  * url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/face/clustering/face/create",serverIp]];
    
    NSString * baseString = [self stringUrlEncodeing:faceBase64Str];
    
    NSString  * postStr =[NSString stringWithFormat:@"app_id=%@&app_secret=%@&faceId=%@&groupId=%@&img=%@&tag=%@",apiKey,secretKey,faceId,groupId,baseString,tagInfo];
    
    [[CWURLSession sharedClient] postStrToServer:url postStr:postStr block:^(NSData *data, NSError *error) {
        
        if(data != nil){
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if(dict != nil){
                completion([[dict objectForKey:@"result"] integerValue],[dict objectForKey:@"info"],[dict objectForKey:@"faceId"]);
            }else{
                completion(0x1003,@"网络异常",nil);
            }
        }else{
            completion(0x1003,@"网络异常",nil);
        }
    }];
}

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
-(void)cwDeleteFaceSErverIp:(NSString *)serverIp apiKey:(NSString *)apiKey secretKey:(NSString *)secretKey faceId:(NSString *)faceId groupID:(NSString *)groupID  block:(FaceDeleteBlock)completion{
    
    NSURL  * url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/face/clustering/face/delete",serverIp]];
    
    NSString  * postStr =[NSString stringWithFormat:@"app_id=%@&app_secret=%@&faceId=%@&groupId=%@",apiKey,secretKey,faceId,groupID];
    
    [[CWURLSession sharedClient] postStrToServer:url postStr:postStr block:^(NSData *data, NSError *error) {
        
        if(data != nil){
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if(dict != nil){
                completion([[dict objectForKey:@"result"] integerValue],[dict objectForKey:@"info"]);
            }else{
                completion(0x1003,@"网络异常");
            }
        }else{
            completion(0x1003,@"网络异常");
        }
    }];
}

#pragma mark
#pragma mark-----------cwCreateGrop 创建组
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

-(void)cwCreateGrop:(NSString *)serverIp apiKey:(NSString *)apiKey secretKey:(NSString *)secretKey gropID:(NSString *)gropID tag:(NSString *)tagInfo block:(FaceCrateBlock)completion{
    
    NSURL  * url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/face/clustering/group/create",serverIp]];
    
    NSString  * postStr =[NSString stringWithFormat:@"app_id=%@&app_secret=%@&groupId=%@&tag=%@",apiKey,secretKey,gropID,tagInfo];
    
    [[CWURLSession sharedClient] postStrToServer:url postStr:postStr block:^(NSData *data, NSError *error) {
        if(data != nil){
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if(dict != nil){
                completion([[dict objectForKey:@"result"] integerValue],[dict objectForKey:@"info"],[dict objectForKey:@"groupId"]);
            }else{
                completion(0x1003,@"网络异常",nil);
            }
        }else{
            completion(0x1003,@"网络异常",nil);
        }
        
    }];
    
}

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

-(void)cwDeleteGrop:(NSString *)serverIp apiKey:(NSString *)apiKey secretKey:(NSString *)secretKey gropID:(NSString *)gropID{
    
    NSURL  * url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/face/clustering/group/delete",serverIp]];
    
    NSString  * postStr =[NSString stringWithFormat:@"app_id=%@&app_secret=%@&groupId=%@",apiKey,secretKey,gropID];
    
    [[CWURLSession sharedClient] postStrToServer:url postStr:postStr block:^(NSData *data, NSError *error) {
        
    }];
    
}
#pragma mark
#pragma mark-----------cwAddFaceToGrop 添加人脸到组
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
-(void)cwAddFaceToGrop:(NSString *)serverIp apiKey:(NSString *)apiKey secretKey:(NSString *)secretKey gropId:(NSString *)gropID faceId:(NSString *)faceId block:(AddFaceToGropBlock)completion{
    
    NSURL  * url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/face/clustering/group/addFace",serverIp]];
    
    NSString  * postStr =[NSString stringWithFormat:@"app_id=%@&app_secret=%@&groupId=%@&faceId=%@",apiKey,secretKey,gropID,faceId];
    
    [[CWURLSession sharedClient] postStrToServer:url postStr:postStr block:^(NSData *data, NSError *error) {
        
        if(data != nil){
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if(dict != nil){
                completion([[dict objectForKey:@"result"] integerValue],[dict objectForKey:@"info"]);
            }else{
                completion(0x1003,@"网络异常");
            }
        }else{
            completion(0x1003,@"网络异常");
        }
    }];
}

#pragma mark
#pragma mark-----------cwQureyFaceFromGrop 组内识别
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

-(void)cwQureyFaceFromGrop:(NSString *)serverIp apiKey:(NSString *)apiKey secretKey:(NSString *)secretKey gropID:(NSString *)gropID faceImageBase64:(NSString *)faceBase64Str topN:(NSInteger)topN block:(FaceAttributeBlock)completion{
    
    NSURL  * url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/face/recog/group/identify",serverIp]];
    
    NSString * baseString = [self stringUrlEncodeing:faceBase64Str];
    
    NSString  * postStr =[NSString stringWithFormat:@"app_id=%@&app_secret=%@&groupId=%@&topN=%ld&img=%@",apiKey,secretKey,gropID,(long)topN,baseString];
    
    [[CWURLSession sharedClient] postStrToServer:url postStr:postStr block:^(NSData *data, NSError *error) {
        if(data != nil){
            
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if(dict != nil){
                completion([[dict objectForKey:@"result"] integerValue],[dict objectForKey:@"info"],[dict objectForKey:@"faces"]);
            }else{
                completion(0x1003,@"网络异常",nil);
            }
        }else{
            completion(0x1003,@"网络异常",nil);
        }
        
    }];
}

#pragma mark
#pragma mark-----------cwFaceLivess 后端活体防hack攻击检测
/**
 *  后端活体防hack攻击检测
 *  @param serverIp             服务器地址
 *  @param apiKey               云从科技获取的apikey
 *  @param secretKey            云从科技获取的secretkey
 *  @param encryptJsonStr       最佳人脸图片、关键点数组、头部角度数组、每个活体动作通过时的照片组成的json字符串加密之后的字符串
 *  @param completion           result     返回结果 0成功 非0错误号     param 1为活体 其他费活体     infoStr       返回详细信息
 */

-(void)cwFaceLivess:(NSString *)serverIp apiKey:(NSString *)apiKey secretKey:(NSString *)secretKey encryptJsonStr:(NSString *)encryptJsonStr block:(LivessBlock)completion{
    
    NSURL  * url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/faceliveness",serverIp]];
    //拼接app_id、app_secret
    NSString  * postStr =[NSString stringWithFormat:@"app_id=%@&app_secret=%@&param=%@",apiKey,secretKey,[self stringUrlEncodeing:encryptJsonStr]];
    
    [self postStrToServer:url postStr:postStr block:^(NSData *data, NSError *error) {
        if(data != nil){
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

            if(dict != nil){
                
                completion([[dict objectForKey:@"result"] integerValue],[[dict objectForKey:@"code"] integerValue],[dict objectForKey:@"info"]);
            }else{
                completion(0x1003,-1,@"网络异常");
            }
        }else{
            completion(0x1003,-1,@"网络异常");
        }
    }];
}

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
-(void)cwAddWaterMarImage:(NSString * _Nonnull)serverIp  image:(UIImage * _Nonnull)originalImage maskImage:(UIImage * _Nonnull)maskImage completion:(cardOCRBlock _Nonnull)block{
    
    request.timeoutInterval = 30;
    
    NSURL  * url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/tool/digitalwater/addImage",serverIp]];
    
    NSData  * data = UIImageJPEGRepresentation(originalImage, .6f);
    
    NSString  * imageBase64Str = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSData  * maskData = UIImageJPEGRepresentation(maskImage, .6f);
    
    NSString  * maskImageBase64Str = [maskData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    //拼接app_id、app_secret
    NSString  * postStr =[NSString stringWithFormat:@"imgSrc=%@&imgMask=%@",[self stringUrlEncodeing:imageBase64Str],[self stringUrlEncodeing:maskImageBase64Str]];
    
    [self postStrToServer:url postStr:postStr block:^(NSData *data, NSError *error) {
        if(data != nil){
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"dict =%@",dict);
            if(dict != nil){
                block(dict);
            }else{
                block(nil);
            }
        }else{
            block(nil);
        }
    }];
}
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
-(void)cwDigitalWaterMarkVerifyStrMask:(NSString * _Nonnull)serverIp  image:(UIImage * _Nonnull)watermarkImage strMask:(NSString * _Nonnull)maskStr completion:(DigitalWaterMarkBlock _Nonnull)block{
    
    request.timeoutInterval = 20;
    
    NSURL  * url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/tool/digitalwater/detectString",serverIp]];
    
    NSData  * data = UIImageJPEGRepresentation(watermarkImage, 0.6f);
    
    NSString  * imageBase64Str = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    //拼接app_id、app_secret
    NSString  * postStr =[NSString stringWithFormat:@"imgSrc=%@&strMask=%@",[self stringUrlEncodeing:imageBase64Str],maskStr];
    
    [self postStrToServer:url postStr:postStr block:^(NSData *data, NSError *error) {
        NSLog(@"data = %@ error =%@",data,error);
        if(data != nil){
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"dict =%@",dict);
            if(dict != nil){
                
                block([[dict objectForKey:@"result"] integerValue],[[dict objectForKey:@"score"] doubleValue]);
            }else{
                block(0x1003,0.f);
            }
        }else{
            block(0x1003,0.f);
        }
    }];
}

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
-(void)cwDigitalWaterMarkVerifyImageMask:(NSString * _Nonnull)serverIp image:(UIImage * _Nonnull)watermarkImage maskImage:(UIImage * _Nonnull)maskImage completion:(DigitalWaterMarkBlock _Nonnull)block{
    
    request.timeoutInterval = 20;
    
    NSURL  * url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/tool/digitalwater/detectImage",serverIp]];
    
    NSData  * data = UIImageJPEGRepresentation(watermarkImage, .6f);
    
    NSString  * imageBase64Str = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSData  * maskData = UIImageJPEGRepresentation(maskImage, .6f);
    
    NSString  * maskImageBase64Str = [maskData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];

    //拼接app_id、app_secret
    NSString  * postStr =[NSString stringWithFormat:@"imgSrc=%@&imgMask=%@",[self stringUrlEncodeing:imageBase64Str],[self stringUrlEncodeing:maskImageBase64Str]];
    
    [self postStrToServer:url postStr:postStr block:^(NSData *data, NSError *error) {

        if(data != nil){
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"dict =%@",dict);
            if(dict != nil){
                block([[dict objectForKey:@"result"] integerValue],[[dict objectForKey:@"score"] doubleValue]);
            }else{
                block(0x1003,0.f);
            }
        }else{
            block(0x1003,0.f);
        }
    }];

}

#pragma mark
#pragma mark-----------stringUrlEncodeing base64去掉空格
/**
 *  @brief base64去掉空格
 *
 *  @param str 原字符串
 *
 *  @return 去掉空格之后的字符串
 */
-(NSString *)stringUrlEncodeing:(NSString *)str{
    
    NSString * baseString;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_0
    baseString = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet whitespaceCharacterSet]];
#else
    baseString = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)faceStr,NULL,CFSTR(":/?#[]@!$&’()*+,;="),kCFStringEncodingUTF8);
#endif
    
    return baseString;
}


@end

