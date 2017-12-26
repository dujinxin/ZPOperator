//
//  CWCaptureManager.m
//  CWCaptureManager
//
//  Created by DengWuPing on 16/11/7.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import "CWCaptureManager.h"
#import <ImageIO/ImageIO.h>

@interface CWCaptureManager ()<AVCaptureVideoDataOutputSampleBufferDelegate>{
    
    UIImageView  *  _focusView;
}

@property (nonatomic, strong) UIView *preview;

@end

@implementation CWCaptureManager

#pragma mark -
#pragma mark configure
- (id)init {
    self = [super init];
    if (self != nil) {
    }
    return self;
}
#pragma mark
#pragma mark---------------- cwConfigureWithParentLayer

- (void)cwConfigureWithParentLayer:(UIView*)parent previewRect:(CGRect)preivewRect {
    
    self.preview = parent;
    
    //1、队列
    [self createQueue];
    
    //2、session
    [self addSession];
    
    //3、previewLayer
    [self addVideoPreviewLayerWithRect:preivewRect];
    [parent.layer addSublayer:_previewLayer];
    //4、input
    [self addVideoInputFrontCamera:NO];
    
    //5、output
    [self addVideoOutput];
    
    AVCaptureDevice *camDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    int flags =NSKeyValueObservingOptionNew;
    [camDevice addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
    
    _focusView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 80)];
    
    _focusView.backgroundColor = [UIColor clearColor];
    
    _focusView.image = [UIImage imageNamed:@"CWResource.bundle/focs"];
    
    [self.preview addSubview:_focusView];
    
    _focusView.hidden = YES;
    
}

#pragma mark
#pragma mark---------------- createQueue  创建一个队列
/**
 *  创建一个队列，防止阻塞主线程
 */
- (void)createQueue {
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    self.sessionQueue = sessionQueue;
}
#pragma mark
#pragma mark---------------- addSession  session
/**
 *  session
 */
- (void)addSession {
    
    NSString *mediaType = AVMediaTypeVideo;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if ((![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])|| authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"请在iPhone的\"设置-隐私-相机\"选项中，允许访问您的相机。"] delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
    }else if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] && [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])//判断是否支持前置摄像头
    {
        AVCaptureSession *tmpSession = [[AVCaptureSession alloc] init];
        self.session = tmpSession;
        //设置质量
        _session.sessionPreset = AVCaptureSessionPresetiFrame1280x720;
        
        if(!_session.isRunning){
            [_session startRunning];
        }
    }
}
#pragma mark
#pragma mark---------------- addVideoPreviewLayerWithRect  相机的实时预览
/**
 *  相机的实时预览页面
 *
 *  @param previewRect 预览页面的frame
 */
- (void)addVideoPreviewLayerWithRect:(CGRect)previewRect {
    
    AVCaptureVideoPreviewLayer *preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = previewRect;
    self.previewLayer = preview;
}

#pragma mark
#pragma mark---------------- addVideoInputFrontCamera  添加输入设备
/**
 *  添加输入设备
 *
 *  @param front 前或后摄像头
 */
