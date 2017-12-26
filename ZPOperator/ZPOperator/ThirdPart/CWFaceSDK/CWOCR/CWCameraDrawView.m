//
//  CameraDrawView.m
//
//
//  Created by DengWuPing on 16/11/7.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import "CWCameraDrawView.h"

#define ScanValue 7

#define kLength 40

#define kVerticalMargin  ((preSize.height / ScanValue))

#define KHeight ((preSize.height - kVerticalMargin*2.0))

#define kHorizontalMargin (preSize.width-KHeight/1.58)*0.5

#define bottomContainerView_DOWN_COLOR   [UIColor colorWithRed:68/255.0f green:68/255.0f blue:68/255.0f alpha:1.f]

#define CWMERAVIEW_DEVICE_SIZE      [[UIScreen mainScreen] bounds].size

#define kClearRectSizeHeight ((CWMERAVIEW_DEVICE_SIZE.width - 2*kHorizontalMargin)/1.58)


@interface CWCameraDrawView(){
    
    UIImageView  *   imageView;
    
    UIView       *   menuView;
    
    CALayer      *   lineLayer;
    
    UILabel      *   landScapLabel;
    
    UIImageView   *  landScanLineImageView;
    
}

@property(nonatomic,assign) BOOL showUp;

@property(nonatomic,assign) BOOL showRight;

@property(nonatomic,assign) BOOL showBottom;

@property(nonatomic,assign) BOOL showLeft;

@end

@implementation CWCameraDrawView

- (id)initWithFrame:(CGRect)frame{
    
    if ((self = [super initWithFrame:frame])) {
        
        // Initialization code
        [self addCameraMenuView];
        boundColor = [UIColor greenColor];
        CGRect rect = CGRectMake(-6, 273, CWMERAVIEW_DEVICE_SIZE.width, 21);
        _lable = [[UILabel alloc] initWithFrame:rect];
        _lable.textColor = [UIColor whiteColor];
        _lable.font = [UIFont boldSystemFontOfSize:16];
        _lable.backgroundColor = [UIColor clearColor];
        _lable.transform=CGAffineTransformMakeRotation(M_PI/2);
        _lable.textAlignment = NSTextAlignmentCenter;
        _lable.adjustsFontSizeToFitWidth = YES;
        _lable.center = CGPointMake(20,CWMERAVIEW_DEVICE_SIZE.height/2);
        
        UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        //适配ipad
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            if (statusBarOrientation == UIInterfaceOrientationPortrait) {
                _lable.center = CGPointMake(CWMERAVIEW_DEVICE_SIZE.width * 0.12, CWMERAVIEW_DEVICE_SIZE.height/2);
            }else{
                _lable.center = CGPointMake(CWMERAVIEW_DEVICE_SIZE.width * 0.12, CWMERAVIEW_DEVICE_SIZE.width/2);
            }
        }else{
            //竖屏时提示label位置
            if (statusBarOrientation == UIInterfaceOrientationPortrait) {
                _lable.center = CGPointMake(20,CWMERAVIEW_DEVICE_SIZE.height/2);
            }else{
                _lable.center = CGPointMake(20,CWMERAVIEW_DEVICE_SIZE.width/2);
            }
        }
        [self addSubview:_lable];
        
        landScapLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 280, CWMERAVIEW_DEVICE_SIZE.width, 30)];
        
        if (CWMERAVIEW_DEVICE_SIZE.width == 320) {
            landScapLabel.frame = CGRectMake(140, 240, CWMERAVIEW_DEVICE_SIZE.width, 30);
        }
        
        landScapLabel.textColor = [UIColor whiteColor];
        landScapLabel.font = [UIFont boldSystemFontOfSize:16];
        landScapLabel.backgroundColor = [UIColor clearColor];
        landScapLabel.textAlignment = NSTextAlignmentCenter;
        landScapLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:landScapLabel];
        landScapLabel.transform=CGAffineTransformMakeRotation(M_PI/2);
        
        
        landScanLineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(kHorizontalMargin, (CWMERAVIEW_DEVICE_SIZE.height - kClearRectSizeHeight)/2, CWMERAVIEW_DEVICE_SIZE.width - kHorizontalMargin *2, 3)];
        
        landScanLineImageView.image = [UIImage imageNamed:@"CWResource.bundle/scanLine.png"];
        landScanLineImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:landScanLineImageView];
        landScanLineImageView.hidden = YES;
    }
    return self;
}

