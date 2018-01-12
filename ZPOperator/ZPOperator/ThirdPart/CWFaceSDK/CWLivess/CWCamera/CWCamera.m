//
//  CWCamera.m
//
//  Created by dengwuping on 15/4/1.
//  Copyright (c) 2015年 dengwuping. All rights reserved.
//

#import "CWCamera.h"
#import <CoreMedia/CoreMedia.h>
#import <CoreMedia/CMMetadata.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CWCamera () <AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate,UIAlertViewDelegate>
{
    AVCaptureSession					*_captureSession;//相机session
    
    AVCaptureDevice                     *_videoDevice;//相机设备
    
    AVCaptureDeviceInput                * videoInPut;
    
    AVCaptureConnection					*_videoConnection; //视频
    
    AVCaptureConnection					*_audioConnection;//音频
    
    AVCaptureVideoPreviewLayer          *_Prelayer; //视频流预览
    CWCameraOrientation                 _camraOrientaion;
    
    
    AVCaptureVideoDataOutput           *  videoOut;
    
    CWCameraType                       currentCameraType;//当前摄像头类型
    NSURL								*_movieURL; //视频地址
    AVAssetWriter						*_assetWriter;
    AVAssetWriterInput					*_assetWriterAudioIn;
    
    AVAssetWriterInput					*_assetWriterVideoIn;
    
    dispatch_queue_t					_movieWritingQueue;//写视频的线程
    BOOL							    _readyToRecordVideo;
    
    BOOL								_readyToRecordAudio;
    
    BOOL								_readyToRecordMetadata;
    BOOL								_recordingWillBeStarted;   //即将开始录制视频
    BOOL								_recordingWillBeStopped;   //即将停止录制
    BOOL                                _StopRecord; // 停止录制
    
    NSInteger                           _width; // 视频宽
    
    NSInteger                           _height; //视频高
    
    double                              _frameRate;  //视频帧率
    int                                rotateType;  //push的视频帧是否进行旋转
    NSString                           *vedioPath; //视频存储地址
    dispatch_queue_t queue;
    
}

@property (readwrite, getter=isRecording) BOOL	recording;//是否录制

@property (readwrite) AVCaptureVideoOrientation videoOrientation;//

@end

#define CW_IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//屏幕宽
#define CW_MAMERA_WIDTH  [[UIScreen mainScreen] bounds].size.width
//屏幕高
#define CW_MAMERA_HEIGHT  [[UIScreen mainScreen] bounds].size.height

@implementation CWCamera

#pragma mark
#pragma mark------------ SharedInstance
+(instancetype)SharedInstance{
    static CWCamera * instance;
    static dispatch_once_t once_t;
    dispatch_once(&once_t,^{
        instance = [[CWCamera alloc]initSingle];
    });
    return instance;
}

//只是把原来在init方法中的代码，全都搬到initSingle
- (id)initSingle{
    self = [super init];
    if(self){
        
        self.referenceOrientation = AVCaptureVideoOrientationPortrait;
        
        _movieWritingQueue = dispatch_queue_create("Movie Writing Queue", DISPATCH_QUEUE_SERIAL);
        
    }
    return self;
}

- (id)init{
    return [CWCamera SharedInstance];
}

#pragma mark
#pragma mark----------- setupCaptureSessionCameraType //初始化相机

- (BOOL)setupCaptureSessionCameraType:(AVCaptureDevicePosition)cameraType{
    
    /*
     * Create capture session
     */
    _captureSession = [[AVCaptureSession alloc] init];
    
    //设置视频质量
    if([self.session canSetSessionPreset:AVCaptureSessionPreset640x480])
        [self.session setSessionPreset:AVCaptureSessionPreset640x480];
    
    [self addVideoInput:currentCameraType];
    
    [self addVideoOutPut:currentCameraType];
    
    [self addAudioIn];
    
    return YES;
}

#pragma mark
#pragma mark----------- addVideoInput  //添加视频输入
/**
 *  @brief  添加视频输入
 *
 *  @param cameraType  摄像头类型
 */

-(void)addVideoInput:(CWCameraType)cameraType{
    
    if (videoInPut != nil) {
        videoInPut = nil;
    }
    
    if (cameraType == CameraTypeFront) {
        _videoDevice = [self videoDeviceWithPosition:AVCaptureDevicePositionFront];
        if (_videoConnection != nil) {
            _videoConnection.videoMirrored = YES;
        }
    }else{
        _videoDevice = [self videoDeviceWithPosition:AVCaptureDevicePositionBack];
        if (_videoConnection != nil) {
            _videoConnection.videoMirrored = NO;
        }
    }
    
    videoInPut = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:nil];
    
    if ([_captureSession canAddInput:videoInPut])
        [_captureSession addInput:videoInPut];
    
}

