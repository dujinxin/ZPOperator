//
//  CWCaptureController.m
//  CloudwalkBankCardOCR
//
//  Created by DengWuPing on 16/11/16.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import "CWBankCardCaptureController.h"
#import "CWCaptureManager.h"
#import "CWCameraDrawView.h"
#import "CWMBProgressHud.h"

@interface CWBankCardCaptureController ()<CWCaptureManagerDelegate>{
    
    CGPoint            currTouchPoint; //对焦的焦点
    
    CloudwalkBankCardOCR   *  cardAliginClient;
    
    __block BOOL        isStartPush;  //是否pus视频帧
    
    NSInteger          createHandleRet; // 创建handle的返回结果
    
    __block NSInteger   frameCount;  //对焦之后选取的视频帧总数
    
    __block double     cardScore; //获取的银行卡图片质量分
    
    __block  UIImage    *  tempCardImage;
    
    BOOL               isRecogniseFinished; //是否完成扫描对齐检测
}

@property (nonatomic, strong) CWCameraDrawView * drawView;//扫描界面遮罩View

@property (nonatomic, strong) CWCaptureManager *captureManager; //相机预览类

@property (nonatomic, strong) NSTimer * foucsTimer; //每2s自动对焦timer

@property (nonatomic, strong) NSTimer * overtimeTimer; //20s扫描超时提醒Timer

@end

#define SC_DEVICE_SIZE      [[UIScreen mainScreen] bounds].size

#define  BEST_FRAME_COUNT 6

@implementation CWBankCardCaptureController

#pragma mark
#pragma mark --------------- init---------初始化设置默认值

