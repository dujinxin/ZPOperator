//
//  CloudwalkFaceSDKLivessDef.h
//  CloudwalkFaceSDK
//
//  Created by DengWuPing on 17/1/10.
//  Copyright © 2017年 DengWuPing. All rights reserved.
//

#ifndef CloudwalkFaceSDKLivessDef_h
#define CloudwalkFaceSDKLivessDef_h


//活体等级
typedef NS_ENUM(NSInteger,CWLiveDetectlLevel){
    CWLiveDetectLow=0,        //活体检测难度低
    CWLiveDetectStandard,    //活体检测难度中等   转头区分左右、上下  检测出当前动作则为通过
    CWLiveDetectLevelHigh    //活体检测难度高     严格动作控制、检测出与当前提示不同的动作则为失败
};

//活体检测动作定义
typedef NS_ENUM(NSInteger,CWLiveDetectType)
{
    CWLivePrepare,//眨眼
    CWLiveHeadTurnLeft,//向左转头
    CWLiveHeadTurnRight,//向右转头
    CWLiveHeadRise,//向上抬头
    CWLiveHeadDown,//向下低头
    CWLiveOpenMouth,//张嘴
    CWLiveBlink,//眨眼
};

//活体动作检测
static   NSString  * _Nonnull  headLeft = @"向左缓慢转头";

static   NSString  * _Nonnull headRight = @"向右缓慢转头";

static   NSString  * _Nonnull headUp = @"缓慢抬头"; //默认已去掉

static   NSString  * _Nonnull headDown = @"缓慢点头";//默认已去掉

static   NSString  * _Nonnull openMouth = @"张嘴";

static   NSString  * _Nonnull blink = @"眨眼";

//视频流格式
typedef NS_ENUM(NSInteger,CWFaceBufferType)
{
    CWFaceBufferBGRA=1,//视频流格式 BGRA    kCVPixelFormatType_32BGRA
    CWFaceBufferYUV420,//视频流格式  YUV420  kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
};

#pragma mark
#pragma mark----------- 屏幕方向
/******************屏幕方向*******************/
typedef NS_ENUM(NSInteger,CWScreenDirection)
{
    CWScreenDirectionPortrait=1,
    CWScreenDirectionPortraitUpsideDown,
    CWScreenDirectionLeft, //横屏向左
    CWScreenDirectionRight,//横屏向右
    
};

#pragma mark
#pragma mark----------- 活体检测准备阶段提示语
/******************活体检测准备阶段提示语*******************/

typedef NS_ENUM(NSInteger,CW_PrepareFaceInfo){
    
    //活体检测准备阶段提示语
    CW_FACE_PREPARE_TOOFAR = 2,     //人脸距离摄像头太远
    CW_FACE_PREPARE_TOOCLOSE,       //人脸距离摄像头太近
    CW_FACE_PREPARE_FRONTAL,        //人脸没有正对屏幕
    CW_FACE_PREPARE_STABLE,         //人脸晃动
    CW_FACE_PREPARE_TOODARK,        //光线太暗
    CW_FACE_PREPARE_BRIGHT,         //光线太亮
    CW_FACE_PREPARE_NOTCENTER,      //人脸不居中
    CW_FACE_PREPARE_NOFACE,         //检测不到人脸
    CW_FACE_PREPARE_FACECOVER      //人脸被遮挡
};

#pragma mark
#pragma mark----------- 活体检测返回码
/******************活体检测返回码*******************/

typedef NS_ENUM(NSInteger,CW_LivenessCode){
    
    //活体检测代码返回
    CW_FACE_LIVENESS_OPENMOUTH = 600,     //检测到张嘴
    CW_FACE_LIVENESS_BLINK,               //检测到眨眼
    CW_FACE_LIVENESS_HEADPITCH,           //检测到抬头
    CW_FACE_LIVENESS_HEADDOWN,            //检测到点头
    CW_FACE_LIVENESS_HEADLEFT,            //检测到左转
    CW_FACE_LIVENESS_HEADRIGHT,           //检测到右转
    
    //活体检测失败
    CW_FACE_LIVENESS_NOPEPOLE = 700,            //没有检测到人脸
    CW_FACE_LIVENESS_MULTIPERSONE,        //检测到多个人
    CW_FACE_LIVENESS_PEPOLECHANGED,       //检测到换人
    CW_FACE_LIVENESS_OVERTIME,            //检测超时
    
    CW_FACE_LIVENESS_ATTACK_PICTURE =704,      //检测到攻击-图片攻击
    
    //检测到攻击
    CW_FACE_LIVENESS_ATTACK_SHAKE,        //检测到攻击-图像抖动
    CW_FACE_LIVENESS_ATTACK_MOUTH,        //检测到攻击-嘴被扣取
    CW_FACE_LIVENESS_ATTACK_RIGHTEYE,     //检测到攻击-右眼被扣取
    CW_FACE_LIVENESS_ATTACK_UNSTABLE,     //检测到攻击-人脸不稳定
    CW_FACE_LIVENESS_ATTACK_PAD,          //检测到攻击-方框(如纸片、pad)攻击
    CW_FACE_LIVENESS_ATTACK_VIDEO,        //检测到攻击-视频攻击
};