#pragma mark
#pragma mark----------- addVideoOutPut  //添加视频输出

/**
 *  @brief 添加视频输出
 *
 *  @param cameraType  摄像头类型
 */

-(void)addVideoOutPut:(CWCameraType)cameraType{
    
    if (videoOut != nil) {
        videoOut = nil;
    }
    
    //添加videooutPut
    videoOut = [[AVCaptureVideoDataOutput alloc] init];
    
    [videoOut setAlwaysDiscardsLateVideoFrames:YES];
    
    //设置视频流格式为BGRA格式
    [videoOut setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
    //kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
    
    if ([_videoDevice lockForConfiguration:nil]) {
        
#ifdef __IPHONE_7_0
        if (_videoDevice.activeFormat.videoSupportedFrameRateRanges)
        {
            [_videoDevice setActiveVideoMinFrameDuration:CMTimeMake(10, 300)];
            
            [_videoDevice setActiveVideoMaxFrameDuration:CMTimeMake(10, 300)];
        }
        
        //设置自动对焦 当场景改变时自动对焦
        if([_videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
            //设置自动对焦 当场景改变时自动对焦
            _videoDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }else  if([_videoDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
            //设置自动对焦 当场景改变时自动对焦
            _videoDevice.focusMode = AVCaptureFocusModeAutoFocus;
        }
        
        //设置ISO的值 必须是在min 和max之间
        //        [_videoDevice setExposureModeCustomWithDuration:CMTimeMake(10, 300) ISO:100 completionHandler:nil];
        
        [_videoDevice unlockForConfiguration];
#endif
    }
    
    queue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
    
    [videoOut setSampleBufferDelegate:self queue:queue];
    
    if ([_captureSession canAddOutput:videoOut])
        [_captureSession addOutput:videoOut];
    
    /*
     * Create video connection
     */
    
    _videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
    
    //前置摄像头镜像
    if(cameraType == CameraTypeFront){
        //是否镜像
        _videoConnection.videoMirrored = YES;
    }else
        _videoConnection.videoMirrored = NO;
    
    if (_videoConnection.supportsVideoOrientation ) {
        switch (_camraOrientaion) {
            case CameraOrientationPortrait:
                _videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
            case CameraOrientationPortraitUpsideDown:
                _videoConnection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            case CameraOrientationLeft:
                _videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case CameraOrientationRight:
                _videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            default:
                break;
        }
    }
}


/**
 对焦设置曝光点
 
 @param point 焦点
 */
-(void)foucsWithPoint:(CGPoint)point{
    
    CGPoint devicePoint = [self convertToPointOfInterestFromViewCoordinates:point];
    
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

#pragma mark
#pragma mark---------------- focusWithMode

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    
    if(queue != nil){
        dispatch_async(queue, ^{
            
            AVCaptureDevice *device = [videoInPut device];
            
            NSError *error = nil;
            
            if ([device lockForConfiguration:&error])
            {
                if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
                {
                    
                    [device setFocusPointOfInterest:point];
                    [device setFocusMode:focusMode];
                }
                
                if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
                {
                    [device setExposurePointOfInterest:point];
                    [device setExposureMode:exposureMode];
                }
                
                [device unlockForConfiguration];
            }
        });
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
    
    CGSize frameSize = CGSizeMake(CW_MAMERA_WIDTH, CW_MAMERA_HEIGHT-64);
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = _Prelayer;
    
    if(frameSize.height !=0 && frameSize.width !=0){
        
        if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResize] && frameSize.height !=0 && frameSize.width !=0) {
            
            pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
        } else {
            
            CGRect cleanAperture;
            
            for(AVCaptureInputPort *port in [[self.session.inputs firstObject]ports]) {
                
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


#pragma mark
#pragma mark----------- addAudioIn //添加音频输入
-(void)addAudioIn{
    AVCaptureDeviceInput * audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
    if ([_captureSession canAddInput:audioIn])
        [_captureSession addInput:audioIn];
    AVCaptureAudioDataOutput * audioOut = [[AVCaptureAudioDataOutput alloc] init];
    dispatch_queue_t audioCaptureQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
    
    [audioOut setSampleBufferDelegate:self queue:audioCaptureQueue];
    
    if ([_captureSession canAddOutput:audioOut])
        [_captureSession addOutput:audioOut];
    
    _audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
    
}

#pragma mark
#pragma mark----------- videoDeviceWithPosition //获取相机设备 前后摄像头
- (AVCaptureDevice *)videoDeviceWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
        
        if (device.position == position){
            
            return device;
            
        }
    return nil;
}

#pragma mark
#pragma mark----------- audioDevice //获取音频设备

- (AVCaptureDevice *)audioDevice{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if (devices.count > 0)
        return [devices firstObject];
    return nil;
}

#pragma mark
#pragma mark----------- StartCamera //打开相机获取摄像头视频流
/**
 *  @brief 打开相机
 *
 *  @param cameratype     相机类型、前置或后置
 *  @param orintation     屏幕方向
 *  @param rect           预览展示大小
 *  @param superView      展示预览layer的父View
 *  @param cameraDelegate 视频流回调代理
 *
 *  @return YES成功
 */
-(AVCaptureVideoPreviewLayer *)cwStartCamera:(CWCameraType)cameratype CameraOrientation:(CWCameraOrientation)orintation delegate:(id<CaptureManagerDelegate>)cameraDelegate{
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if ((![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])|| authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"请在iPhone的\"设置-隐私-相机\"选项中，允许访问您的相机。"] delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
        return nil;
    }else{
        //判断是否支持前置摄像头
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] && [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
        {
            _camraOrientaion = orintation;
            
            _delegate = cameraDelegate;
            
            currentCameraType = cameratype;
            
            if (cameratype == CameraTypeFront) {
                [self setupCaptureSessionCameraType:AVCaptureDevicePositionFront];
            }else{
                [self setupCaptureSessionCameraType:AVCaptureDevicePositionBack];
            }
            //设置显示PreViewlayer
            _Prelayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
            
            _Prelayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            
            [_Prelayer setMasksToBounds:YES];
            
            [self rotateLayer];
            
            _ispush = YES;
            
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionStoppedRunningNotification:) name:AVCaptureSessionDidStopRunningNotification object:_captureSession];
            
            if (!_captureSession.isRunning)
                [_captureSession startRunning];
            
            return _Prelayer;
        }
        else
            return nil;
    }
}

#pragma mark
#pragma mark  startRecording //开始录制视频
-(void)startRecordingSizeMode:(CWVideoSizeMode)sizeMode FrameRate:(double)frameRate andPath:(NSString *)path{
    
    //激活相机
    [self resumeCaptureSession];
    _frameRate = frameRate; //帧率
    if (sizeMode == CWVideoSizeModeSmall) {
        _width = 240;
        _height = 320;
    }
    else{
        _width = 480;
        _height = 640;
    }
    
    vedioPath = path;
    //设置movieUrl路径
    _movieURL = [NSURL fileURLWithPath:path isDirectory:YES];
    //如果文件已存在 移除
    [self removeFile:_movieURL];
    
    dispatch_async(_movieWritingQueue, ^{
        
        if (_recordingWillBeStarted || self.recording)
            return;
        _recordingWillBeStarted = YES;
        _recordingWillBeStopped = NO;
        _StopRecord = NO;
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(recordingWillStart)]){
            [self.delegate recordingWillStart];
        }
        
        NSError *error;
        _assetWriter = [[AVAssetWriter alloc] initWithURL:_movieURL fileType:AVFileTypeQuickTimeMovie error:&error];
        if (error){
            NSLog(@"error= %@",error);
        }
    });
}