-(id)init{
    self = [super init];
    if (self) {
        //设置默认阈值为0.65
        _qualityScore = 0.65f;
        //设置默认的银行卡类型为银行卡正面
        _cardType  =CWBankCardTypeFront;
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
    cardAliginClient = [CloudwalkBankCardOCR sharInstance];
    
    //初始化检测句柄、设置授权码
    createHandleRet  =   [cardAliginClient cwCreateCardHandle:self.authCodeStr];
    
    //判断授权是否成功
    if (createHandleRet != 0) {
        
        [[CWMBProgressHud sharedClient] showHudWithView:self.view isSuccess:NO message:@"授权失败!" hudMode:CWMBProgressHudModeCustomView isRotate:(M_PI/2)];
        
    }else{
        
        [cardAliginClient cwSetCardType:self.cardType];

        //自动对焦
        [self AutoFocus];

        //添加扫描超时定时器
        [self addOverTimeTimer];
        
        [self resetSelectStatus];
    }
}

#pragma mark
#pragma mark --------------- addOverTimeTimer---------//添加超时倒计时
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
    self.drawView.cardType = self.cardType;
    
    [self.drawView SetPreSize:self.captureManager.previewLayer.bounds.size];
    //关闭按钮
    [self.drawView.closeButton addTarget:self action:@selector(backToPreViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.drawView];
    
    [self.drawView showAnimation];
    
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
        [cardAliginClient cwDetectCardEdges:sampleBuffer  bufferType:CWCardAliginBufferTypeBGRA beginPoint:firstPoint endPoint:secondPoint completionBlock:^(CWCardDetectRet ret, BOOL isTopAlign, BOOL isBottomAlign, BOOL isLeftAlign, BOOL isRightAlign) {
            
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
            [self sendBankCardDeteDelegate:cardScore cardImage:tempCardImage];
        }
        else{
            
            self.qualityScore = 0.5f;
            //重置选择状态
            [self resetSelectStatus];
            
            [self AutoFocus];

        }
    }
}
#pragma mark
#pragma mark --------------- getCardImage---------//获取卡片对齐图像

-(void)getCardImage{
    
    //在四边对齐之后获取对齐之后的卡片图片
    [cardAliginClient cwGetAlignCardImage:^(CWCardDetectRet ret, double score, UIImage *  cardImage) {
        
        if (ret ==0) {
            //选取质量分大于阈值且在所选的x帧中质量分最好的图片
            if(score >_qualityScore && score > cardScore){
                
                cardScore = score;
                
                tempCardImage = cardImage;
            }
            frameCount ++;
        }
        //如果检测返回的质量分数大于0.8则直接返回无需再选择多帧
        if(score >0.8f && cardImage != nil){
            //是银行卡就在上面进行识别 身份证返回图片
            [self sendBankCardDeteDelegate:score cardImage:cardImage];
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
    
    cardScore = _qualityScore;
    
    isRecogniseFinished = NO;

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[CWMBProgressHud sharedClient]hideHud];
        
        [self invalidateTimer:_foucsTimer];

        if(_foucsTimer == nil){
            _foucsTimer  =[NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(AutoFocus) userInfo:nil repeats:YES];
        }
    });
}

/**
 银行卡识别
 */
//-(void)bankCardRecognise:(double)score cardImage:(UIImage *) cardImage{

//    //开始识别停止对齐检测
//    isStartPush = YES;
//    
//    isRecogniseFinished = YES;
//    
//    [self invalidateTimer:_foucsTimer];
//    
//    [self invalidateTimer:_overtimeTimer];
//    
//    [[CWMBProgressHud sharedClient] showHudWithView:self.view isSuccess:NO message:@"银行卡识别中...." hudMode:CWMBProgressHudModeIndeterminate isRotate:(M_PI/2)];
//    
//    NSData * cardImageData = UIImageJPEGRepresentation(cardImage, 0.6f);
//    
//    [[CWURLSession sharedClient] cwBankCardOcr:self.serVerUrl apiKey:self.appId secretKey:self.appSecretKey cardImageData:cardImageData block:^(NSDictionary * _Nullable cardInfo) {
//        
//        [[CWMBProgressHud sharedClient] hideHud];
//        
//        //判断发卡行名称、卡号是否为空
//        if([self isvalidCardInfo:cardInfo]){
//            [self sendBankCardDeteDelegate:score cardImage:cardImage cardInfo:cardInfo];
//        }else{
//            [self resetSelectStatus];
//        }
//    }];
    
//}

#pragma mark
#pragma mark --------------- sendBankCardDeteDelegate---------//发送代理

-(void)sendBankCardDeteDelegate:(double)score cardImage:(UIImage *)cardImage {
    
    //停止push视频帧
    isStartPush  = YES;
    //获取对齐卡片成功之后停止显示超时弹框
    isRecogniseFinished = YES;
    //在主线程执行
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(cwCardEdgesDetect:imageScore:)]) {
            
            [self.delegate cwCardEdgesDetect:cardImage imageScore:score];
        }
        [self backToPreViewController];
    });
}


#pragma mark
#pragma mark --------------- isvalidCardInfo---------//判断银行卡信息是否合法
/**
 判断银行卡信息是否合法
 
 @param cardInfo 银行卡结果字典
 @return YES or NO
 */
-(BOOL)isvalidCardInfo:(NSDictionary *)cardInfo{
    
    BOOL  isValid = YES;
    
    if (cardInfo == nil || [cardInfo objectForKey:@"BankName"]== nil || [cardInfo objectForKey:@"CardNum"] == nil || [[cardInfo objectForKey:@"BankName"] isEqualToString:@"unknown"]) {
        isValid = NO;
    }
    
    return isValid;
}

#pragma mark
#pragma mark  stopCamera -----关闭相机
-(void)stopCamera{
    [self.captureManager cwStopCamera];
}


#pragma mark
#pragma mark --------------- backToPreViewController---------//退出扫描界面
-(void)backToPreViewController{
    //释放扫描检测句柄
    [cardAliginClient cwDestroyCardHandle];
    //停止自动对焦timer
    [self invalidateTimer:_foucsTimer];
    //停止超时提醒timer
    [self invalidateTimer:_overtimeTimer];
    
    [self.drawView stopAnimation];

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
