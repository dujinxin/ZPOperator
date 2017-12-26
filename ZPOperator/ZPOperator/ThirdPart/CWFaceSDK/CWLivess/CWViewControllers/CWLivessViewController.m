//
//  LiveDetectViewController.m
//  CloudwalkFaceSDKDemo
//
//  Created by DengWuPing on 16/5/12.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import "CWLivessViewController.h"
#import "CWProgressView.h"
#import "CWFinishedView.h"
#import "CWAudioPlayer.h"
#import "CWAnimationView.h"
#import "CWURLSession.h"
#import "CWMBProgressHud.h"
#import "CWHackerCheckView.h"

#import "ZPOperator-Swift.h"

@interface CWLivessViewController ()<CaptureManagerDelegate,cwDelegate,CWAudioPlayerDelegate>{
    
    NSMutableArray      *      actionArray;      //需要做的活体动作
    CWFinishedView      *      finishedView;     //检测结果显示页面
    
    CWProgressView      *      progressView;    // 进度条View
    
    BOOL                       isAudioPlay;        //当前是否正在播放
    NSDictionary        *      imageNameDictionary;//图片字典
    
    NSInteger                  stepIndex;          //执行检测的索引
    
    CWAnimationView     *      animationView;     //底部动画显示
    
    NSString            *      audioFileName;      //当前播放的声音文件名
    AVCaptureVideoPreviewLayer  *  preLayer;
    
    __block NSData      *       _bestFaceData; // 获取的最佳人脸图片
    
    BOOL                   isALive;  //活体检测是否成功
    
    CGRect                 faceBoxRect;  //人脸框Rect
    
    BOOL                   isDetectFace;  //开始检测人脸是否在框内
    
    NSInteger              errorCode;  //活体检测返回的错误码
    
    NSInteger              sdkErrorCode;//SDK初始化返回码
    
    CWCameraType           cameraType;  //相机类型、前置、后置
    
    UIView              *   guideView;   //引导View
    
    UIView              *   headView;    //headerView
    
    float                   bottomViewHight;
    
    UIImageView         *   faceBoxImgview; //人脸框图片ImageView
    
    UIView              *   bottomView;    //底部的动画提示View
    
    UIView              *   animationSuperView;
    
    UIImageView         *   tipsImageView;
    
    UILabel             *   actionNameLabel;  //动作提示label
    
    UIView              *   cameraView;   //相机预览View
    
    NSMutableString            *   encryptjsonStr; //后端防hack攻击字符串
    
    CWHackerCheckView   *   hackerView;   //防攻击检测View
    
    UIBackgroundTaskIdentifier		    _backgroundRecordingID;
    
    BOOL              isStopLivess;
    
    BOOL              isStartLive;
    
    BOOL              isShowFaildView;
    
}

@property(nonatomic,strong)NSTimer    *   timer;       //倒计时定时器

@end

#define  LivessOverTime    8  //活体检测的超时时间

#define tipsLabelHight CWLIVESSSCREEN_HEIGHT * 0.05

//RGB颜色
#define CWFR_ColorFromRGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
//屏幕宽
#define CWLIVESSSCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width

//屏幕高
#define CWLIVESSSCREEN_HEIGHT  [[UIScreen mainScreen] bounds].size.height
//这里是会报警告的代码
@implementation CWLivessViewController

#pragma mark
#pragma mark-----------  viewWillAppear  //隐藏导航栏
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
//    if (self.navigationController != nil) {
//        self.navigationController.navigationBarHidden = YES;
//    }
}

-(id)init{
    if (self = [super init]) {
        [self setDefaultPara];
    }
    return self;
}

#pragma mark
#pragma mark-------------------- setLivessParam 设置活体检测参数
/**
 *  @brief 设置默认参数
 */
-(void)setDefaultPara{
    _isShowResultView = YES;
    _livessNumber = 3;
    _allActionArry = [NSArray arrayWithObjects:blink,openMouth,headLeft,headRight, nil];
    _isRecord  = NO;
    _videoPath = [NSString stringWithFormat:@"%@/Documents/cwLivessDetect.mp4",NSHomeDirectory()];
    _videoSizeMode = CWVideoSizeModeHigh;
}

#pragma mark
#pragma mark-------------------- setLivessParam 设置活体检测参数

/**
 *  @brief 设置活体检测参数
 *
 *  @param authCode       SDK授权码
 （必须传入从云从科技获取的正确的授权码）
 
 *  @param activeNumber   活体动作个数
 （可设置1-5个活体动作、默认去掉点头动作  默认为3个动作）
 
 *  @param isShowResult   是否显示结果页面
 （检测成功、失败的View）
 
 */

-(void)setLivessParam:(NSString *)authCode livessNumber:(NSInteger)activeNumber isShowResultView:(BOOL)isShowResult{
    
    self.authCodeString = authCode;
    self.livessNumber = activeNumber;
    self.isShowResultView = isShowResult;
}

#pragma mark
#pragma mark-------------------- createHeaderView 自定义导航条