#pragma mark
#pragma mark - removeFile //移除视频文件
- (void)removeFile:(NSURL *)fileURL{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = fileURL.path;
    if ([fileManager fileExistsAtPath:filePath]){
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        
        if (!success){
        }
    }
}

#pragma mark
#pragma mark - stopRecording //停止录制视频
- (void)stopRecording{
    dispatch_async(_movieWritingQueue, ^{
        
        if (_recordingWillBeStopped || !self.recording){
            return;
        }
        _StopRecord = YES;
        _recordingWillBeStopped = YES;
        //assetWriter完成写文件
        [_assetWriter finishWritingWithCompletionHandler:^()
         {
             AVAssetWriterStatus completionStatus = _assetWriter.status;
             switch (completionStatus){
                 case AVAssetWriterStatusCompleted:{
                     _readyToRecordVideo = NO;
                     _readyToRecordAudio = NO;
                     _readyToRecordMetadata = NO;
                     _assetWriter = nil;
                     _recordingWillBeStopped = NO;
                     if (self.delegate != nil && [self.delegate respondsToSelector:@selector(recordingDidStop)]) {
                         [self.delegate recordingDidStop];
                     }
                     self.recording = NO;
                     break;
                 }
                 case AVAssetWriterStatusFailed:{
                     _recordingWillBeStopped = NO;
                     self.recording = NO;
                     if (self.delegate != nil && [self.delegate respondsToSelector:@selector(recordingDidStop)]) {
                         [self.delegate recordingDidStop];
                     }
                     break;
                 }
                 default:
                     break;
             }
         }];
    });
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

/**
 *  @brief 旋转preViewLayer
 *
 */

-(void)rotateLayer{
    
    switch (_camraOrientaion) {
        case CameraOrientationPortrait:
            break;
        case CameraOrientationLeft:
            _Prelayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case CameraOrientationRight:
            _Prelayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case CameraOrientationPortraitUpsideDown:
            _Prelayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            break;
    }
}
#pragma mark
#pragma mark----------- switchCameraType  //切换前、后置摄像头
/**
 *  @brief 切换前、后置摄像头
 *
 *  @param cameratype  摄像头类型
 */
-(void)switchCameraType:(CWCameraType)cameratype{
    //与当前摄像头类型相反
    if (cameratype != currentCameraType) {
        
        currentCameraType = cameratype;
        
        [_captureSession beginConfiguration];
        
        [_captureSession removeInput:videoInPut];
        
        [_captureSession removeOutput:videoOut];
        
        [self addVideoInput:cameratype];
        
        [self addVideoOutPut:cameratype];
        
        [_captureSession commitConfiguration];
    }
}
#pragma mark
#pragma mark----------- captureOutput Delegate //获取音视频流
/**
 *  @brief 视频、音频流回调
 *
 *  @param captureOutput ...
 *  @param sampleBuffer  视频流数据
 *  @param connection    ...
 */

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    CFRetain(sampleBuffer);
    
    dispatch_sync(_movieWritingQueue, ^{
        if (connection == _videoConnection && _ispush){
            if (self.delegate && [self.delegate respondsToSelector:@selector(captureOutputSampleBuffer:bufferType:)]) {
                [self.delegate captureOutputSampleBuffer:sampleBuffer bufferType:1];
            }
        }
        if (_assetWriter){
            BOOL wasReadyToRecord = [self inputsReadyToRecord];
            if (connection == _videoConnection){
                if (!_readyToRecordVideo)
                    _readyToRecordVideo = [self setupAssetWriterVideoInput:CMSampleBufferGetFormatDescription(sampleBuffer)];
                if ([self inputsReadyToRecord] && _StopRecord == NO)
                    [self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];
            }
            else if (connection == _audioConnection){
                
                if (!_readyToRecordAudio)
                    _readyToRecordAudio = [self setupAssetWriterAudioInput:CMSampleBufferGetFormatDescription(sampleBuffer)];
                if ([self inputsReadyToRecord] && _StopRecord ==NO)
                    [self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeAudio];
            }
            BOOL isReadyToRecord = [self inputsReadyToRecord];
            if (!wasReadyToRecord && isReadyToRecord){
                _recordingWillBeStarted = NO;
                self.recording = YES;
            }
        }
        CFRelease(sampleBuffer);
    });
}

