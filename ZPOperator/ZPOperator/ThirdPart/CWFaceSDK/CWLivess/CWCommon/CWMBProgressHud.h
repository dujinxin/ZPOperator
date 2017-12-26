//
//  CWCWMBProgressHud.h
//  CloudwalkFaceSDKDemo
//
//  Created by DengWuPing on 16/7/14.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

typedef NS_ENUM(NSInteger, CWMBProgressHudMode) {
    CWMBProgressHudModeIndeterminate,
    CWMBProgressHudModeDeterminate,
    CWMBProgressHudModeDeterminateHorizontalBar,
    CWMBProgressHudModeAnnularDeterminate,
    CWMBProgressHudModeCustomView,
    CWMBProgressHudModeText
};

typedef NS_ENUM(NSInteger, CWMBProgressHudAnimation) {
    CWMBProgressHudAnimationFade,
    CWMBProgressHudAnimationZoom,
    CWMBProgressHudAnimationZoomOut = CWMBProgressHudAnimationZoom,
    CWMBProgressHudAnimationZoomIn
};


#ifndef CWMB_INSTANCETYPE
#if __has_feature(objc_instancetype)
#define CWMB_INSTANCETYPE instancetype
#else
#define CWMB_INSTANCETYPE id
#endif
#endif

#ifndef CWMB_STRONG
#if __has_feature(objc_arc)
#define CWMB_STRONG strong
#else
#define CWMB_STRONG retain
#endif
#endif

#ifndef CWMB_WEAK
#if __has_feature(objc_arc_weak)
#define CWMB_WEAK weak
#elif __has_feature(objc_arc)
#define CWMB_WEAK unsafe_unretained
#else
#define CWMB_WEAK assign
#endif
#endif

@interface CWProgressHud : UIView

- (id __nullable)initWithWindow:(UIWindow * __nonnull)window;

- (id __nullable)initWithView:(UIView *__nonnull)view;

- (void)show:(BOOL)animated;

- (void)hide:(BOOL)animated;

- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay;

@property (assign) CWMBProgressHudMode mode;

@property (assign) CWMBProgressHudAnimation animationType;

@property (CWMB_STRONG) UIView * __nullable customView;

@property (copy) NSString * __nullable labelText;

@property (assign) float opacity;

@property (CWMB_STRONG) UIColor * __nullable color;

@property (assign) float cornerRadius;

@property (assign) BOOL taskInProgress;

@property (CWMB_STRONG) UIFont * __nullable labelFont;

@property (CWMB_STRONG) UIColor*  __nullable labelColor;

@property (atomic, assign, readonly) CGSize size;

@property (assign, getter = isSquare) BOOL square;

@end

@interface CWMBProgressHud : NSObject

{
    CWProgressHud   * hud;
}

+ (__nonnull instancetype)sharedClient;


/**
 *  @brief 显示hud
 *
 *  @param isSuccess 是否显示成功图片
 *  @param message   提示信息
 *  @param hudeMode  hud的model
 */

-(void)showHudModel:(BOOL)isSuccess message:(NSString * __nonnull)message  hudMode:(CWMBProgressHudMode)hudeMode;

-(void)hideHud;


/**
 *  @brief 显示hud
 *
 *  @param isSuccess 是否显示成功图片
 *  @param message   提示信息
 *  @param hudeMode  hud的model
 */

-(void)showHudWithView:(UIView * __nonnull)view isSuccess:(BOOL)isSuccess message:(NSString * __nonnull)message  hudMode:(CWMBProgressHudMode)hudeMode isRotate:(float)rotateDegree;


@end