-(void)createHeaderView{
    //自定义导航条
    headView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CWLIVESSSCREEN_WIDTH, 64)];
    headView.backgroundColor = CWFR_ColorFromRGB(232,0,0);
    [self.view addSubview:headView];
    
    UILabel*headViewLabel=[[UILabel alloc]initWithFrame:CGRectMake((CWLIVESSSCREEN_WIDTH-200)/2, 20, 200, 44)];
    headViewLabel.text=@"活体检测";
    headViewLabel.textAlignment = NSTextAlignmentCenter;
    headViewLabel.textColor=[UIColor whiteColor];
    headViewLabel.font=[UIFont systemFontOfSize:20];
    [headView addSubview:headViewLabel];
    
    //自定义导航条的返回按钮
    UIButton*backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 20, 40, 40);
    [backButton setImage:[UIImage imageNamed:@"CWResource.bundle/jiantou@2x.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToHomeViewController:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:backButton];
}

#pragma mark
#pragma mark-------------------- creatGuideView 活体动作之前的引导页view

-(void)creatGuideView{
    
    //开始活体动作之前的引导页view     可以改变他的显示和隐藏
    guideView=[[UIView alloc]initWithFrame:CGRectMake(0, 64, CWLIVESSSCREEN_WIDTH, CWLIVESSSCREEN_HEIGHT-64)];
    //guideView.backgroundColor = CWFR_ColorFromRGB(27,35,57);
    guideView.backgroundColor = [UIColor jxffffffColor];
    [self.view addSubview:guideView];
    
    //guideview上的控件
    UILabel*tipLabel1=[[UILabel alloc]initWithFrame:CGRectMake(0, ((CWLIVESSSCREEN_HEIGHT-64)*0.06), CWLIVESSSCREEN_WIDTH, tipsLabelHight)];
    tipLabel1.text=@"请正对手机,确保光线充足";
    tipLabel1.textAlignment=NSTextAlignmentCenter;
    tipLabel1.textColor=[UIColor jx333333Color];
    tipLabel1.font=[UIFont systemFontOfSize:17];
    tipLabel1.clipsToBounds = YES;
    [guideView addSubview:tipLabel1];
    
    
    UIImageView *tipImageview=[[UIImageView alloc]init];
    tipImageview.image=[UIImage imageNamed:@"CWResource.bundle/xiaoren02@2x.png"];
    tipsImageView.contentMode = UIViewContentModeScaleAspectFill;
    tipsImageView.layer.masksToBounds = YES;
    tipsImageView.clipsToBounds = YES;
    tipImageview.frame = CGRectMake((CWLIVESSSCREEN_WIDTH- (CWLIVESSSCREEN_WIDTH*0.9))/2,tipLabel1.frame.origin.y+tipLabel1.frame.size.height + CWLIVESSSCREEN_WIDTH * 0.05 , (CWLIVESSSCREEN_WIDTH*0.9), (CWLIVESSSCREEN_HEIGHT*0.47));
    [guideView addSubview:tipImageview];
    
    
    UILabel*tipLabel2=[[UILabel alloc]init];
    tipLabel2.textColor=[UIColor jx333333Color];
    tipLabel2.text=@"请确保是账户本人操作";
    tipLabel2.frame = CGRectMake(0, tipImageview.frame.origin.y + tipImageview.frame.size.height + CWLIVESSSCREEN_HEIGHT * 0.02, CWLIVESSSCREEN_WIDTH, tipsLabelHight);
    tipLabel2.textAlignment=NSTextAlignmentCenter;
    tipLabel2.font=[UIFont systemFontOfSize:17];
    [guideView addSubview:tipLabel2];
    tipLabel2.clipsToBounds = YES;
    
    //startLivess
    UIButton*startLiveButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [startLiveButton addTarget:self action:@selector(startLivess:) forControlEvents:UIControlEventTouchUpInside];
    [startLiveButton setTitle:@"开始检测" forState:UIControlStateNormal];
    [startLiveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    startLiveButton.titleLabel.font=[UIFont systemFontOfSize:19];
    startLiveButton.layer.cornerRadius=5;
    startLiveButton.layer.masksToBounds=YES;
    startLiveButton.clipsToBounds = YES;
    [startLiveButton setBackgroundColor:[UIColor mainColor]];
    //[startLiveButton setBackgroundColor:CWFR_ColorFromRGB(232,0,0)];
    startLiveButton.frame = CGRectMake(CWLIVESSSCREEN_WIDTH*  0.11, tipLabel2.frame.origin.y + tipLabel2.frame.size.height + CWLIVESSSCREEN_HEIGHT * 0.04, CWLIVESSSCREEN_WIDTH * 0.78, CWLIVESSSCREEN_HEIGHT * 0.07);
    [guideView addSubview:startLiveButton];
}

#pragma mark
#pragma mark-------------------- creatLiveView 活体检测CameraView

-(void)creatLiveView
{
    cameraView=[[UIView alloc]initWithFrame:CGRectMake(0, 64, CWLIVESSSCREEN_WIDTH, CWLIVESSSCREEN_HEIGHT-64)];
    [self.view addSubview:cameraView];
    cameraView.hidden=YES;
    
    bottomViewHight = CWLIVESSSCREEN_HEIGHT * 0.36;
    if (CWLIVESSSCREEN_HEIGHT < 568) {
        bottomViewHight = CWLIVESSSCREEN_HEIGHT * 0.3;
    }
    bottomView=[[UIView alloc]initWithFrame:CGRectMake(0, cameraView.frame.size.height - bottomViewHight, CWLIVESSSCREEN_WIDTH, bottomViewHight)];
    //bottomView.backgroundColor=CWFR_ColorFromRGB(27,35,57);
    bottomView.backgroundColor = [UIColor jx333333Color];
    [cameraView addSubview:bottomView];
    
    //开始活体检测后的页面上的控件
    //人脸匡和底部提示的view
    faceBoxImgview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CWLIVESSSCREEN_WIDTH, cameraView.frame.size.height - bottomViewHight)];
    faceBoxImgview.image=[UIImage imageNamed:@"CWResource.bundle/face_box_640@2x.png"];
    [cameraView addSubview:faceBoxImgview];
    
    actionNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(CWLIVESSSCREEN_WIDTH*0.05, CWLIVESSSCREEN_WIDTH*0.03, CWLIVESSSCREEN_WIDTH * 0.9, tipsLabelHight)];
    actionNameLabel.textAlignment=NSTextAlignmentCenter;
    actionNameLabel.font=[UIFont systemFontOfSize:20];
    actionNameLabel.textColor=[UIColor jxffffffColor];
    actionNameLabel.numberOfLines = 0;
    actionNameLabel.text=@"请按图示将人脸放入取景框中,并保持静默!";
    actionNameLabel.numberOfLines = 0;
    [bottomView addSubview:actionNameLabel];
    
    //底部提示图片的origin.y = actionNameLabel.frame.origin.y + actionNameLabel.frame.size.height + （剩余高度 - 图片高度）/2
    
    float tipsImageViewY = (bottomViewHight - actionNameLabel.frame.origin.y - actionNameLabel.frame.size.height -   (bottomViewHight-tipsLabelHight)*0.78)/2 + actionNameLabel.frame.origin.y + actionNameLabel.frame.size.height;
    
    //底部提示view 上的控件
    tipsImageView=[[UIImageView alloc]initWithFrame:CGRectMake((CWLIVESSSCREEN_WIDTH -  (bottomViewHight-tipsLabelHight)*0.78)/2, tipsImageViewY,  (bottomViewHight-tipsLabelHight)*0.78, (bottomViewHight-tipsLabelHight)*0.78)];
    
    tipsImageView.image=[UIImage imageNamed:@"CWResource.bundle/tipsImage@2x.png"];
    tipsImageView.contentMode = UIViewContentModeScaleAspectFill;
    [bottomView addSubview:tipsImageView];
    
}