- (void)addScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect {
    
    CGContextSetRGBFillColor(ctx, 40 / 255.0,40 / 255.0,40 / 255.0,0.5);
    CGContextFillRect(ctx, rect);   //draw the transparent layer
}
#pragma mark
#pragma mark -----------  addCenterClearRect -------------- //添加中间透明矩形框
//添加中间透明矩形框
- (void)addCenterClearRect :(CGContextRef)ctx rect:(CGRect)rect {
    
    CGContextClearRect(ctx, rect);  //clear the center rect  of the layer
}

//drawRect 画四个角和四条边
- (void)drawRect:(CGRect)rect {
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    CGFloat viewWidth = preSize.width;
    
    CGFloat viewHeight = preSize.height;
    
    float  topMargin = viewHeight  * 0.04;
    
    //中间清空的矩形框
    CGRect clearDrawRect = CGRectMake(_beginPoint.y,_beginPoint.x,_endPoint.y-_beginPoint.y, _endPoint.x- _beginPoint.x);
    
    if (imageView != nil) {
        imageView.frame = clearDrawRect;
    }
    
    menuView.frame = CGRectMake(0,(viewHeight - viewHeight * 0.1),viewWidth, viewHeight * 0.1);
    
    _closeButton.frame = CGRectMake(20, (menuView.frame.size.height-30)/2, 30, 30);
    
    lineLayer.frame = CGRectMake(_beginPoint.y + _closeButton.frame.size.width +10, 0,1, viewHeight - _endPoint.y-20);
    
    CGSize screenSize =[UIScreen mainScreen].bounds.size;
    
    CGRect screenDrawRect =CGRectMake(0, 0, screenSize.width,screenSize.height);
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    [self addScreenFillRect:currentContext rect:screenDrawRect];
    
    [self addCenterClearRect:currentContext rect:clearDrawRect];
    
    CGFloat lineWidth  = 3;
    
    CGContextSetStrokeColorWithColor(currentContext, [boundColor CGColor]);
    
    CGContextSetStrokeColorWithColor(currentContext, [[UIColor greenColor] CGColor]);
    CGContextSetLineWidth(currentContext, lineWidth);
    
    CGPoint newPoints1[] = {
        CGPointMake(_beginPoint.y, _beginPoint.x+kLength),
        CGPointMake(_beginPoint.y, _beginPoint.x),
        CGPointMake(_beginPoint.y+kLength, _beginPoint.x)
    };
    CGContextAddLines(currentContext, newPoints1, 3);
    CGContextStrokePath(currentContext);
    
    CGPoint newPoints2[] = {
        CGPointMake(_endPoint.y, _beginPoint.x+kLength),
        CGPointMake(_endPoint.y, _beginPoint.x),
        CGPointMake(_endPoint.y-kLength, _beginPoint.x)
    };
    CGContextAddLines(currentContext, newPoints2, 3);
    CGContextStrokePath(currentContext);
    
    CGPoint newPoints3[] = {
        CGPointMake(_beginPoint.y, _endPoint.x-kLength),
        CGPointMake(_beginPoint.y, _endPoint.x),
        CGPointMake(_beginPoint.y+kLength, _endPoint.x)
    };
    CGContextAddLines(currentContext, newPoints3, 3);
    CGContextStrokePath(currentContext);
    
    CGPoint newPoints4[] = {
        CGPointMake(_endPoint.y-kLength, _endPoint.x),
        CGPointMake(_endPoint.y, _endPoint.x),
        CGPointMake(_endPoint.y, _endPoint.x-kLength)
    };
    CGContextAddLines(currentContext, newPoints4, 3);
    CGContextStrokePath(currentContext);
    
    //    if (self.cardType == 2) {
    //画四条边
    //上边
    if (self.showUp) {
        CGPoint lineUpPoints[] = {
            CGPointMake(kHorizontalMargin+kLength, kVerticalMargin - topMargin),
            CGPointMake(viewWidth-kHorizontalMargin , kVerticalMargin - topMargin),
        };
        CGContextAddLines(currentContext, lineUpPoints, 2);
        CGContextStrokePath(currentContext);
    }
    
    //    //右边
    if (self.showRight) {
        CGPoint lineRightPoints[] = {
            CGPointMake(viewWidth-kHorizontalMargin, kVerticalMargin+kLength - topMargin),
            CGPointMake(viewWidth-kHorizontalMargin, viewHeight-kVerticalMargin-kLength),
        };
        CGContextAddLines(currentContext, lineRightPoints, 2);
        CGContextStrokePath(currentContext);
    }
    //下边
    if (self.showBottom) {
        CGPoint lineBottomPoints[] = {
            CGPointMake(kHorizontalMargin + kLength, viewHeight-kVerticalMargin - topMargin),
            CGPointMake(viewWidth-kHorizontalMargin-kLength, viewHeight-kVerticalMargin - topMargin),
        };
        CGContextAddLines(currentContext, lineBottomPoints, 2);
        CGContextStrokePath(currentContext);
    }
    
    //    //左边
    if (self.showLeft) {
        CGPoint lineLeftPoints[] = {
            CGPointMake(kHorizontalMargin, kVerticalMargin+kLength - topMargin),
            CGPointMake(kHorizontalMargin, viewHeight-kVerticalMargin-kLength),
        };
        CGContextAddLines(currentContext, lineLeftPoints, 2);
        CGContextStrokePath(currentContext);
    }
    //    }
}