- (void)addVideoInputFrontCamera:(BOOL)front {
    
    NSArray *devices = [AVCaptureDevice devices];
    
    AVCaptureDevice *frontCamera;
    
    AVCaptureDevice * backCamera;
    
    for (AVCaptureDevice *device in devices) {
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                backCamera = device;
                
            }  else {
                frontCamera = device;
            }
        }
    }
    
    NSError *error = nil;
    
    if (front) {
        AVCaptureDeviceInput *frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        
        if (!error) {
            
            if ([frontCamera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                [frontCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
            }
            
            if ([_session canAddInput:frontFacingCameraDeviceInput]) {
                [_session addInput:frontFacingCameraDeviceInput];
                self.inputDevice = frontFacingCameraDeviceInput;
            }
        }
    } else {
        AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!error) {
            
            if ([backCamera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                [backCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
            }
            
            if ([_session canAddInput:backFacingCameraDeviceInput]) {
                [_session addInput:backFacingCameraDeviceInput];
                self.inputDevice = backFacingCameraDeviceInput;
            }
        }
    }
}
#pragma mark
#pragma mark---------------- addVideoOutput  关添加输出设备
/**
 *  添加输出设备
 */
- (void)addVideoOutput {
    
    self.output = [[AVCaptureVideoDataOutput alloc]
                   init];
    self.output.alwaysDiscardsLateVideoFrames = YES;
    
    dispatch_queue_t queue;
    
    queue = dispatch_queue_create("cameraQueue", NULL);
    
    [self.output setSampleBufferDelegate:self queue:queue];
    
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    
    NSNumber* value = [NSNumber
                       numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    
    [self.output setVideoSettings:videoSettings];
    
    [_session addOutput:self.output];
    
}


-(void)cwPauseCamera{
    if (self.session && [self.session isRunning]) {
        [self.session stopRunning];
    }
}

-(void)cwResumCamera{
    
    if (self.session && (![self.session isRunning])) {
        [self.session startRunning];
    }
}

#pragma mark
#pragma mark---------------- cwStopCamera  关闭相机

-(void)cwStopCamera{
    
    if(self.session){
        
        AVCaptureDevice * camDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        @try {
            [camDevice removeObserver:self forKeyPath:@"adjustingFocus" context:nil];
        } @catch (NSException *exception) {
            
        } @finally {
            [self.session stopRunning];
        }
    }
}

#pragma mark
#pragma mark---------------- captureOutput  采集音视频流的代理方法
/**
 采集音视频流的代理方法
 
 @param captureOutput 输出设备
 @param sampleBuffer  音视频流
 @param connection    connection
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer    fromConnection:(AVCaptureConnection *)connection {
    //判断代理是否存在 是否响应代理方法
    if (self.delegate  && [self.delegate respondsToSelector:@selector(captureSampleBuffer:)]) {
        [self.delegate captureSampleBuffer:sampleBuffer];
    }
}
#pragma mark
#pragma mark---------------- cwFocusInPoint  对焦
/**
 *  点击后对焦
 *
 *  @param devicePoint 点击的point
 */

- (void)cwFocusInPoint:(CGPoint)devicePoint {
    
    //判断是否显示对焦的View
    if(self.isShowFoucsView){
        
        self.isShowFoucsView = NO;
        
        _focusView.center = devicePoint;
        
        _focusView.hidden = NO;
        
        [self.preview bringSubviewToFront:_focusView];
        
        [UIView animateWithDuration:0.3 animations:^{
            _focusView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                _focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                _focusView.hidden = YES;
            }];
        }];
    }
    
    devicePoint = [self convertToPointOfInterestFromViewCoordinates:devicePoint];
    
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

#pragma mark
#pragma mark---------------- focusWithMode

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    
    if(_sessionQueue != nil){
        dispatch_async(_sessionQueue, ^{
            AVCaptureDevice *device = [_inputDevice device];
            NSError *error = nil;
            if ([device lockForConfiguration:&error])
            {
                //对焦模式和对焦点
                if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
                {
                    [device setFocusPointOfInterest:point];
                    [device setFocusMode:focusMode];
                }
                //曝光模式和曝光点
                if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
                {
                    [device setExposurePointOfInterest:point];
                    [device setExposureMode:exposureMode];
                }
                
                [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
                
                [device unlockForConfiguration];
            }
        });
    }
}

// 监听焦距发生改变
-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    
    if([keyPath isEqualToString:@"adjustingFocus"]){
        
        BOOL adjustingFocus =[[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        
        // 0代表焦距不发生改变 1代表焦距改变
        if (adjustingFocus == 0 && self.delegate!= nil && [self.delegate respondsToSelector:@selector(captureFoucsFinished)]) {
            
            [self.delegate captureFoucsFinished];
        }
    }
}

- (void)subjectAreaDidChange:(NSNotification *)notification {
    
    CGPoint devicePoint = CGPointMake(.5, .5);
    
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark
#pragma mark---------------- convertToPointOfInterestFromViewCoordinates 外部的point转换为camera需要的point
/**
 *  外部的point转换为camera需要的point(外部point/相机页面的frame)
 *
 *  @param viewCoordinates 外部的point
 *
 *  @return 相对位置的point
 */
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    
    CGSize frameSize = _previewLayer.bounds.size;
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = self.previewLayer;
    
    if(frameSize.height !=0 && frameSize.width !=0){
        if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResize] && frameSize.height !=0 && frameSize.width !=0) {
            pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
        } else {
            
            CGRect cleanAperture;
            
            for(AVCaptureInputPort *port in [[self.session.inputs lastObject]ports]) {
                
                if([port mediaType] == AVMediaTypeVideo) {
                    
                    cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                    
                    CGSize apertureSize = cleanAperture.size;
                    
                    CGPoint point = viewCoordinates;
                    
                    CGFloat apertureRatio = 0.f;
                    
                    if(apertureSize.width !=0){
                        apertureRatio = (apertureSize.height / apertureSize.width);
                    }else{
                        apertureRatio = apertureSize.height;
                    }
                    
                    CGFloat viewRatio = frameSize.width / frameSize.height;
                    
                    CGFloat xc = .5f;
                    
                    CGFloat yc = .5f;
                    
                    if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspect]) {
                        
                        if(viewRatio > apertureRatio) {
                            CGFloat y2 = frameSize.height;
                            CGFloat x2 = frameSize.height * apertureRatio;
                            CGFloat x1 = frameSize.width;
                            
                            CGFloat blackBar = (x1 - x2) / 2;
                            
                            if(point.x >= blackBar && point.x <= blackBar + x2) {
                                
                                xc = y2!=0 ? (point.y / y2) : 0.f;
                                
                                yc = x2 !=0 ? (1.f - ((point.x - blackBar) / x2)) : 1.f ;
                            }
                        } else {
                            CGFloat y2 =  apertureRatio!=0 ? (frameSize.width / apertureRatio) : 1.f;
                            
                            CGFloat y1 = frameSize.height;
                            
                            CGFloat x2 = frameSize.width;
                            
                            CGFloat blackBar = (y1 - y2) / 2;
                            if(point.y >= blackBar && point.y <= blackBar + y2) {
                                
                                xc = y2!=0 ? ((point.y - blackBar) / y2) : 0.f ;
                                yc = 1.f - (point.x / x2);
                            }
                        }
                    } else if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                        if(viewRatio > apertureRatio) {
                            
                            CGFloat y2 = apertureSize.height !=0 ? (apertureSize.width * (frameSize.width / apertureSize.height)) : 1.f;
                            
                            xc = y2 !=0.f ? ((point.y + ((y2 - frameSize.height) / 2.f)) / y2) : 0.f;
                            
                            yc = (frameSize.width - point.x) / frameSize.width;
                            
                        } else {
                            
                            CGFloat x2 = apertureSize.width!=0.f ? (apertureSize.height * (frameSize.height / apertureSize.width)) : 0.f;
                            
                            yc =  x2  !=0.f ? (1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2)) : 0.f;
                            
                            xc = point.y / frameSize.height;
                        }
                    }
                    
                    pointOfInterest = CGPointMake(xc, yc);
                    
                    break;
                }
            }
        }
    }
    return pointOfInterest;
}

@end