#pragma mark
#pragma mark-----------  viewDidLoad
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"人脸识别";
    
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc ] initWithImage:[UIImage new] style:UIBarButtonItemStylePlain target:self action:@selector(doNothing)];
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc ] initWithTitle:@"123" style:UIBarButtonItemStylePlain target:self action:@selector(doNothing)];
    
    //self.navigationItem.leftItemsSupplementBackButton = false;
    //[self createHeaderView];
    
    [self creatLiveView];
    
    [self creatGuideView];
    
    [self setFaceBoxRect];
    
    //相应的活体动作图片
    imageNameDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"openMouth",openMouth,@"turnLeft",headLeft,@"trunRight",headRight,@"rise",headUp,@"down",headDown,@"blink",blink, nil];
    
    actionArray = [[NSMutableArray alloc]init];
    
    //添加动画View
    animationView = [[CWAnimationView alloc]initWithFrame:CGRectMake(0, tipsLabelHight, CWLIVESSSCREEN_WIDTH, bottomViewHight-tipsLabelHight)];
    
    [bottomView addSubview:animationView];
    
    //SDK初始化
    errorCode = sdkErrorCode =  [[CloudwalkFaceSDK shareInstance] cwInit:self.authCodeString];
    
    //设置delegate
    [CloudwalkFaceSDK shareInstance].delegate = self;
    
    isDetectFace = NO;
    
    cameraType = CameraTypeFront;
    
    //设置提示lable根据宽度适应字体的大小
    actionNameLabel.adjustsFontSizeToFitWidth = YES;
    
    isStartLive = NO;
    
    isShowFaildView = NO;

    //添加锁屏或者退出到后台继续进行活体检测
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)applicationDidEnterBackgroundNotification{
    
    if (isStartLive && isShowFaildView == NO && isStopLivess == NO) {
        [self showFailedView:YES failedMessage:@"在活体检测过程中请勿退出到后台或者锁屏!"];
    }
}
- (void)doNothing{
    NSLog(@"doNothing");
}
#pragma mark
#pragma mark----------- setFaceBoxRect   //设置取景框区域

-(void)setFaceBoxRect{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        faceBoxRect = CGRectMake(80, 64, CWLIVESSSCREEN_WIDTH -160, CWLIVESSSCREEN_HEIGHT - bottomViewHight - 64);
    }else{
        if (CWLIVESSSCREEN_WIDTH <=320) {
            //中间的人脸框
            faceBoxRect = CGRectMake(50, 64, CWLIVESSSCREEN_WIDTH -100, CWLIVESSSCREEN_HEIGHT - bottomViewHight - 64);
        }else{
            //中间的人脸框
            faceBoxRect = CGRectMake(60, 64, CWLIVESSSCREEN_WIDTH -120, CWLIVESSSCREEN_HEIGHT - bottomViewHight - 64);
        }
    }
}

#pragma mark
#pragma mark----------- randomActions   //随机生成活体动作
/**
 *  @brief 随机活体动作
 */
-(void)randomActions{
    
    if (self.livessNumber <= _allActionArry.count) {
        
        [actionArray removeAllObjects];
        
        if(self.livessNumber == 1){
            
            [actionArray removeAllObjects];
            //1个动作时优先选择张嘴或眨眼
            if([_allActionArry containsObject:openMouth] || [_allActionArry containsObject:blink]){
                
                NSArray  *  array = @[blink,openMouth];
                
                int r = arc4random() % 2;
                
                [actionArray addObject:[array objectAtIndex:r]];
            }else{
                //如果不包含张嘴和眨眼 则从余下动作中选取一个
                int r = arc4random() % _allActionArry.count;
                
                [actionArray addObject:[_allActionArry objectAtIndex:r]];
            }
        }
        else{
            
            [self randomActionFromAllArray];
            
            NSMutableSet *randomSet = [[NSMutableSet alloc] init];
            
            while ([randomSet count] < actionArray.count) {
                int r = arc4random() % [actionArray count];
                [randomSet addObject:[actionArray objectAtIndex:r]];
            }
            
            [actionArray removeAllObjects];
            
            [actionArray addObjectsFromArray:[randomSet allObjects]];
        }
    }
}

-(void)randomActionFromAllArray{
    
    [actionArray removeAllObjects];
    
    //随机XX个不重复的动作 可以修改活体动作个数
    while ([actionArray count] < self.livessNumber) {
        //从0-活体动作数组中随机 XX 个动作
        int r = arc4random() % [_allActionArry count];
        
        if (![actionArray containsObject:[_allActionArry objectAtIndex:r]]) {
            [actionArray addObject:[_allActionArry objectAtIndex:r]];
        }
    }
    //大于1个动作时必须要有一个张嘴或者眨眼
    if(self.livessNumber >1){
        if ([_allActionArry containsObject:openMouth] ||[_allActionArry containsObject:blink]){
            
            if ((![actionArray containsObject:openMouth]) && (![actionArray containsObject:blink])) {
                [self randomActions];
            }
        }
    }
}


#pragma mark
#pragma mark----------- startLivess   //开始活体检测按钮方法
/**
 *  @brief 开始活体检测
 *
 *  @param sender 开始进入活体检测界面
 */