#pragma mark pauseCaptureSession //暂停录制 停止摄像头
- (void)pauseCaptureSession{
    if (_captureSession.isRunning)
        [_captureSession stopRunning];
}
#pragma mark resumeCaptureSession//激活摄像头
- (void)resumeCaptureSession{
    if (_captureSession){
        if (!_captureSession.isRunning)
            [_captureSession startRunning];
    }
}

#pragma mark
#pragma mark setupAssetWriterAudioInput //设置音频格式 帧率
- (BOOL)setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription{
    // 创建音频输出设置字典
    const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
    size_t aclSize = 0;
    const AudioChannelLayout *currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription, &aclSize);
    
    NSData *currentChannelLayoutData = nil;
    if ( currentChannelLayout && aclSize > 0 )
        currentChannelLayoutData = [NSData dataWithBytes:currentChannelLayout length:aclSize];
    else
        currentChannelLayoutData = [NSData data];
    
    //设置音频格式为aac  帧率为基本的帧率44100
    NSDictionary *audioCompressionSettings = @{AVFormatIDKey : [NSNumber numberWithInteger:kAudioFormatMPEG4AAC],AVSampleRateKey : [NSNumber numberWithFloat:currentASBD->mSampleRate],AVEncoderBitRatePerChannelKey : [NSNumber numberWithInt:44100],AVNumberOfChannelsKey : [NSNumber numberWithInteger:currentASBD->mChannelsPerFrame],AVChannelLayoutKey : currentChannelLayoutData};
    
    if ([_assetWriter canApplyOutputSettings:audioCompressionSettings forMediaType:AVMediaTypeAudio]){
        // 初始化音频输入源
        _assetWriterAudioIn = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
        
        _assetWriterAudioIn.expectsMediaDataInRealTime = YES;
        
        if ([_assetWriter canAddInput:_assetWriterAudioIn]){
            [_assetWriter addInput:_assetWriterAudioIn];
        }
        else{
            NSLog(@"Couldn't add asset writer audio input.");
            return NO;
        }
    }
    else{
        NSLog(@"Couldn't apply audio output settings.");
        return NO;
    }
    return YES;
}


