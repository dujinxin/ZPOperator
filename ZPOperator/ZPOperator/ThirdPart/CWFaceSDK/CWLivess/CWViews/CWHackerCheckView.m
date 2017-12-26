//
//  CWHackerCheckView.m
//  CloudwalkFaceSDKDemo
//
//  Created by DengWuPing on 16/12/9.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import "CWHackerCheckView.h"
#import "ZPOperator-Swift.h"

//屏幕宽
#define CWHACKER_SCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width
//屏幕高
#define  CWHACKER_SCREEN_HEIGHT  [[UIScreen mainScreen] bounds].size.height

@implementation CWHackerCheckView


/**
 初始化方法
 
 @param frame frame
 @return 返回 CWHackerCheckView实例
 */
-(id)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        self.backgroundColor =  CWHacker_ColorFromRGB(30,40,63);
        [self creatView];
    }
    return self;
}

#pragma mark
#pragma mark--------------- creatSureButton 创建确定按钮

-(UIButton *)creatSureButton{
    //确定按钮
    UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints=NO;
    button.enabled = YES;
    [button setTitle:@"确定" forState:UIControlStateNormal];
    button.titleLabel.textColor=[UIColor whiteColor];
    button.titleLabel.font=[UIFont systemFontOfSize:20];
    //[button setBackgroundColor:CWHacker_ColorFromRGB(232,0,0)];
    [button setBackgroundColor:[UIColor mainColor]];
    button.titleLabel.textAlignment=NSTextAlignmentCenter;
    button.layer.cornerRadius=5;
    button.layer.masksToBounds=YES;
    [self addSubview:button];
    
    NSLayoutConstraint * suerButtonL=[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:CWHACKER_SCREEN_WIDTH * 0.1];
    
    NSLayoutConstraint * suerButtonR=[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:-CWHACKER_SCREEN_WIDTH * 0.1];
    
    NSLayoutConstraint * suerButtonH=[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44];
    
    NSLayoutConstraint * sureButtonBottom=[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-CWHACKER_SCREEN_HEIGHT*0.08];
    
    [self addConstraints:@[suerButtonL,suerButtonR,suerButtonH,sureButtonBottom]];
    
    return button;
}

#pragma mark
#pragma mark--------------- creatView 创建View 页面布局