-(void)startLivess:(id)sender{
    
    isStopLivess = YES;
    
    if (isStartLive == NO) {
        
        isStartLive = YES;
        
        if (sdkErrorCode == CW_FACE_DET_OK) {
            
            isALive = NO;
            
            stepIndex = 0;
            
            //随机活体动作
            [self randomActions];
            //打开摄像头
            [self startCamera];
            //隐藏引导界面 显示活体检测界面
            [UIView animateWithDuration:0.3f animations:^{
                guideView.frame =  CGRectMake(-CWLIVESSSCREEN_WIDTH, 64, CWLIVESSSCREEN_WIDTH, CWLIVESSSCREEN_HEIGHT-64);
            } completion:^(BOOL isfinished){
                guideView.hidden = YES;
                audioFileName = @"main";
                [self playAudioFileName];
            }];
            tipsImageView.hidden = NO;
            actionNameLabel.text = @"请按图示将人脸放入取景框中,并正对屏幕!";
            [self performSelector:@selector(delayPushFrame) withObject:nil afterDelay:2.f];

        }
        else{
            if (self.isShowResultView) {
                [self showFailedView:YES failedMessage:@"初始化失败!"];
            }else{
                [self backToHomeViewController:nil];
            }
        }
    }
}

-(void)delayPushFrame {
    
    isStopLivess = NO;
    
    isDetectFace = YES;
}
#pragma mark
#pragma mark----------- showAnimationViewAndText   //显示每一步动作的动画提示和文字提示
/**
 *  @brief 示每一步动作的动画提示和文字提示
 */
-(void)showAnimationViewAndText{
    
    if(actionArray != nil && actionArray.count >0 ){
        NSString  * stepStr = [actionArray objectAtIndex:stepIndex];
        actionNameLabel.text = stepStr;
        //显示底部的动画
        [self showAnimation:stepStr];
    }
}

#pragma mark
#pragma mark----------- startCamera   //打开摄像头
/**
 *  @brief 打开摄像头
 */
-(void)startCamera{
    cameraView.hidden = NO;
    //设置屏幕方向，支持横屏、默认为竖屏
    CWCameraOrientation  orintation = CameraOrientationPortrait;
    preLayer = [[CWCamera SharedInstance] cwStartCamera:cameraType CameraOrientation:orintation delegate:self];
    //设置横屏时 要设置相应的预览大小为横屏时的大小
    if (orintation == CameraOrientationRight || orintation == CameraOrientationLeft) {
        preLayer.frame = CGRectMake(0, 0, CWLIVESSSCREEN_HEIGHT,cameraView.frame.size.width);
    }else if (orintation == CameraOrientationPortrait){
        preLayer.frame = CGRectMake(0, 0, CWLIVESSSCREEN_WIDTH, CWLIVESSSCREEN_HEIGHT-64);
    }
    [cameraView.layer insertSublayer:preLayer atIndex:0];
    
    [[CloudwalkFaceSDK shareInstance] cwStartLivess:CWLivePrepare];

}

#pragma mark
#pragma mark----------- captureOutputSampleBuffer   //视频流代理方法
/**
 *  @brief 视频流代理方法
 *
 *  @param sampleBuffer 视频流buffer
 *  @param bufferType   视频格式 1-BGRA kCVPixelFormatType_32BGRA  2-YUV420  kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
 *  @param direction 屏幕方向
 */

-(void)captureOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer bufferType:(NSInteger)bufferType{
    
    if(isStopLivess == NO){
        
        [[CloudwalkFaceSDK shareInstance] cwPushFrame:bufferType  screenDirection:CWScreenDirectionPortrait  frameBuffer:sampleBuffer];
    }
}

#pragma mark
#pragma mark----------- livessAction   //每一步活体动作
/**
 *  @brief 每一个活体动作
 */
-(void)livessAction{
    //总的动作个数大于0
    if (actionArray != nil && actionArray.count >0) {
        if (stepIndex ==0 && self.isRecord == YES) {
            [[CWCamera SharedInstance] startRecordingSizeMode:_videoSizeMode FrameRate:20 andPath:_videoPath];
        }
        NSString  * stepStr = [actionArray objectAtIndex:stepIndex];
        if ([stepStr isEqualToString:headLeft]) {
            audioFileName = @"left";
            //左转检测
            if (cameraType == CameraTypeFront) {
                //前置摄像头时左转检测
                [[CloudwalkFaceSDK shareInstance] cwStartLivess:CWLiveHeadTurnLeft];
            }else{
                //后置摄像头时是 右转检测
                [[CloudwalkFaceSDK shareInstance] cwStartLivess: CWLiveHeadTurnRight];
            }
        }
        else if ([stepStr isEqualToString:headRight]) {
            audioFileName = @"right";
            //右转检测
            if (cameraType == CameraTypeFront) {
                //前置摄像头时右转检测
                [[CloudwalkFaceSDK shareInstance] cwStartLivess:CWLiveHeadTurnRight];
            }else{
                //后置摄像头时是 左转检测
                [[CloudwalkFaceSDK shareInstance] cwStartLivess:CWLiveHeadTurnLeft];
            }
        }
        else if ([stepStr isEqualToString:headUp]) {
            audioFileName = @"top";
            //抬头检测
            [[CloudwalkFaceSDK shareInstance] cwStartLivess:CWLiveHeadRise];
        }else if ([stepStr isEqualToString:headDown]) {
            audioFileName = @"down";
            //点头检测
            [[CloudwalkFaceSDK shareInstance] cwStartLivess:CWLiveHeadDown];
        }
        else if ([stepStr isEqualToString:openMouth]) {
            audioFileName = @"openMouth";
            //张嘴检测
            [[CloudwalkFaceSDK shareInstance] cwStartLivess:CWLiveOpenMouth];
        }
        else if ([stepStr isEqualToString:blink]) {
            audioFileName = @"eye";
            //眨眼检测
            [[CloudwalkFaceSDK shareInstance] cwStartLivess:CWLiveBlink];
        }
        //播放音频文件
        [self playAudioFileName];
        
        //显示倒计时
        [self ShowCountProgressView:LivessOverTime];
        //设置每个动作的倒计时
        [self setTimerCountDown];
        
    }else if (self.livessNumber ==0){
        //活体动作为0时直接获取最佳人脸
        [self performSelector:@selector(liveDetectSucess) withObject:nil afterDelay:2];
    }
}

