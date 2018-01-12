//
//  CWFinishedView.m
//  CloudWalkFaceForDev
//
//  Created by DengWuPing on 15/7/17.
//  Copyright (c) 2015年 dengwuping. All rights reserved.
//

#import "CWFinishedView.h"
#import "ZPOperator-Swift.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//RGB颜色
#define CW_ColorFromRGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

//屏幕宽
#define CWLIVESSSCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width
//屏幕高
#define CWLIVESSSCREEN_HEIGHT  [[UIScreen mainScreen] bounds].size.height

@implementation CWFinishedView

-(id)init{
    if (self=[super init]) {
    }
    return self;
}

//重写初始化方法
-(id)initWithFrame:(CGRect)frame WithIsSuccessed:(bool)isSuccessed{
    if (self=[super initWithFrame:frame]) {
        if (isSuccessed) {
            [self creatSucessView];
        }else{
            [self creatFailedView];
        }
        self.failedLabel.preferredMaxLayoutWidth = self.failedLabel.bounds.size.width;
    }
    return self;
}

#pragma mark
#pragma mark-----------   showAnimation //画圆
/**
 *  @brief 画圆
 *
 *  @param color 圆的颜色
 */
-(void)showAnimation:(UIColor *)color
{
    UIBezierPath *path=[UIBezierPath bezierPath];
    
    [path addArcWithCenter:CGPointMake(60,60) radius:60 startAngle:0 endAngle:2*M_PI clockwise:NO];
    
    CAShapeLayer * arcLayer=[CAShapeLayer layer];
    arcLayer.path=path.CGPath;
    arcLayer.fillColor = [UIColor clearColor].CGColor;
    arcLayer.strokeColor= color.CGColor;
    arcLayer.lineWidth=3;
    arcLayer.frame=self.frame;
    [self.errorView.layer addSublayer:arcLayer];
    [self drawLineAnimation:arcLayer];
}

#pragma mark
#pragma mark-----------   drawLineAnimation //画圆的动画
/**
 *  @brief 画圆的动画
 *
 *  @param layer 动画layer添加
 */
-(void)drawLineAnimation:(CALayer*)layer
{
    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    bas.duration=0.6;
    bas.fromValue=[NSNumber numberWithInteger:0];
    bas.toValue=[NSNumber numberWithInteger:1];
    [layer addAnimation:bas forKey:@"key"];
}