#pragma mark
#pragma mark -----------  showLineUP -------------- //设置显示对齐的边
//设置显示对齐的边
-(void)showLineUP:(BOOL)up right:(BOOL)right bottom:(BOOL)bottom left:(BOOL)left{
    self.showUp = up;
    self.showRight = right;
    self.showBottom = bottom;
    self.showLeft = left;
    [self setNeedsDisplay];
}

#pragma mark
#pragma mark -----------  addCameraMenuView -------------- //添加底部关闭按钮View
- (void)addCameraMenuView {
    //拍照按钮
    menuView = [[UIView alloc] init];
    
    menuView.backgroundColor = (bottomContainerView_DOWN_COLOR );
    [self addSubview:menuView];
    
    _closeButton =[ UIButton buttonWithType:UIButtonTypeCustom];
    
    [_closeButton setImage:[UIImage imageNamed:@"CWResource.bundle/close_cha@2x.png"] forState:UIControlStateNormal];
    
    [menuView addSubview:_closeButton];
    
    [self drawALineAndColor:[UIColor colorWithRed:102/255.f green:102/255.f blue:102/255.f alpha:1.f] inLayer:menuView.layer];
}

#pragma mark
#pragma mark -----------  drawALineAndColor -------------- //画一条线
//画一条线
-(void)drawALineAndColor:(UIColor*)color inLayer:(CALayer*)parentLayer {
    lineLayer = [CALayer layer];
    lineLayer.backgroundColor = color.CGColor;
    [parentLayer addSublayer:lineLayer];
}

-(CGPoint)getBeginPoint{
    return _beginPoint;
}

-(CGPoint)getEndPoint{
    return _endPoint;
}

#pragma mark
#pragma mark -----------  setCardType -------------- //设置扫描类型