#pragma mark
#pragma mark VidioRecordingDelegae
-(void)recordingWillStart{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UIDevice currentDevice].multitaskingSupported)
            _backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
    });
}

-(void)recordingDidStop{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([UIDevice currentDevice].multitaskingSupported)
        {
            [[UIApplication sharedApplication] endBackgroundTask:_backgroundRecordingID];
            _backgroundRecordingID = UIBackgroundTaskInvalid;
        }
    });
}

#pragma mark
#pragma mark----------- showAnimation
/**
 *  @brief 根据当前动作显示提示动画
 *
 *  @param actionStr 当前动作名称
 */
-(void)showAnimation:(NSString *)actionStr{
    NSString    * imageName = [imageNameDictionary objectForKey:actionStr];  //动画提示
    UIImage * imageA = [UIImage imageNamed:[NSString stringWithFormat:@"CWResource.bundle/front@2x.png"]];
    UIImage * imageB = [UIImage imageNamed:[NSString stringWithFormat:@"CWResource.bundle/%@@2x.png",imageName]];
    animationView.hidden = NO;
    //动画图片切换
    [animationView showAnimation:imageA imageB:imageB];
}
#pragma mark
#pragma mark-----------  playAudioFileName // 播放提示音
/**
 *  @brief 播放语音
 *
 *  @param audioFileName 语音文件名
 */
-(void)playAudioFileName{
    //如果当前正在播放语音  先停止播放
    if(isAudioPlay){
        [[CWAudioPlayer sharedInstance] stopPlay];
        isAudioPlay = NO;
    }
    
    if (isAudioPlay == NO ) {
        
        NSString * path = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"CWResource.bundle/%@.mp3",audioFileName]];
        
        [[CWAudioPlayer sharedInstance] startPlayAudio:path AndDelegae:self];
        
        isAudioPlay = YES;
    }
}

#pragma mark
#pragma mark-----------  audioPlayFinished // 语音播放完成的代理方法
/**
 *  @brief 语音播放完成代理方法
 */
-(void)audioPlayFinished{
    
    if ([audioFileName isEqualToString:@"main"]) {
        //提示语音播放完成之后 检测人脸是否在取景框内
//        isDetectFace  = YES;
    }else if ([audioFileName isEqualToString:@"next2"] &&  isStopLivess == NO){
        [self livessAction];
    }
}

#pragma mark
#pragma mark----------- addCountDownProgressView //添加每一个动作的倒计时
/**
 *  @brief 显示倒计时View
 *
 *  @param time 倒计时
 */
-(void)ShowCountProgressView:(NSInteger)time{
    if (progressView == nil) {
        progressView = [[CWProgressView alloc]initWithFrame:CGRectMake(CWLIVESSSCREEN_WIDTH-70, 10, 60, 60)];
        [bottomView addSubview:progressView];
        
        progressView.outerBackgroundColor = CWFR_ColorFromRGB(51, 58, 66);
    }
    progressView.hidden = NO;
    
    progressView.progress = 1.0;
    
    progressView.showText = 1;
    
    progressView.progressText = time;
    
    progressView.roundedHead = 1;
    
    progressView.showShadow = 0;
}

#pragma mark
#pragma mark----------- setTimerCountDown   //设置倒计时
/**
 *  @brief 设置倒计时
 */

-(void)setTimerCountDown{
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setProgressViewPorgress) userInfo:nil repeats:YES];
}
#pragma mark
#pragma mark----------- stopTimer   //清空定时器
/**
 *  @brief 清空定时器
 */
-(void)stopTimer{
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
#pragma mark
#pragma mark----------- setProgressViewPorgress   //倒计时显示
/**
 *  倒计时显示
 */
-(void)setProgressViewPorgress{
    
    CGFloat  progress = 1.0 / LivessOverTime;
    if (progressView.progressText >= 1) {
        progressView.progressText -= 1;
        progressView.progress -= progress;
    }
    
    if (progressView.progressText == 0) {
        //返回检测超时
        errorCode = CW_FACE_LIVENESS_OVERTIME;
        [self stopTimer];
        [self liveDetecteFailed:@"检测超时,请在规定的时间内做出相应的动作!" audioFileName:@"overtime" isPlayAudio:YES];
    }
}

#pragma mark
#pragma mark----------- cwFaceInfoCallBack   //人脸检测代理方法
/**
 *  @brief 人脸检测代理方法
 *
 *  @param personsArry 返回人脸数组  人脸框坐标、关键点坐标 字典
 */
-(void)cwFaceInfoCallBack:(NSArray *)personsArry{
    
    if (personsArry.count >0) {
        
        NSDictionary  * dict = [personsArry objectAtIndex:0];
        
        int  faceltFlag = [[dict objectForKey:@"FaceltFlag"] intValue];
        
        if(faceltFlag >1 || faceltFlag == -5){
            [self livessTipsMessage:faceltFlag];
        }
        //语音提示完成
        if(isDetectFace && faceltFlag == 1){
            //判断人脸坐标是否在取景框内
            dispatch_async(dispatch_get_main_queue(), ^{
                [self livessStart];
            });
        }
    }
}

//根据算法内部返回的提示码进行文字提示
-(void)livessTipsMessage:(int)tipsCode{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (tipsCode) {
            case CW_FACE_PREPARE_TOOFAR:
                actionNameLabel.text = @"请再近一点";
                break;
            case CW_FACE_PREPARE_TOOCLOSE:
                actionNameLabel.text = @"请再远一点";
                break;
            case CW_FACE_PREPARE_FRONTAL:
                actionNameLabel.text = @"请正对屏幕";
                break;
            case CW_FACE_PREPARE_STABLE:
                actionNameLabel.text = @"请不要晃动手机";
                break;
            case CW_FACE_PREPARE_TOODARK:
                actionNameLabel.text = @"请保持光线充足";
                break;
            case CW_FACE_PREPARE_BRIGHT:{
                [[CWCamera SharedInstance] foucsWithPoint:CGPointMake(faceBoxRect.size.width/2, faceBoxRect.size.height/2+60)];
                actionNameLabel.text = @"请调整光线，避开强光";
            }
                break;
            case CW_FACE_PREPARE_NOTCENTER:
                actionNameLabel.text = @"请将人脸放入取景框中";
                break;
            case CW_FACE_PREPARE_NOFACE:
                actionNameLabel.text = @"检测不到人脸";
                break;
            case CW_FACE_PREPARE_FACECOVER:
                actionNameLabel.text = @"人脸被遮挡";
                break;
            case -5:
                actionNameLabel.text = @"请调整位置，更换背景";
                break;
            default:
                break;
        }
    });
}