//失败页面的布局适
-(void)creatFailedView{
    
    //errorView   failedLabel   titleLabel   backButton  redoButton  suerButton
    self.failedView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CWLIVESSSCREEN_WIDTH, CWLIVESSSCREEN_HEIGHT)];
    //self.failedView.backgroundColor = [UIColor blackColor];
    self.failedView.backgroundColor = [UIColor jxffffffColor];
    [self addSubview:self.failedView];
    
    self.titleLabel=[[UILabel alloc]init];
    //self.titleLabel.text=@"验证失败";
    self.titleLabel.textAlignment=NSTextAlignmentCenter;
    self.titleLabel.font=[UIFont systemFontOfSize:20];
    self.titleLabel.textColor=[UIColor whiteColor];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints=NO;
    [self.failedView addSubview: self.titleLabel];
    
    self.errorView=[[UIView alloc]init];
    self.errorView.translatesAutoresizingMaskIntoConstraints=NO;
    [self.failedView addSubview:self.errorView];
    
    
    self.failedLabel=[[UILabel alloc]init];
    self.failedLabel.font=[UIFont systemFontOfSize:16];
    self.failedLabel.numberOfLines=0;
    self.failedLabel.textAlignment=NSTextAlignmentCenter;
    //self.failedLabel.textColor=[UIColor whiteColor];
    self.failedLabel.textColor=[UIColor jx333333Color];
    self.failedLabel.translatesAutoresizingMaskIntoConstraints=NO;
    [self.failedView addSubview:self.failedLabel];
    
    self.redoButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.redoButton setTitle:@"重新检测" forState:UIControlStateNormal];
    self.redoButton.translatesAutoresizingMaskIntoConstraints=NO;
    self.redoButton.titleLabel.textColor=[UIColor whiteColor];
    self.redoButton.titleLabel.textAlignment=NSTextAlignmentCenter;
    self.redoButton.titleLabel.font=[UIFont systemFontOfSize:20];
    [self.redoButton setBackgroundColor:[UIColor operatorOrangeColor]];
    //[self.redoButton setBackgroundColor:CW_ColorFromRGB(232,0,0)];
    self.redoButton.layer.cornerRadius=5;
    self.redoButton.layer.masksToBounds=YES;
    [self.failedView addSubview:self.redoButton];
    
    
    self.backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    //[self.backButton setTitle:@"返回" forState:UIControlStateNormal];
    self.backButton.titleLabel.textAlignment=NSTextAlignmentCenter;
    self.backButton.titleLabel.textColor=[UIColor whiteColor];
    self.backButton.titleLabel.font=[UIFont systemFontOfSize:20];
    //[self.backButton setBackgroundColor:[UIColor mainColor]];
    //[self.backButton setBackgroundColor:CW_ColorFromRGB(232,0,0)];
    self.backButton.layer.masksToBounds=YES;
    self.backButton.layer.cornerRadius=5;
    self.backButton.translatesAutoresizingMaskIntoConstraints=NO;
    [self.failedView addSubview:self.backButton];
    
    CGFloat h = 64;
    CGSize size = [UIScreen mainScreen].currentMode.size;
    if (CGSizeEqualToSize(size, CGSizeMake(1125.0, 2436.0))) {
        h = 88;
    }
    
    //titleLabel约束
    //NSLayoutConstraint*titleLabelTop=[NSLayoutConstraint constraintWithItem: self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.failedView attribute:NSLayoutAttributeTop multiplier:1 constant:CWLIVESSSCREEN_HEIGHT*0.06];
    NSLayoutConstraint*titleLabelTop=[NSLayoutConstraint constraintWithItem: self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.failedView attribute:NSLayoutAttributeTop multiplier:1 constant:h + 20];
    
    NSLayoutConstraint*titleLbelL=[NSLayoutConstraint constraintWithItem: self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.failedView attribute:NSLayoutAttributeLeft multiplier:1 constant:CWLIVESSSCREEN_WIDTH*0.16];
    
    NSLayoutConstraint*titleLabelR=[NSLayoutConstraint constraintWithItem: self.titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.failedView attribute:NSLayoutAttributeRight multiplier:1 constant:-CWLIVESSSCREEN_WIDTH*0.16];
    
    NSLayoutConstraint*titleLabelH=[NSLayoutConstraint constraintWithItem: self.titleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:CWLIVESSSCREEN_HEIGHT*0.07];
    [self.failedView addConstraints:@[titleLabelTop,titleLbelL,titleLabelR,titleLabelH]];
    
    
    //X居中
    NSLayoutConstraint*errorViewTop=[NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:40];
    
    NSLayoutConstraint*errorViewCenterX=[NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.failedView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    NSLayoutConstraint*errorViewW=[NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:120];
    
    NSLayoutConstraint*errorViewH=[NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:120];
    
    NSLayoutConstraint*errViewD=[NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.failedLabel attribute:NSLayoutAttributeTop multiplier:1 constant:-30];
    
    [self.failedView addConstraints:@[errorViewCenterX,errorViewW,errorViewH,errViewD,errorViewTop]];
    
    
    NSLayoutConstraint*failedLabelL=[NSLayoutConstraint constraintWithItem:self.failedLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.failedView attribute:NSLayoutAttributeLeft multiplier:1 constant:CWLIVESSSCREEN_WIDTH*0.08];
    
    NSLayoutConstraint*failedLbelR=[NSLayoutConstraint constraintWithItem:self.failedLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.failedView attribute:NSLayoutAttributeRight multiplier:1 constant:-CWLIVESSSCREEN_WIDTH*0.08];
    
    NSLayoutConstraint*failedLbelH=[NSLayoutConstraint constraintWithItem:self.failedLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:CWLIVESSSCREEN_HEIGHT*0.18];
    
    [self.failedView addConstraints:@[failedLabelL,failedLbelR,failedLbelH]];
    
    NSLayoutConstraint*refoButtonL=[NSLayoutConstraint constraintWithItem:self.redoButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.failedView attribute:NSLayoutAttributeLeft multiplier:1 constant:CWLIVESSSCREEN_WIDTH*0.11];
    
    NSLayoutConstraint*refoButtonR=[NSLayoutConstraint constraintWithItem:self.redoButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.failedView attribute:NSLayoutAttributeRight multiplier:1 constant:-CWLIVESSSCREEN_WIDTH*0.11];
    
    NSLayoutConstraint*redoButtonH=[NSLayoutConstraint constraintWithItem:self.redoButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44];
    
    NSLayoutConstraint*redoButtonD=[NSLayoutConstraint constraintWithItem:self.redoButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backButton attribute:NSLayoutAttributeTop multiplier:1 constant:-CWLIVESSSCREEN_HEIGHT*0.045];
    
    [self.failedView addConstraints:@[refoButtonL,refoButtonR,redoButtonH,redoButtonD]];
    
    NSLayoutConstraint*BackButtonTop=[NSLayoutConstraint constraintWithItem:self.backButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.redoButton attribute:NSLayoutAttributeBottom multiplier:1 constant:CWLIVESSSCREEN_HEIGHT*0.045];
    NSLayoutConstraint*backButtonL=[NSLayoutConstraint constraintWithItem:self.backButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.failedView attribute:NSLayoutAttributeLeft multiplier:1 constant:CWLIVESSSCREEN_WIDTH*0.11];
    NSLayoutConstraint*backButtonR=[NSLayoutConstraint constraintWithItem:self.backButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.failedView attribute:NSLayoutAttributeRight multiplier:1 constant:-CWLIVESSSCREEN_WIDTH*0.11];
    NSLayoutConstraint*backButtonH=[NSLayoutConstraint constraintWithItem:self.backButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44];
    NSLayoutConstraint*backBtnD=[NSLayoutConstraint constraintWithItem:self.backButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.failedView attribute:NSLayoutAttributeBottom multiplier:1 constant:-CWLIVESSSCREEN_HEIGHT*0.08];
    [self.failedView addConstraints:@[BackButtonTop,backButtonL,backButtonR,backBtnD,backButtonH]];
    //失败图片
    UIImageView*faieldImg=[[UIImageView alloc]init];
    faieldImg.image=[UIImage imageNamed:@"CWResource.bundle/failed@2x.png"];
    faieldImg.translatesAutoresizingMaskIntoConstraints=NO;
    [self.errorView addSubview:faieldImg];
    //Y 左10 有10  宽高100
    
    NSLayoutConstraint*failImgCenterX=[NSLayoutConstraint constraintWithItem:faieldImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.errorView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    NSLayoutConstraint*failImgCenterY=[NSLayoutConstraint constraintWithItem:faieldImg attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.errorView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint*failImgW=[NSLayoutConstraint constraintWithItem:faieldImg attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
    NSLayoutConstraint*failImgH=[NSLayoutConstraint constraintWithItem:faieldImg attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
    [self.failedView addConstraints:@[failImgCenterY,failImgCenterX,failImgW,failImgH]];
    
}

//成功页面的布局
-(void)creatSucessView{
    
    self.SucessView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CWLIVESSSCREEN_WIDTH, CWLIVESSSCREEN_HEIGHT)];
    //self.SucessView.backgroundColor=[UIColor blackColor];
    self.SucessView.backgroundColor=[UIColor jxffffffColor];
    [self addSubview:self.SucessView];
    
    UILabel*titleLabel=[[UILabel alloc]init];
    //titleLabel.text=@"验证成功";
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.font=[UIFont systemFontOfSize:20];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints=NO;
    [self.SucessView addSubview:titleLabel];
    
    self.errorView=[[UIView alloc]init];
    self.errorView.translatesAutoresizingMaskIntoConstraints=NO;
    [self.SucessView addSubview:self.errorView];
    
    
    self.failedLabel=[[UILabel alloc]init];
    self.failedLabel.font=[UIFont systemFontOfSize:17];
    //self.failedLabel.textColor=[UIColor whiteColor];
    self.failedLabel.textColor=[UIColor jx333333Color];
    self.failedLabel.textAlignment=NSTextAlignmentCenter;
    self.failedLabel.translatesAutoresizingMaskIntoConstraints=NO;
    [self.SucessView addSubview: self.failedLabel];
    
    
    self.suerButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.suerButton.translatesAutoresizingMaskIntoConstraints=NO;
    [self.suerButton setTitle:@"下一步" forState:UIControlStateNormal];
    self.suerButton.titleLabel.textColor=[UIColor whiteColor];
    self.suerButton.titleLabel.font=[UIFont systemFontOfSize:20];
    [self.suerButton setBackgroundColor:[UIColor operatorOrangeColor]];
    //[self.suerButton setBackgroundColor:CW_ColorFromRGB(232,0,0)];
    self.suerButton.titleLabel.textAlignment=NSTextAlignmentCenter;
    self.suerButton.layer.cornerRadius=5;
    self.suerButton.layer.masksToBounds=YES;
    [self.SucessView addSubview:self.suerButton];
    
    CGFloat h = 64;
    CGSize size = [UIScreen mainScreen].currentMode.size;
    if (CGSizeEqualToSize(size, CGSizeMake(1125.0, 2436.0))) {
        h = 88;
    }
    
    //titleLabel约束
    //NSLayoutConstraint*titleLabelTop=[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.SucessView attribute:NSLayoutAttributeTop multiplier:1 constant:CWLIVESSSCREEN_HEIGHT*0.06];
    NSLayoutConstraint*titleLabelTop=[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.SucessView attribute:NSLayoutAttributeTop multiplier:1 constant:h + 20];
    
    NSLayoutConstraint*titleLbelL=[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.SucessView attribute:NSLayoutAttributeLeft multiplier:1 constant:CWLIVESSSCREEN_WIDTH*0.16];
    
    NSLayoutConstraint*titleLabelR=[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.SucessView attribute:NSLayoutAttributeRight multiplier:1 constant:-CWLIVESSSCREEN_WIDTH*0.16];
    
    NSLayoutConstraint*titleLabelH=[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44];
    
    [self.SucessView addConstraints:@[titleLabelTop,titleLbelL,titleLabelR,titleLabelH]];
    
    
    //X居中
    NSLayoutConstraint*errorViewCenterX=[NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.SucessView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint*errorViewW=[NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:120];
    NSLayoutConstraint*errorViewH=[NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:120];
    NSLayoutConstraint*errViewD=[NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem: self.failedLabel attribute:NSLayoutAttributeTop multiplier:1 constant:-30];
    [self.SucessView addConstraints:@[errorViewW,errorViewH,errViewD,errorViewCenterX]];
    
    
    NSLayoutConstraint*failedLabelCenterY=[NSLayoutConstraint constraintWithItem: self.failedLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.SucessView attribute:NSLayoutAttributeCenterY multiplier:1 constant:CWLIVESSSCREEN_HEIGHT*0.075];
    
    NSLayoutConstraint*failedLabelL=[NSLayoutConstraint constraintWithItem: self.failedLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.SucessView attribute:NSLayoutAttributeLeft multiplier:1 constant:CWLIVESSSCREEN_WIDTH*0.05];
    
    NSLayoutConstraint*failedLbelR=[NSLayoutConstraint constraintWithItem: self.failedLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.SucessView attribute:NSLayoutAttributeRight multiplier:1 constant:-CWLIVESSSCREEN_WIDTH*0.05];
    
    NSLayoutConstraint*failedLbelH=[NSLayoutConstraint constraintWithItem: self.failedLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:CWLIVESSSCREEN_HEIGHT*0.18];
    [self.SucessView addConstraints:@[failedLabelL,failedLbelR,failedLabelCenterY,failedLbelH]];
    
    
    NSLayoutConstraint*suerButtonL=[NSLayoutConstraint constraintWithItem:self.suerButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.SucessView attribute:NSLayoutAttributeLeft multiplier:1 constant:CWLIVESSSCREEN_WIDTH*0.11];
    
    NSLayoutConstraint*suerButtonR=[NSLayoutConstraint constraintWithItem:self.suerButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.SucessView attribute:NSLayoutAttributeRight multiplier:1 constant:-CWLIVESSSCREEN_WIDTH*0.11];
    
    NSLayoutConstraint*suerButtonH=[NSLayoutConstraint constraintWithItem:self.suerButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44];
    
    NSLayoutConstraint * sureButtonTop=[NSLayoutConstraint constraintWithItem:self.suerButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem: self.failedLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:CWLIVESSSCREEN_HEIGHT*0.12];
    
    [self.SucessView addConstraints:@[suerButtonL,suerButtonR,suerButtonH,sureButtonTop]];
    
    //失败图片
    UIImageView*faieldImg=[[UIImageView alloc]init];
    faieldImg.image=[UIImage imageNamed:@"CWResource.bundle/success@2x.png"];
    faieldImg.translatesAutoresizingMaskIntoConstraints=NO;
    [self.errorView addSubview:faieldImg];
    //Y 左10 有10  宽高100
    NSLayoutConstraint*failImgTop=[NSLayoutConstraint constraintWithItem:faieldImg attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.errorView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    NSLayoutConstraint*failImgCenterX=[NSLayoutConstraint constraintWithItem:faieldImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.errorView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    NSLayoutConstraint*failImgCenterY=[NSLayoutConstraint constraintWithItem:faieldImg attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.errorView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    NSLayoutConstraint*failImgW=[NSLayoutConstraint constraintWithItem:faieldImg attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
    
    NSLayoutConstraint*failImgH=[NSLayoutConstraint constraintWithItem:faieldImg attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
    
    [self.SucessView addConstraints:@[failImgTop,failImgCenterX,failImgCenterY,failImgW,failImgH]];
}


@end
