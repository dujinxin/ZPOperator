//
//  CWCaptureController.m
//  CloudwalkBankCardOCR
//
//  Created by DengWuPing on 16/11/16.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import "CWIDCardCaptureController.h"
#import "CWCaptureManager.h"
#import "CWCameraDrawView.h"
#import "CWMBProgressHud.h"

@interface CWIDCardCaptureController ()<CWCaptureManagerDelegate>{
    
    CGPoint            currTouchPoint;
    
    CloudwalkIDCardOCR   *  cardAliginClient;
    
    __block BOOL        isStartPush;  //是否pus视频帧
    
    NSInteger          createHandleRet; // 创建handle的返回结果
    
    __block NSInteger   frameCount;  //对焦之后选取的视频帧总数
    
    __block double     qualityScore; //获取的身份证图片质量分
    
    __block  UIImage    *  tempCardImage;
    
    BOOL               isRecogniseFinished; //是否完成识别
    
    
}

@property (nonatomic, strong) CWCameraDrawView * drawView;

@property (nonatomic, strong) CWCaptureManager *captureManager;

@property (nonatomic, strong) NSTimer * foucsTimer;

@property (nonatomic, strong) NSTimer * overtimeTimer;

@end

#define SC_DEVICE_SIZE      [[UIScreen mainScreen] bounds].size

#define  BEST_FRAME_COUNT 6

@implementation CWIDCardCaptureController

#pragma mark
#pragma mark --------------- init---------初始化设置默认值
-(id)init{
    self = [super init];
    if (self) {
        //初始话设置默认的图像清晰度阈值为0.62
        _cardQualityScore = 0.62f;
    }
    return self;
}

#pragma mark
#pragma mark --------------- viewDidLoad---------SDK初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置相机预览界面的Rect
    UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    isStartPush = YES;
    
    //设置预览大小
    if(statusBarOrientation == UIInterfaceOrientationLandscapeLeft || statusBarOrientation == UIInterfaceOrientationLandscapeRight){
        self.previewRect = CGRectMake(0, 0, SC_DEVICE_SIZE.height,SC_DEVICE_SIZE.width);
    }else{
        self.previewRect = CGRectMake(0, 0, SC_DEVICE_SIZE.width, SC_DEVICE_SIZE.height);
    }
    //摄像头操作实例
    _captureManager = [[CWCaptureManager alloc] init];
    
    _captureManager.delegate = self;
    //设置视频预览的父View和大小
    [_captureManager cwConfigureWithParentLayer:self.view previewRect:self.previewRect];
    //添加遮罩层
    [self addShadowBoxView];
    //自动对焦的焦点
    currTouchPoint = self.view.center;
    
    //创建对齐检测句柄
    cardAliginClient = [CloudwalkIDCardOCR sharInstance];
    
    //初始化检测句柄、设置授权码
    createHandleRet  =   [cardAliginClient cwCreateIdCardRecog:self.lisenceStr];
    
    //判断授权是否成功
    if (createHandleRet != 0) {
        
        [[CWMBProgressHud sharedClient] showHudWithView:self.view isSuccess:NO message:@"扫描初始化失败!" hudMode:CWMBProgressHudModeCustomView isRotate:(M_PI/2)];
    }else{
        
        [cardAliginClient cwSetCardType:self.type];

        //自动对焦
        [self AutoFocus];
        
        [self addOverTimeTimer];

        [self resetSelectStatus];
    }
}

#pragma mark
#pragma mark --------------- addOverTimeTimer---------//添加超时倒计时
//添加超时倒计时
-(void)addOverTimeTimer{
    
    [self invalidateTimer:_overtimeTimer];
    
    //设置扫描12s超时倒计时
    _overtimeTimer = [NSTimer scheduledTimerWithTimeInterval:12.f target:self selector:@selector(showOverTime) userInfo:nil repeats:NO];
}
#pragma mark
#pragma mark --------------- invalidateTimer---------//停止定时器
-(void)invalidateTimer:(NSTimer *)timer{
    
    if (timer != nil) {
        
        [timer invalidate];
        
        timer = nil;
    }
}

#pragma mark
#pragma mark --------------- showOverTime---------//显示超时提示
-(void)showOverTime{
    
    isStartPush = YES;
    
    if (isRecogniseFinished == NO ) {
        
        [[CWMBProgressHud sharedClient] showHudWithView:self.view isSuccess:NO message:@"扫描超时,请正对卡片、调整光线避免反光或背光!" hudMode:CWMBProgressHudModeText isRotate:(M_PI/2)];
        
        [self performSelector:@selector(AutoFocus) withObject:nil afterDelay:2.f];
    }
}

#pragma mark
#pragma mark --------------- AutoFocus---------//自动对焦
-(void)AutoFocus{
    if (_captureManager != nil) {
        [_captureManager cwFocusInPoint:currTouchPoint];
    }
}

-(void)captureFoucsFinished{
    if (isRecogniseFinished == NO) {
        isStartPush = NO;
    }
}

#pragma mark
#pragma mark --------------- addShadowBoxView---------//添加半透明遮罩层
/**
 添加遮罩层View
 */