-(void)creatView{
    
    //确定按钮
    _suerButton = [self creatSureButton];
    
    //上面显示前端检测和后端防hack攻击的superView
    UIView   *  clearView = [[UIView alloc]init];
    clearView.backgroundColor = [UIColor clearColor];
    clearView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:clearView];
    
    NSLayoutConstraint * clearViewL=[NSLayoutConstraint constraintWithItem:clearView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:CWHACKER_SCREEN_WIDTH * 0.1];
    
    NSLayoutConstraint * clearViewR=[NSLayoutConstraint constraintWithItem:clearView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:-CWHACKER_SCREEN_WIDTH * 0.1];
    
    NSLayoutConstraint * clearViewTop=[NSLayoutConstraint constraintWithItem:clearView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSLayoutConstraint * clearViewBottom=[NSLayoutConstraint constraintWithItem:clearView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.suerButton attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    [self addConstraints:@[clearViewL,clearViewR,clearViewTop,clearViewBottom]];
    
    //顶部显示前端检测成功的VIew
    UIView   *  topView = [[UIView alloc]init];
    topView.backgroundColor = CWHacker_ColorFromRGB(10, 15, 28);
    topView.translatesAutoresizingMaskIntoConstraints = NO;
    [clearView addSubview:topView];
    
    float multiplier = 0.36f;
    
    float  topConstant  = (self.frame.size.height - 44 - CWHACKER_SCREEN_WIDTH * 0.1) * 0.09;

    if (CWHACKER_SCREEN_HEIGHT < 568) {
        multiplier = 0.38f;
        topConstant  = (self.frame.size.height - 44 - CWHACKER_SCREEN_WIDTH * 0.1) * 0.07;
    }else if(CWHACKER_SCREEN_HEIGHT == 568){
        multiplier = 0.38f;
        topConstant  = (self.frame.size.height - 44 - CWHACKER_SCREEN_WIDTH * 0.1) * 0.07;
    }
    
    NSLayoutConstraint * topViewL=[NSLayoutConstraint constraintWithItem:topView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:clearView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    
    NSLayoutConstraint * topViewR=[NSLayoutConstraint constraintWithItem:topView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:clearView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    
    NSLayoutConstraint * topViewHeight=[NSLayoutConstraint constraintWithItem:topView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:clearView attribute:NSLayoutAttributeHeight multiplier:multiplier constant:0];
    
     NSLayoutConstraint * topViewTop=[NSLayoutConstraint constraintWithItem:topView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:clearView attribute:NSLayoutAttributeTop multiplier:1 constant:topConstant];
    
    [clearView addConstraints:@[topViewL,topViewR,topViewHeight,topViewTop]];
    
    //前端检测灰色线
    UIView   * topLineView = [self creatLineView:topView];
    
    //前端检测是否成功的提示lable
    _topLabel = [self createTipsLabel:topView relatedView:topLineView title:@"前端活体检测成功"];
    
    //前端检测是否成功的ImageVIew
    _topImageView = [self creatImageVIew:topView relatedView:topLineView imageName:@"CWResource.bundle/ico_tick@2x.png"];
   
    //后端防hack攻击的superView
    UIView   * bottomView = [[UIView alloc]init];
    bottomView.backgroundColor = CWHacker_ColorFromRGB(10, 15, 28);
    bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    [clearView addSubview:bottomView];
    
    NSLayoutConstraint * bottomViewL=[NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:clearView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    
    NSLayoutConstraint * bottomViewR=[NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:clearView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    
    NSLayoutConstraint * bottomViewHeight=[NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:topView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    NSLayoutConstraint * bottomViewTop=[NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topView attribute:NSLayoutAttributeBottom multiplier:1 constant:topConstant];
    
    [clearView addConstraints:@[bottomViewL,bottomViewR,bottomViewHeight,bottomViewTop]];
    
    
    UIView  * bottompLineView = [self creatLineView:bottomView];
    
    //底部显示后端防hack攻击是否成功的提示label
    _bottomLabel = [self createTipsLabel:bottomView relatedView:bottompLineView title:@"后端防hack攻击成功"];

    //底部显示后端防hack攻击成功或失败的ImageView
    _bottomImageView = [self creatImageVIew:bottomView relatedView:bottompLineView imageName:@"CWResource.bundle/ico_tick@2x.png"];
}

#pragma mark
#pragma mark------------ creatImageVIew 创建imageView

/**
 创建成功、失败的imageView

 @param superView 装载imageView的父View
 @param relatedView 与之相关约束View
 @param imageName 图片名称
 @return UIImageView
 */
-(UIImageView *)creatImageVIew:(UIView *)superView relatedView:(UIView *)relatedView imageName:(NSString *)imageName{

    UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [superView  addSubview:imageView];
    
    NSLayoutConstraint * bottomImageViewCenterX=[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    NSLayoutConstraint *bottomImageViewTop=[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1 constant:10];
    
    NSLayoutConstraint * bottomImageViewBottom =[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:relatedView attribute:NSLayoutAttributeTop multiplier:1 constant:-10];
    
    [superView addConstraints:@[bottomImageViewCenterX,bottomImageViewTop,bottomImageViewBottom]];
    
    return imageView;
}


#pragma mark
#pragma mark--------------- creatLineView   画灰色的线
/**
 画灰色的线

 @param superView 装载灰色线的fuView
 @return 返回灰色线View
 */
-(UIView *)creatLineView:(UIView *)superView {
    
    //灰色线
    UIView   * lineView = [[UIView alloc]init];
    lineView.backgroundColor = CWHacker_ColorFromRGB(19, 28, 49);
    lineView.translatesAutoresizingMaskIntoConstraints = NO;
    [superView addSubview:lineView];
    
    NSLayoutConstraint * bottompLineViewL=[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    
    NSLayoutConstraint * bottompLineViewR=[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    
    NSLayoutConstraint * bottompLineViewHeight=[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:1];
    
    NSLayoutConstraint * bottompLineViewTop=[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:-41];
    
    [superView addConstraints:@[bottompLineViewL,bottompLineViewR,bottompLineViewHeight,bottompLineViewTop]];
    
    return lineView;
}

#pragma mark
#pragma mark--------------- createTipsLabel  创建提示语Label

/**
 创建提示语label

 @param superView 装载label的fuview
 @param relatedView 与之有关约束View
 @param title text
 @return labe
 */
-(UILabel *)createTipsLabel:(UIView *)superView  relatedView:(UIView *)relatedView title:(NSString *)title{
    
    UILabel * label = [[UILabel alloc]init];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = CWHacker_ColorFromRGB(42, 166, 84);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:16.f];
    label.adjustsFontSizeToFitWidth = YES;
    label.translatesAutoresizingMaskIntoConstraints =NO;
    label.text = title;
    label.numberOfLines = 0;

    [superView addSubview:label];
    
    NSLayoutConstraint * labelLeading=[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    
    NSLayoutConstraint * lLabelTrailling=[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    
    NSLayoutConstraint * labelTop=[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:relatedView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    NSLayoutConstraint * labelBottom=[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    [superView addConstraints:@[labelLeading,lLabelTrailling,labelTop,labelBottom]];
    
    return label;
}

#pragma mark
#pragma mark--------------- cwSetFrontDetectFailed  设置检测成功、失败的图和提示语
/**
 设置检测成功、失败的图和提示语
 
 @param isDetectFaild 前端检测是否成功
 @param isHackerFailed 后端防hack攻击是否成功
 */
-(void)cwSetFrontDetectFailed:(BOOL)isDetectFaild  hackerDetect:(BOOL)isHackerFailed{
    
    if (isDetectFaild) {
        _topImageView.image = [UIImage imageNamed:@"CWResource.bundle/ico_error@2x.png"];
        _topLabel.text = @"前端活体检测失败!";
        _topLabel.textColor = CWHacker_ColorFromRGB(217, 0, 6);
    }
    if (isHackerFailed) {
        _bottomImageView.image = [UIImage imageNamed:@"CWResource.bundle/ico_error@2x.png"];
        _bottomLabel.text = @"后端防hack攻击检测失败!";
        _bottomLabel.textColor = CWHacker_ColorFromRGB(217, 0, 6);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