/**
 *  @brief 检测到人脸在框内开始活体动作检测
 */

-(void)livessStart{
    
    isDetectFace  = NO;
    
    if (self.livessNumber >0 ) {
        tipsImageView.hidden = YES;
    }
    //开始活体检测
    [self livessAction];
    //显示动画和文字提示
    [self showAnimationViewAndText];
}

#pragma mark
#pragma mark----------- cwLivessInfoCallBack   //活体检测的代理方法
/**
 *  @brief 活体检测代理方法
 *
 *  @param contextType     活体检测的代码
 *  @param imageData       当前动作通过时保存的图片（JPG格式的）
 *  @param message   活体动作检测信息
 */
-(void)cwLivessInfoCallBack:(CW_LivenessCode)contextType liveImage:(NSData *)imageData message:(NSString *)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        errorCode = contextType;
        
        //检测到没人或者是多个人 或者是攻击则提示当前动作检测失败
        switch (contextType) {
                
            case CW_FACE_LIVENESS_NOPEPOLE:    //没有检测到人脸
            {
                
                [self liveDetecteFailed:@"检测失败，请按图示将人脸放入取景框中!" audioFileName:@"detectFailed" isPlayAudio:YES];
            }
                break;
            case CW_FACE_LIVENESS_MULTIPERSONE:  //检测到多个人
            {
                
                [self liveDetecteFailed:@"检测失败，检测到多个人!" audioFileName:@"detectFailed" isPlayAudio:YES];
            }
                break;
            case CW_FACE_LIVENESS_PEPOLECHANGED: //检测到换人
                
            case CW_FACE_LIVENESS_ATTACK_PICTURE:   //检测到图片攻击
            {
                [self liveDetecteFailed:@"检测失败,请正对屏幕、调整光线并按提示完成相应的动作!"  audioFileName:@"wrongAction" isPlayAudio:YES];
            }
                break;
            case CW_FACE_LIVENESS_OPENMOUTH:
            case CW_FACE_LIVENESS_BLINK:
            case CW_FACE_LIVENESS_HEADPITCH:
            case CW_FACE_LIVENESS_HEADDOWN:
            case CW_FACE_LIVENESS_HEADLEFT:
            case CW_FACE_LIVENESS_HEADRIGHT:
                [self liveDetectSucess];
                break;
            default:
                break;
        }
        
    });
}

#pragma mark
#pragma mark----------- liveDetectSucess 当前动作检测成功
/**
 *  @brief 检测成功
 */
