//
//  CWCaptureManager.h
//  CWCaptureManager
//
//  Created by DengWuPing on 16/11/7.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//


#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

#define MAX_PINCH_SCALE_NUM   3.f

#define MIN_PINCH_SCALE_NUM   1.f

//视频帧回调代理
@protocol CWCaptureManagerDelegate <NSObject>


/**
 视频流回调代理方法
 
 @param sampleBuffer 视频帧buffer
 */
-(void)captureSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@optional

//对焦完成代理方法
-(void)captureFoucsFinished;

@end

@interface CWCaptureManager : NSObject
/**
 视频流采集线程
 */
@property (nonatomic) dispatch_queue_t sessionQueue;
/**
 主设备session
 */
@property (nonatomic, strong) AVCaptureSession *session;
/**
 视频预览Layer
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
/**
 视频输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput *inputDevice;
/**
 视频输出设备
 */
@property (nonatomic, strong) AVCaptureVideoDataOutput *output;

/**
 视频帧回调代理
 */
@property(nonatomic,assign)id<CWCaptureManagerDelegate>delegate;


/**
 是否显示对焦图片
 */
@property(nonatomic,assign)BOOL  isShowFoucsView;
/**
 打开摄像机
 @param parent      加载preLayer的父View
 @param preivewRect prelayer的大小
 */
- (void)cwConfigureWithParentLayer:(UIView*)parent previewRect:(CGRect)preivewRect;

/**
 点击屏幕进行对焦
 
 @param devicePoint 屏幕中的点
 */
- (void)cwFocusInPoint:(CGPoint)devicePoint;

/**
 暂停摄像头
 */
-(void)cwPauseCamera;

/**
 重启摄像头
 */
-(void)cwResumCamera;
/**
 关闭摄像头
 */
-(void)cwStopCamera;

@end