-(void)setCardType:(NSInteger)cardType{
    
    if (cardType ==0 || cardType ==1) {
        imageView = [[UIImageView alloc]init];
        [self addSubview:imageView];
        _lable.text = @"请横握手机,将身份证与扫描框边缘对齐";
    }else{
        _lable.text = @"请横握手机,将银行卡与扫描框边缘对齐";
        landScapLabel.text = @"横版银行卡识别";
    }
    _cardType = cardType;
}

#pragma mark
#pragma mark -----------  SetPreSize  -------------- //设置预览大小 默认全屏

-(void)SetPreSize:(CGSize)size
{
    preSize = size;
    
    [self setBeginPointAndEndPoint];
    
    [self addCameraMenuView];
    
    landScanLineImageView.frame = CGRectMake(kVerticalMargin + kHorizontalMargin,_endPoint.y - _beginPoint.y, _endPoint.y + _beginPoint.x, 3);
    
    landScanLineImageView.transform =CGAffineTransformMakeRotation(M_PI/2);
}

#pragma mark
#pragma mark -----------  setBeginPointAndEndPoint  -------------- //设置起始点
-(void)setBeginPointAndEndPoint{
    
    CGFloat viewWidth = preSize.width;
    
    CGFloat viewHeight = preSize.height;
    
    float  topMargin = viewHeight  * 0.04;
    
    _beginPoint = CGPointMake(kVerticalMargin - topMargin, kHorizontalMargin);
    
    _endPoint = CGPointMake(viewHeight-kVerticalMargin - topMargin, viewWidth - kHorizontalMargin);
}



-(void)setLandScapeView{
    
    _lable.hidden  =NO;
    
    landScapLabel.hidden = NO;
    
    [self showLandScapeAnimation];
    
}

-(void)showAnimation{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self setLandScapeView];
        
    });
}

#pragma mark
#pragma mark -----------  showLandScapeAnimation  -------------- //显示横屏扫描动画
-(void)showLandScapeAnimation{
    
    CABasicAnimation *animation = [self moveYTime:2 fromY:[NSNumber numberWithFloat:0] toY:[NSNumber numberWithFloat:-(CWMERAVIEW_DEVICE_SIZE.width- kVerticalMargin)] rep:OPEN_MAX animationx:YES];
    
    [landScanLineImageView.layer addAnimation:animation forKey:@"landScapeLineAnimation"];
    
    landScanLineImageView.hidden = NO;
    
}

#pragma mark
#pragma mark -----------  moveYTime  -------------- //添加动画
-(CABasicAnimation *)moveYTime:(float)time fromY:(NSNumber *)fromY toY:(NSNumber *)toY rep:(int)rep animationx:(BOOL)isAnimationX
{
    CABasicAnimation *animationMove;
    if (isAnimationX) {
        animationMove= [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    }else{
        animationMove= [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    }
    [animationMove setFromValue:fromY];
    [animationMove setToValue:toY];
    animationMove.duration = time;
    animationMove.repeatCount  = rep;
    animationMove.fillMode = kCAFillModeForwards;
    animationMove.removedOnCompletion = NO;
    animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animationMove;
}


#pragma mark
#pragma mark -----------  removeAnimation  -------------- //移除动画
/**
 *  @aremoveAnimation
 *
 *  去除扫码动画
 */

- (void)removeAnimation:(UIView *)view animationName:(NSString * )animationName{
    
    @try {
        [view.layer removeAnimationForKey:animationName];
        
    } @catch (NSException *exception) {
        
    } @finally {
        view.hidden = YES;
    }
}

#pragma mark
#pragma mark -----------  stopAnimation  -------------- // 停止动画
/**
 *  @stopAnimation
 *
 *  停止动画
 */

-(void)stopAnimation{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self removeAnimation:landScanLineImageView animationName:@"landScapeLineAnimation"];
    });
}


@end