#pragma mark
#pragma mark----------- 算法返回错误码
/******************算法返回错误码*******************/

typedef NS_ENUM(NSInteger,CW_FaceDETCode){
    CW_FACE_DET_OK = 0, //成功
                        //算法SDK错误码返回
    CW_FACE_EMPTY_FRAME = 20000,            // 空图像
    
    CW_FACE_UNSUPPORTFRAME,                  // 图像格式不支持
    CW_FACE_DETECTED_NOFACE,                        // 没有人脸
    CW_FACE_SETROI_FAILED,                        // ROI设置失败
    CW_FACE_SETMINMAX_FAILED,                        // 最小最大人脸设置失败
    CW_FACE_OUTOF_RANGEERR,            // 数据范围错误
    CW_FACE_METHOD_INVALID,            // 方法无效
    CW_FACE_UNAUTHORIZED,                // 未授权
    CW_FACE_UNINITIALIZED,                // 尚未初始化
    CW_FACE_DETMODEL_FAILED,                    // 加载检测模型失败
    CW_FACE_KEYPTMODEL_FAILED,                    // 加载关键点模型失败
    CW_FACE_QUALITYMODEL_FAILED,                // 加载质量评估模型失败
    CW_FACE_LIVENESSMODEL_FAILED,                // 加载活体检测模型失败
    CW_FACE_DET_FAILED,                            // 检测失败
    CW_FACE_KEYPT_FAILED,                        // 提取关键点失败
    CW_FACE_ALIGN_FAILED,                        // 对齐人脸失败
    CW_FACE_QUALITY_FAILED,                      // 质量评估失败
    CW_FACE_LIVENESS_DETERR                      // 活体检测错

};


//人脸信息字典key
#define POINTS_KEY @"KEY_Points_KEY"     //关键点

#define RECT_KEY   @"FaceRect_KEY"     //人脸框坐标
#define TRACKID_KEY   @"TrackID_KEY"     //跟踪ID

#define HEADPITCH_KEY   @"HeadPitch_KEY"  //是否抬头、低头
#define HEADYAW_KEY   @"HeadYaw_KEY"     //是否左右转头
#define MOUTHOPEN_KEY   @"MouthOpen_KEY"   //是否张嘴

#define BLINK_KEY       @"Blink_KEY"     //是否眨眼

#define FACESCORE_KEY   @"FaceScore_KEY"   //人脸质量分数
#define BRIGHTNESS_KEY   @"Brightness_KEY"  //亮度

#define CLEARNESS_KEY   @"Clearness_KEY"  //人脸清晰度

#define GLASSNESS_KEY   @"Glassness_KEY"  //是否戴眼镜

#define SKINNESS_KEY   @"Skiness_KEY"     //肤色

#define BlackGlass_KEY   @"BlackGlassProb"// 戴黑框眼镜置信度，越大表示戴黑框眼镜的可能性越大，推荐范围0.0-0.5

#define Sunglass_KEY   @"SunglassProb"  //戴墨镜的置信分，越大表示戴墨镜的可能性越大，推荐范围0.0-0.5

#define EyeOcclusion_KEY   @"EyeOcclusionProb" // 眼睛被遮挡的置信度，越大表示眼睛越可能被遮挡，推荐范围0.0-0.5

#define Facelt_KEY   @"FaceltFlag" //防脸优 flag  返回1开始活体检测

#define LivessAttack_KEY   @"LivessAttack" //活体检测攻击码

#define HEAD_PITCH_DEGREE_KEY @"Head_Pitch_Degree_KEY"   //抬头、低头的角度

#define HEAD_YAW_DEGREE_KEY  @"Head_Yaw_Degree_KEY"      //转头的角度

#endif /* CloudwalkFaceSDKLivessDef_h */