-(void)liveDetectSucess{
    
    //当前检测成功停止倒计时
    [self stopTimer];
    
    //上一个动作检测成功，播放语音  进行下一个活体动作检测
    if (stepIndex < actionArray.count-1 && self.livessNumber >0) {
        
        audioFileName =  @"next2";
        
        [self playAudioFileName];
        
        stepIndex++;
        
        //显示下一个活体动作的动画
        [self showAnimationViewAndText];
        
    }else{
        
        isStopLivess = YES;
        
        if (self.isRecord) {
            [[CWCamera SharedInstance] stopRecording];
        }
        
        //获取最佳人脸原图的关键点数组
        __block NSArray * _keyPointArray;
        
        //获取最佳人脸原图头部角度数组
        __block NSArray * _headPoseArray;
        
        //最佳人脸图片原图base64字符串
        __block NSString  * bestFaceStr;
        
        //只能调用一次最佳人脸 ，调用之后就会把之前的缓存给清理
        [[CloudwalkFaceSDK shareInstance] cwGetBestFaceImage:^(NSData *originalData, NSData *bestFaceData, NSArray *keyPointArray, NSArray *headPoseArray) {
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
            
            bestFaceStr = [originalData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
#else
            bestFaceStr = [originalData base64Encoding]
#endif
            if(bestFaceData != nil){
                _bestFaceData = [[NSData alloc]initWithData:bestFaceData];
            }
            _keyPointArray = keyPointArray;
            
            _headPoseArray = headPoseArray;
        }];
        
        //后端防攻击字符串拼接 @"最佳人脸原图base64,关键点(前面9个x，后面9个y),最佳人脸头部角度(pitch,yaw,roll)_最佳人脸下一帧原图base64,关键点(前面9个x，后面9个y),最佳人脸下一帧原图头部角度(pitch,yaw,roll)"
        
        encryptjsonStr = [[NSMutableString alloc]init];
        
        //最佳人脸下一帧原图 base64字符串
        __block  NSString  * besetFaceNextFrameStr ;
        
        //最佳人脸下一帧原图关键点数组 前面9个x，后面9个为y
        __block NSArray * frameKeyPointArray;
        
        //最佳人脸下一帧原图人脸角度数组  pitch、yaw、roll
        __block NSArray *  frameHeadPoseArray;
        
        //获取最佳人脸一帧图以及关键点、角度
        [[CloudwalkFaceSDK shareInstance] cwGetBestFaceNextFrame:^(NSData *originalData, NSData *bestFaceData, NSArray *keyPointArray, NSArray *headPoseArray) {
            //最佳人脸下一帧原始图
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
            
            besetFaceNextFrameStr = [originalData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
#else
            besetFaceNextFrameStr = [originalData base64Encoding];
#endif
            frameKeyPointArray = keyPointArray;
            
            frameHeadPoseArray = headPoseArray;
        }];
        
        //判断最佳人脸和最佳人脸下一帧是否为空
        if (bestFaceStr != nil && besetFaceNextFrameStr != nil) {
            
            audioFileName =  @"next2";
            
            [self playAudioFileName];
            
            isALive = YES;
            
            [encryptjsonStr appendString:bestFaceStr];
            
            for (int i=0; i<_keyPointArray.count; i++) {
                [encryptjsonStr appendString:[NSString stringWithFormat:@",%@",[_keyPointArray objectAtIndex:i]]];
            }
            
            for (int i=0; i<_headPoseArray.count; i++) {
                [encryptjsonStr appendString:[NSString stringWithFormat:@",%@",[_headPoseArray objectAtIndex:i]]];
            }
            
            [encryptjsonStr appendString:[NSString stringWithFormat:@"_%@",besetFaceNextFrameStr]];
            
            for (int i=0; i<frameKeyPointArray.count; i++) {
                [encryptjsonStr appendString:[NSString stringWithFormat:@",%@",[frameKeyPointArray objectAtIndex:i]]];
            }
            
            for (int i=0; i<frameHeadPoseArray.count; i++) {
                [encryptjsonStr appendString:[NSString stringWithFormat:@",%@",[frameHeadPoseArray objectAtIndex:i]]];
            }
            
            //活体检测成功停止活体动作检测  可以在这里调用后端防攻击接口
            if (self.isShowResultView) {
                //播放检测成功的语音 显示成功界面
                audioFileName =  @"detectSucess";
                [self showFailedView:NO failedMessage:@"检测成功,感谢您的配合!"];
                [self playAudioFileName];
                
            }else{
                [self backToHomeViewController:nil];
            }
        }
        else{
            [self liveDetecteFailed:@"检测失败,请正对屏幕、调整光线并按提示完成相应的动作!" audioFileName:@"" isPlayAudio:NO];
        }
        
        //停止活体检测
        [[CloudwalkFaceSDK shareInstance] cwStoptLivess];
        
    }
}

#pragma mark
#pragma mark cwFaceliveness  后端活体验证
/**
 后端活体验证
 
 @param bestFace      最佳人脸图片
 @param keyPointArray 关键点数组
 @param pitch         抬头的角度
 @param yaw           偏头的角度
 @param roll          转头的角度
 */
-(void)cwFaceliveness:(NSString *)jsonStr{
    
//    [self showLoadingView:@"后端防hack攻击检测中...."];
//    
//    [[CWURLSession sharedClient] cwFaceLivess:self.ipaddress apiKey:self.app_idStr secretKey:self.app_secretStr encryptJsonStr:jsonStr block:^(NSInteger result,NSInteger param,  NSString * _Nullable info) {
//        
//        errorCode = result;
//        
//        //在主线程更新后端防hack攻击的结果
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            [self hidLoadingView];
//            
//            if(result == 0 && param == 1){
//                isALive = YES;
//                //播放检测成功的语音 显示成功界面
//                audioFileName =  @"detectSucess";
//                //显示后端防攻击检测失败
//                [self showHackerCheckView:NO hackerDetect:NO];
//                
//            }else{
//                isALive = NO;
//                //播放检测成功的语音 显示成功界面
//                audioFileName =  @"detectFailed";
//                
//                //显示后端防攻击检测失败
//                [self showHackerCheckView:NO hackerDetect:YES];
//            }
//            [self playAudioFileName];
//            
//        });
//    }];
}

#pragma mark
#pragma mark showHackerCheckView 显示后端防hack攻击是否成功的View
/**
 显示后端防hack攻击是否成功的View
 
 @param isFailed 是否成功
 */

-(void)showHackerCheckView:(BOOL)isDetectFailed hackerDetect:(BOOL) isHackerFailed{
    
    isShowFaildView = YES;

    //检测成功、失败界面显示时 需要先停止检测
    [self stopDetect];
    
    //后端防hack攻击检测的结果View
    hackerView = [[CWHackerCheckView alloc]initWithFrame:CGRectMake(CWLIVESSSCREEN_WIDTH, 64,CWLIVESSSCREEN_WIDTH, CWLIVESSSCREEN_HEIGHT-64)];
    
    [hackerView cwSetFrontDetectFailed:isDetectFailed hackerDetect:isHackerFailed];
    
    [self.view addSubview:hackerView];
    
    [self.view bringSubviewToFront:hackerView];
    
    //前端检测失败或者是后端检测失败提示View
    if (isDetectFailed || isHackerFailed) {
        
        [hackerView.suerButton setTitle:@"重新检测" forState:UIControlStateNormal];
        
        [hackerView.suerButton addTarget:self action:@selector(detectRedo) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //检测成功
    if ((!isDetectFailed) && (!isHackerFailed)) {
        
        //确定按钮
        [hackerView.suerButton addTarget:self action:@selector(backToHomeViewController:) forControlEvents:UIControlEventTouchUpInside];
        
        [hackerView.suerButton setTitle:@"确定" forState:UIControlStateNormal];
    }
    
    //设置坐标从右边出来
    [UIView animateWithDuration:0.2 animations:^{
        hackerView.frame = CGRectMake(0, 64, CWLIVESSSCREEN_WIDTH,CWLIVESSSCREEN_HEIGHT-64);
    } completion:^(BOOL flag){
        
    }];
}


#pragma mark
#pragma mark showLoadingView  人脸比对的等待View

-(void)showLoadingView:(NSString *)loadingStr{
    [[CWMBProgressHud sharedClient] showHudModel:NO message:loadingStr hudMode:CWMBProgressHudModeIndeterminate];
}

-(void)hidLoadingView{
    [[CWMBProgressHud sharedClient] hideHud];
}

#pragma mark
#pragma mark-----------  liveDetectFailed //当前动作检测失败
/**
 *  @brief 检测失败
 */
-(void)liveDetecteFailed:(NSString *)errorMsg audioFileName:(NSString *)audioName isPlayAudio:(BOOL)isPlayAudio{
    
    if (self.isRecord) {
        [[CWCamera SharedInstance] stopRecording];
    }
    
    isALive = NO;
    //是否显示结果页面
    if (self.isShowResultView) {
        //活体检测失败 显示失败界面
        [self showFailedView:YES failedMessage:errorMsg];
        if (isPlayAudio) {
            audioFileName = audioName;
            [self playAudioFileName];
        }
    }else
        [self backToHomeViewController: nil];
    
}

#pragma mark
#pragma mark-----------  showFailedView 、、显示是否检测成功的View
/**
 *  @brief 显示成功或失败的结果页面 (可替换成第三方自定义的结果页面)
 *
 *  @param isFailed  YES 失败页面、 NO 成功页面
 *  @param failedStr 成功、失败的提示语
 */

-(void)showFailedView:(BOOL)isFailed failedMessage:(NSString *)failedStr{
    
    isShowFaildView = YES;

    //检测成功、失败界面显示时 需要先停止检测
    [self stopDetect];
    
    UIColor  * animationColor;
    //显示成功或失败的结果页面
    if (isFailed) {
        self.title = @"识别失败";
        finishedView=[[CWFinishedView alloc]initWithFrame:self.view.bounds WithIsSuccessed:NO];
        //失败界面 返回按钮
        //[finishedView.backButton addTarget:self action:@selector(backToHomeViewController:) forControlEvents:UIControlEventTouchUpInside];
        //重新检测按钮
        [finishedView.redoButton addTarget:self action:@selector(detectRedo) forControlEvents:UIControlEventTouchUpInside];
        animationColor = CWFR_ColorFromRGB(216, 40, 42);
        
    }else{
        self.title = @"识别成功";
        finishedView=[[CWFinishedView alloc]initWithFrame:self.view.bounds WithIsSuccessed:YES];
        
        //确定按钮
        //[finishedView.suerButton addTarget:self action:@selector(backToHomeViewController:) forControlEvents:UIControlEventTouchUpInside];
        [finishedView.suerButton addTarget:self action:@selector(skipToNext) forControlEvents:UIControlEventTouchUpInside];
        animationColor = CWFR_ColorFromRGB(50, 195, 99);
    }
    
    if (self.navigationController !=nil && self.navigationController.navigationBarHidden == NO) {
        finishedView.isHideStatuesBar = YES;
    }
    finishedView.failedLabel.text = failedStr;
    
    [self.view addSubview:finishedView];
    
    [self.view bringSubviewToFront:finishedView];
    //设置坐标从右边出来
    finishedView.frame = CGRectMake(CWLIVESSSCREEN_WIDTH, 0,CWLIVESSSCREEN_WIDTH, CWLIVESSSCREEN_HEIGHT);
    //添加显示的动画
    [UIView animateWithDuration:0.2 animations:^{
        finishedView.frame = CGRectMake(0, 0, CWLIVESSSCREEN_WIDTH,CWLIVESSSCREEN_HEIGHT);
    } completion:^(BOOL flag){
        dispatch_async(dispatch_get_main_queue(), ^{
            [finishedView showAnimation:animationColor];
        });
    }];
}

#pragma mark
#pragma mark-----------   stopDetect 停止检测
//停止检测
-(void)stopDetect{
    
    isStartLive = NO;
    
    animationView.hidden = YES;
    progressView.hidden = YES;
    //停止倒计时
    [self stopTimer];
    
    [preLayer removeFromSuperlayer];
    //关闭摄像头
    [[CWCamera SharedInstance] cwStopCamera];
    //停止活体检测
    [[CloudwalkFaceSDK shareInstance] cwStoptLivess];
}

#pragma mark
#pragma mark-----------   detectRedo 重新检测
/**
 *  @brief 重新检测
 */
-(void)detectRedo{
    
    self.title = @"人脸识别";
    isShowFaildView = NO;

    guideView.frame =  CGRectMake(0, 64, CWLIVESSSCREEN_WIDTH, CWLIVESSSCREEN_HEIGHT-64);
    
    //添加显示的动画
    [UIView animateWithDuration:0.3 animations:^{
        if (hackerView != nil) {
            hackerView.frame = CGRectMake(CWLIVESSSCREEN_WIDTH, 64, CWLIVESSSCREEN_WIDTH,CWLIVESSSCREEN_HEIGHT-64);
        }
        if (finishedView != nil) {
            finishedView.frame = CGRectMake(CWLIVESSSCREEN_WIDTH, 0,CWLIVESSSCREEN_WIDTH, CWLIVESSSCREEN_HEIGHT);
        }
    } completion:^(BOOL flag){
        
    }];
    
    guideView.hidden = NO;
    
    cameraView.hidden = YES;
    
    [self.view layoutIfNeeded];
}

#pragma mark
#pragma mark----------- backToHomeViewController   //返回上一层界面
/**
 *  @brief 返回上一层界面
 *
 *  @param sender 返回按钮
 */
-(void)backToHomeViewController:(id)sender{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //停止检测  关闭摄像头
        [self stopDetect];
        
        [[CloudwalkFaceSDK shareInstance] cwDestroy];
        
        [animationView removeFromSuperview];
        //停止播放语音
        [[CWAudioPlayer sharedInstance] stopPlay];
        
        [CWAudioPlayer sharedInstance].delegate = nil;
        
        //执行代理方法
        if(self.delegate  && [self.delegate respondsToSelector:@selector(cwIntergrationLivess:errorCode:BestFaceImage:encryptJson:)]){
            
            [self.delegate cwIntergrationLivess:isALive errorCode:errorCode BestFaceImage:_bestFaceData encryptJson:encryptjsonStr];
        }
        
        if(self.navigationController != nil){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
    });
}
- (void)skipToNext{
//    //身份证OCR
//    CWOCRViewController * fvctrl = [[CWOCRViewController alloc]init];
//
//    fvctrl.licenseStr = AuthCodeString;
//
//    [self.navigationController pushViewController:fvctrl animated:YES];
//    IdentityAuthentication
//
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    IdentityAuthController * ids = (IdentityAuthController *)[storyboard instantiateViewControllerWithIdentifier:@"IdentityAuthentication"];
    ids.faceStr = encryptjsonStr;
    ids.faceImageData = _bestFaceData;
    [self.navigationController pushViewController:ids animated:YES];
}
#pragma mark
#pragma mark----------- preferredStatusBarStyle   //修改状态栏颜色
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;//只支持这一个方向(正常的方向)
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
