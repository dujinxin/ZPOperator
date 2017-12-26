//
//  CWOCRInfoController.m
//  CloudwalkFaceSDKDemo
//
//  Created by DengWuPing on 16/5/18.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import "CWOCRInfoController.h"
//#import "NSData+Base64.m"
//#import "NSString+Base64.h"

@interface CWOCRInfoController ()

@property(nonatomic,weak)IBOutlet UILabel  * nameLabel;

@property(nonatomic,weak)IBOutlet UILabel  * sexLabel;

@property(nonatomic,weak)IBOutlet UILabel  * nationLabel;

@property(nonatomic,weak)IBOutlet UILabel  * birthdayLabel;

@property(nonatomic,weak)IBOutlet UILabel  * addressLabel;

@property(nonatomic,weak)IBOutlet UILabel  * idNumberLabel;

@property(nonatomic,weak)IBOutlet UILabel  * organLabel;

@property(nonatomic,weak)IBOutlet UILabel  * timeLimitLabel;

@property(nonatomic,weak)IBOutlet UILabel  * frontCardTypeLabel;

@property(nonatomic,weak)IBOutlet UILabel  * backCardTypeLabel;

@property(nonatomic,weak)IBOutlet UIImageView  * headImageView;


@end

@implementation CWOCRInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setfronResultInfo];
    
    [self setBackResultInfo];
    
    self.addressLabel.adjustsFontSizeToFitWidth = YES;
}

#pragma mark
#pragma mark----------- setfronResultInfo   //设置身份证正面信息
/**
 *  @brief 设置身份证正面信息
 */
-(void)setfronResultInfo{
    
    if(self.frontInfoDictionary != nil ){
        if ([self.frontInfoDictionary objectForKey:@"name"] != nil) {
            self.nameLabel.text = [self.frontInfoDictionary objectForKey:@"name"];
        }
        if ([self.frontInfoDictionary objectForKey:@"sex"] != nil) {
            self.sexLabel.text = [self.frontInfoDictionary objectForKey:@"sex"];
        }
        
        if ([self.frontInfoDictionary objectForKey:@"folk"] != nil) {
            self.nationLabel.text = [self.frontInfoDictionary objectForKey:@"folk"];
        }
        
        if ([self.frontInfoDictionary objectForKey:@"cardno"] != nil) {
            self.idNumberLabel.text = [self.frontInfoDictionary objectForKey:@"cardno"];
        }
        
        if ([self.frontInfoDictionary objectForKey:@"address"] != nil) {
            self.addressLabel.text = [self.frontInfoDictionary objectForKey:@"address"];
        }
        
        if ([[self.frontInfoDictionary objectForKey:@"face"] objectForKey:@"image"] != nil) {
            
            NSData  * faceData = [[[self.frontInfoDictionary objectForKey:@"face"] objectForKey:@"image"] base64DecodedData];
            
            self.headImageView.image = [UIImage imageWithData:faceData];
        }
        if ([self.frontInfoDictionary objectForKey:@"code"] !=nil) {
            self.frontCardTypeLabel.text = [self getCardTypeInfo:[[self.frontInfoDictionary objectForKey:@"code"] integerValue]];
        }
        if ([self.frontInfoDictionary objectForKey:@"birthday"] != nil) {
            self.birthdayLabel.text = [self.frontInfoDictionary objectForKey:@"birthday"];
        }
    }
}

-(NSString  *)getCardTypeInfo:(NSInteger)code{
    NSString *  cardTypeInfo;
    switch (code) {
        case 0:
            cardTypeInfo = @"身份证原件";
            break;
        case 1:
            cardTypeInfo = @"身份证复印件";
            break;
        case 2:
        case 3:
            cardTypeInfo = @"身份证翻拍";
            break;
        default:
            break;
    }
    return  cardTypeInfo;
}

#pragma mark
#pragma mark----------- setBackResultInfo   //设置身份证背面信息

-(void)setBackResultInfo{
    if (_backInfoDictionary != nil) {
        
        if ([_backInfoDictionary objectForKey:@"authority"] !=nil ) {
            self.organLabel.text = [_backInfoDictionary objectForKey:@"authority"];
        }
        
        if ([_backInfoDictionary objectForKey:@"validdate1"] != nil && [_backInfoDictionary objectForKey:@"validdate2"] != nil) {
            
            self.timeLimitLabel.text = [NSString stringWithFormat:@"%@-%@",[self validdate:[_backInfoDictionary objectForKey:@"validdate1"]],[self validdate:[_backInfoDictionary objectForKey:@"validdate2"]]];
        }
        if ([self.backInfoDictionary objectForKey:@"code"] !=nil) {
            self.backCardTypeLabel.text = [self getCardTypeInfo:[[self.backInfoDictionary objectForKey:@"code"] integerValue]];
        }

    }
}
#pragma mark
#pragma mark----------- validdate   时间转换
/**
 *  @brief 时间转换
 *
 *  @param dateStr 有效期限时间字符串
 *
 *  @return 转换之后的字符串
 */
-(NSString *)validdate:(NSString *)dateStr{
    
    if (dateStr != nil && dateStr.length >= 8) {
        NSString  * timeStr = [NSString stringWithFormat:@"%@.%@.%@",[dateStr substringWithRange:NSMakeRange(0, 4)],[dateStr substringWithRange:NSMakeRange(4, 2)],[dateStr substringWithRange:NSMakeRange(dateStr.length-2, 2)]];
        return timeStr;
    }else
        return @"";
}

#pragma mark
#pragma mark----------- backToHomeViewController   返回上一层界面
/**
 *  @brief 返回上一层界面
 *
 *  @param sender 返回按钮
 */

-(IBAction)backToHomeViewController:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
#pragma mark----------- preferredStatusBarStyle //改变状态栏颜色

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
