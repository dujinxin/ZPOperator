//
//  CWAnimationView.m
//  CloudwalkFaceSDKDemo
//
//  Created by DengWuPing on 16/5/19.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import "CWAnimationView.h"

@implementation CWAnimationView

{
    UIImageView         *      currentAnimationView;// 当前的动画
    
    UIImageView         *      nextAnimationView; //下一个动作的动画
    
    CGFloat                    animationWidth;
}

//屏幕宽
#define  CWSCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width
//屏幕高
#define  CWSCREEN_HEIGHT  [[UIScreen mainScreen] bounds].size.height


-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        animationWidth = frame.size.height * 0.8;
        
        [self addBottomAnimationView];
    }
    return self;
}

#pragma mark
#pragma mark addBottomAnimationView  //添加底部的动画提示

-(void)addBottomAnimationView{
    
    currentAnimationView = [[UIImageView alloc]initWithFrame:CGRectMake((CWSCREEN_WIDTH-animationWidth)/2, (self.frame.size.height-animationWidth)/2, animationWidth, animationWidth)];
    currentAnimationView.backgroundColor = [UIColor clearColor];
    currentAnimationView.layer.masksToBounds = YES;
    currentAnimationView.clipsToBounds = YES;
    [self addSubview:currentAnimationView];
    [self bringSubviewToFront:currentAnimationView];
    currentAnimationView.hidden = YES;
}

#pragma mark
#pragma mark showAnimationView  //每一步动作的动画提示

-(void)showAnimation:(UIImage *)imageA imageB:(UIImage *)imageB{
    
    //动画提示
    nextAnimationView = [[UIImageView alloc]initWithFrame:CGRectMake(CWSCREEN_WIDTH+10, (self.frame.size.height-animationWidth)/2, animationWidth, animationWidth)];
    
    nextAnimationView.clipsToBounds = YES;
    
    nextAnimationView.layer.masksToBounds = YES;
    
    
    [self addSubview:nextAnimationView];
    
    NSArray * anmationArray = [NSArray arrayWithObjects:imageA,imageB,nil];
    
    nextAnimationView.animationImages = anmationArray;
    nextAnimationView.animationDuration = 2; //执行一次完整动画所需的时长
    nextAnimationView.animationRepeatCount = 0;  //动画重复次数 0表示无限次，默认为0
    [nextAnimationView startAnimating];
    
    currentAnimationView.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        nextAnimationView.frame = currentAnimationView.frame;
        
        currentAnimationView.frame = CGRectMake(-animationWidth, (self.frame.size.height-animationWidth)/2, animationWidth, animationWidth);
        
        currentAnimationView = nextAnimationView;
        
    } completion:^(BOOL flag){
        
    }];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
