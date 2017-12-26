//
//  CWAnimationView.h
//  CloudwalkFaceSDKDemo
//
//  Created by DengWuPing on 16/5/19.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWAnimationView : UIView

-(id)initWithFrame:(CGRect)frame;

-(void)showAnimation:(UIImage *)imageA  imageB:(UIImage *)imageB;

@end