#pragma mark
#pragma mark setupAssetWriterVideoInput //设置视频编码、码率、帧率
- (BOOL)setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription{
    
    CGFloat bitsPerPixel = 2.f;
    
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
    
    NSUInteger numPixels = dimensions.width * dimensions.height;
    
    NSUInteger bitsPerSecond = numPixels * bitsPerPixel;
    
    //设置视频的编码为H264 视频的宽 高 帧率 码率
    NSDictionary *videoCompressionSettings = @{AVVideoCodecKey : AVVideoCodecH264,AVVideoWidthKey : [NSNumber numberWithInteger:_width],AVVideoHeightKey : [NSNumber numberWithInteger:_height],AVVideoCompressionPropertiesKey : @{ AVVideoAverageBitRateKey : [NSNumber numberWithInteger:bitsPerSecond]}};
    
    if ([_assetWriter canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo]){
        //初始化视频输入源
        _assetWriterVideoIn = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
        _assetWriterVideoIn.expectsMediaDataInRealTime = YES;
        _assetWriterVideoIn.transform = [self transformFromCurrentVideoOrientationToOrientation:self.referenceOrientation];
        if ([_assetWriter canAddInput:_assetWriterVideoIn]){
            [_assetWriter addInput:_assetWriterVideoIn];
        }
        else{
            NSLog(@"Couldn't add asset writer video input.");
            return NO;
        }
    }
    else{
        NSLog(@"Couldn't apply video output settings.");
        return NO;
    }
    return YES;
}

#pragma mark
#pragma mark - writeSampleBuffer //把音频和视频一起写成文件
- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType{
    if ( _assetWriter.status == AVAssetWriterStatusUnknown ){
        // 如果状态为未知, 还为开始写入, 开始写入的时间为buffer的时间戳
        if ([_assetWriter startWriting])
            [_assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        else{
            NSLog(@"_assetWriter.error = %@",_assetWriter.error);
        }
    }
    if ( _assetWriter.status == AVAssetWriterStatusWriting ){
        // assert为写入状态 将相应的音视频流写入文件
        if (mediaType == AVMediaTypeVideo){
            if (_assetWriterVideoIn.readyForMoreMediaData){
                if (![_assetWriterVideoIn appendSampleBuffer:sampleBuffer]){
                    NSLog(@"_assetWriter.error = %@",_assetWriter.error);
                }
            }
        }
        else if (mediaType == AVMediaTypeAudio){
            if (_assetWriterAudioIn.readyForMoreMediaData){
                if (![_assetWriterAudioIn appendSampleBuffer:sampleBuffer]){
                    NSLog(@"_assetWriter.error = %@",_assetWriter.error);
                }
            }
        }
    }
}

- (BOOL)inputsReadyToRecord{
    return (_readyToRecordAudio && _readyToRecordVideo );
}

#pragma mark
#pragma mark captureSessionStoppedRunningNotification //停止录制

- (void)captureSessionStoppedRunningNotification:(NSNotification *)notification{
    dispatch_async(_movieWritingQueue, ^{
        if ([self isRecording]){
            [self stopRecording];
        }
    });
}

#pragma mark
#pragma mark----------- cwStopCamera //关闭摄像头

-(void)cwStopCamera{
    
    self.delegate = nil;
    
    _ispush = NO; //停止push
    
    if (self.recording) {
        [self stopRecording];
    }
    
    if (_captureSession)
        dispatch_async(dispatch_get_main_queue(), ^{
            [_captureSession stopRunning];
        });
}

- (AVCaptureSession *)session{
    return _captureSession;
}

#pragma mark
#pragma mark - //视频旋转

- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation{
    CGFloat angle = 0.0;
    switch (orientation){
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        default:
            break;
    }
    return angle;
}

- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation{
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    return transform;
}

- (void)saveVedioToAlAssetsLibrary{
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:vedioPath]
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (error) {
                                        NSLog(@"Save video fail:%@",error);
                                    } else {
                                        NSLog(@"Save video succeed.");
                                    }
                                }];
}

@end