-(void)addShadowBoxView{
    
    self.drawView = [[CWCameraDrawView alloc]initWithFrame:self.previewRect];
    
    self.drawView.backgroundColor = [UIColor clearColor];
    
    //设置卡片类型 根据不同类型的卡片显示不同的提示语

    self.drawView.cardType = self.type;
    
    [self.drawView SetPreSize:self.captureManager.previewLayer.bounds.size];
    //关闭按钮
    [self.drawView.closeButton addTarget:self action:@selector(backToPreViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.drawView];
}

#pragma mark
#pragma mark --------------- touchesBegan---------//点击屏幕进行自动对焦
/**
 屏幕点击事件
 @param touches 触摸
 @param event   点击事件
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    CGPoint  touchPoint = [touch locationInView:self.view];
    
    if (CGRectContainsPoint(_captureManager.previewLayer.bounds, touchPoint) == NO) {
        return;
    }
    _captureManager.isShowFoucsView = YES;
    //自动对焦
    [_captureManager cwFocusInPoint:touchPoint];
}

#pragma mark
#pragma mark --------------- captureSampleBuffer---------//视频帧采集回调代理方法
/**
 视频帧采集回调代理方法
 
 @param sampleBuffer 视频帧buffer
 */
-(void)captureSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    if (createHandleRet == 0 && isStartPush == NO) {
        //检测框起点
        CGPoint  firstPoint = CGPointMake(self.drawView.beginPoint.x,self.drawView.beginPoint.y);
        //检测框终点
        CGPoint  secondPoint = CGPointMake(self.drawView.endPoint.x,self.drawView.endPoint.y);
        
        isStartPush = YES;
        //卡片对其检测
        [cardAliginClient cwDetectIdCard:sampleBuffer bufferType:CWCardAliginBufferTypeBGRA beginPoint:firstPoint endPoint:secondPoint completionBlock:^(CWCardDetectRet ret, BOOL isTopAlign, BOOL isBottomAlign, BOOL isLeftAlign, BOOL isRightAlign) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //画四条边
                [self.drawView showLineUP:isLeftAlign  right:isTopAlign bottom:isRightAlign left:isBottomAlign];
            });
            
            //判断4边对齐 才进行下一步
            if (CWCardDetectRetOk == ret) {
                //获取对齐之后的卡片图片
                [self selectBestFrame];
                
            }else{
                isStartPush = NO;
            }
        }];
    }
}

#pragma mark
#pragma mark --------------- selectBestFrame---------//选择最佳图片帧
/**
 选择最佳图片帧
 */
-(void)selectBestFrame{
    
    //选取n帧中质量分数最好的一帧
    if (frameCount < BEST_FRAME_COUNT ) {
        [self getCardImage];
    }else{
        if (tempCardImage != nil) {
            //获取到质量分最高的一帧图片 通过代理方法进行返回
            [self sendDeteDelegate:qualityScore cardImage:tempCardImage];
        }
        else{
            //阈值达不到0.62则降为0.55
            self.cardQualityScore = 0.55f;
            [self resetSelectStatus];
            [self AutoFocus];
        }
    }
}

#pragma mark
#pragma mark --------------- getCardImage---------//获取卡片对齐图像
-(void)getCardImage{
    
    [cardAliginClient cwGetAlignCardImage:^(CWCardDetectRet ret, double score, UIImage *  cardImage) {
        
        if (ret ==0) {
            //选取质量分最好的图片
            if(score >_cardQualityScore && score > qualityScore){
                
                qualityScore = score;
                
                tempCardImage = cardImage;
            }
            frameCount ++;
        }
        //如果检测返回的质量分数大于0.8则直接识别
        if(score >0.8f && cardImage != nil){
            [self sendDeteDelegate:score cardImage:cardImage];
        }else{
            isStartPush  = NO;
        }
    }];
}

#pragma mark
#pragma mark --------------- resetSelectStatus---------//重置选择状态

/**
 重置选择状态
 */
-(void)resetSelectStatus{

    frameCount = 0;
    
    tempCardImage = nil;
    
    qualityScore = _cardQualityScore;
    
    isRecogniseFinished = NO;

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[CWMBProgressHud sharedClient]hideHud];
        
        [self invalidateTimer:_foucsTimer];
        
        if (_foucsTimer == nil) {
            _foucsTimer  =[NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(AutoFocus) userInfo:nil repeats:YES];
        }
    });
   
}

#pragma mark
#pragma mark --------------- sendDeteDelegate---------//发送代理
/**
 发送结果代理方法
 
 @param dict 身份证识别结果
 */
-(void)sendDeteDelegate:(double)score cardImage:(UIImage *)cardImage{
    
    isStartPush  = YES;
    
    isRecogniseFinished = YES;
    //在主线程执行
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(cwIdCardDetectionCardImage:imageScore:)]) {
            
            [self.delegate cwIdCardDetectionCardImage:cardImage imageScore:score];
        }
        [self backToPreViewController];
    });
}

#pragma mark
#pragma mark  stopCamera -----关闭相机
-(void)stopCamera{
    [self.captureManager cwStopCamera];
}

-(void)backToPreViewController{
    
    [cardAliginClient cwDestroyIdCardRecog];
    
    [self invalidateTimer:_foucsTimer];
    
    [self invalidateTimer:_overtimeTimer];
    
    //先关闭摄像头
    [self stopCamera];
    
    //退出相机页面
    if (self.navigationController != nil) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
}
#pragma mark ---------rotate(only when this controller is presented, the code below effect)-------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
//iOS6+
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
#endif

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
