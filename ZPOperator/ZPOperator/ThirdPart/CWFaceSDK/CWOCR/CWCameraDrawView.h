//
//  CameraDrawView.h
//
//  Created by DengWuPing on 16/11/7.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CWCameraDrawView : UIView {
    CGSize preSize;
    UIColor *  boundColor;
}

@property(nonatomic,assign)CGPoint  beginPoint;

@property(nonatomic,assign)CGPoint endPoint;

//卡片类型  0 身份证反面  1身份证正面  2银行卡正面

@property(nonatomic,assign)NSInteger cardType;;

@property(nonatomic,strong)UIButton  * closeButton;

@property(nonatomic,strong)UILabel *lable;

-(CGPoint)getBeginPoint;

-(CGPoint)getEndPoint;


-(void)SetPreSize:(CGSize)size;

-(void)showLineUP:(BOOL)up right:(BOOL)right bottom:(BOOL)bottom left:(BOOL)left;

-(void)showAnimation;
//停止动画
-(void)stopAnimation;


@end
