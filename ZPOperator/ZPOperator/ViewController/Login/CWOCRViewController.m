//
//  OCRViewController.m
//  CloudwalkFaceSDKDemo
//
//  Created by DengWuPing on 16/5/17.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import "CWOCRViewController.h"
#import "CWCommon.h"
#import "CWOCRInfoController.h"
#import "CloudwalkIDCardOCR.h"
#import "CWMBProgressHud.h"
#import "CWIDCardCaptureController.h"

@interface CWOCRViewController ()<cwIdCardRecoDelegate>
{
    
    UIView      *    headView;   //自定义导航栏
    
    UIView      *    ButtomView;//底部视图view
    
    UILabel     *    titleLabel;//最上面提示语label
    
    UIButton    *    backButton;//身份证反面按钮
    
    UIButton    *    frontButton;//身份证正面按钮
    
    NSInteger        buttonTag;  //正反面按钮tag值
    
    NSString    *    frontBaseStr;  //身份证正面图片base64
    
    NSString    *    backBaseStr;  //身份证反面图片base64
    
    BOOL             isFront;   //身份证正面是否识别完成
    
    BOOL             isBack;   //身份证背面是否识别完成
    
    NSDictionary  *   frontDictionary;  //身份证正面识别结果
    
    NSDictionary  *   backDictionary;  //身份证背面识别结果
}

@end


@implementation CWOCRViewController


-(void)createHeaderView{
    //背景图片
    UIImageView*bejingImg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CWLIVESSSCREEN_WIDTH, CWLIVESSSCREEN_HEIGHT)];
    bejingImg.image=[UIImage imageNamed:@"beijing"];
    [self.view addSubview:bejingImg];
    
    //自定义导航条
    headView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CWLIVESSSCREEN_WIDTH, 64)];
    headView.backgroundColor=CWFR_ColorFromRGB(232,0,0);
    [self.view addSubview:headView];
    
    //自定义导航条的返回按钮
    UIButton*backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"jiantou"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(5, 20, 40, 40);
    [backBtn addTarget:self action:@selector(backToHomeViewController:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:backBtn];
    
    //自定义导航条的标题
    UILabel*headViewLabel=[[UILabel alloc]initWithFrame:CGRectMake((CWLIVESSSCREEN_WIDTH-200)/2, 20, 200, 44)];
    headViewLabel.text=@"身份证识别";
    headViewLabel.textColor=[UIColor whiteColor];
    headViewLabel.font=[UIFont systemFontOfSize:18];
    [headView addSubview:headViewLabel];
    headViewLabel.textAlignment = NSTextAlignmentCenter;
}

-(void)creatView{
    
    //识别按钮
    UIButton*recognaizeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    recognaizeBtn.frame = CGRectMake(CWLIVESSSCREEN_WIDTH * 0.11, CWLIVESSSCREEN_HEIGHT - CWLIVESSSCREEN_WIDTH * 0.14 - CWLIVESSSCREEN_HEIGHT * 0.06, CWLIVESSSCREEN_WIDTH * 0.78, CWLIVESSSCREEN_WIDTH * 0.133);
    [recognaizeBtn setTitle:@"识别" forState:UIControlStateNormal];
    recognaizeBtn.titleLabel.textColor=[UIColor whiteColor];
    recognaizeBtn.titleLabel.font=[UIFont systemFontOfSize:18];
    [recognaizeBtn addTarget:self action:@selector(recognition:) forControlEvents:UIControlEventTouchUpInside];
    recognaizeBtn.layer.cornerRadius=5;
    [recognaizeBtn setBackgroundColor: CWFR_ColorFromRGB(232,0,0)] ;
    [self.view addSubview:recognaizeBtn];
    
    //label  view1  view2 在ButtomView
    
    titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(CWLIVESSSCREEN_WIDTH * 0.1,64 + CWLIVESSSCREEN_HEIGHT * 0.03,CWLIVESSSCREEN_WIDTH * 0.8, 40)];
    titleLabel.font=[UIFont systemFontOfSize:15];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.text = [NSString stringWithFormat:@"请按要求拍摄身份证\n 至少拍摄身份证一面才可以进行识别"];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.adjustsFontSizeToFitWidth=YES;
    titleLabel.numberOfLines=0;
    [self.view addSubview:titleLabel];
    
    //底部view
    ButtomView=[[UIView alloc]initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + 10 + titleLabel.frame.size.height, CWLIVESSSCREEN_WIDTH, recognaizeBtn.frame.origin.y -titleLabel.frame.origin.y - titleLabel.frame.size.height - CWLIVESSSCREEN_WIDTH * 0.1)];
    [self.view addSubview:ButtomView];
    
    UIView*view1=[[UIView alloc]initWithFrame:CGRectMake(0, 0,ButtomView.frame.size.width,  ButtomView.frame.size.height * 0.47)];
    [ButtomView addSubview:view1];
    
    //身份证上的控件  frontButton
    //正面图片
    frontButton=[UIButton buttonWithType:UIButtonTypeCustom];
    frontButton.frame = CGRectMake(0, 0, view1.frame.size.width, view1.frame.size.height - 20);
    [frontButton setImage:[UIImage imageNamed:@"zhengmian"] forState:UIControlStateNormal];
    frontButton.imageView.contentMode=UIViewContentModeScaleAspectFit;
    frontButton.imageView.clipsToBounds = YES;
    frontButton.imageView.layer.masksToBounds = YES;
    [frontButton addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    frontButton.tag=100;
    [view1 addSubview:frontButton];
    
    UILabel*frontLbel=[[UILabel alloc]initWithFrame:CGRectMake(0, frontButton.frame.size.height+5, view1.frame.size.width, 15)];
    frontLbel.text=@"点击拍摄身份证正面(人像面)";
    frontLbel.font=[UIFont systemFontOfSize:15];
    frontLbel.textColor=[UIColor whiteColor];
    frontLbel.textAlignment=NSTextAlignmentCenter;
    [view1 addSubview:frontLbel];
    
    UIView*view2 = [[UIView alloc]initWithFrame:CGRectMake(0, view1.frame.origin.y + ButtomView.frame.size.height * 0.53, ButtomView.frame.size.width, ButtomView.frame.size.height * 0.47)];
    [ButtomView addSubview:view2];
    //身份证反面上的控件
    //反面的图片按钮
    backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"beimian"] forState:UIControlStateNormal];
    backButton.imageView.contentMode=UIViewContentModeScaleAspectFit;
    backButton.frame = CGRectMake(0, 0, view1.frame.size.width, view2.frame.size.height - 20);
    
    backButton.imageView.clipsToBounds = YES;
    backButton.imageView.layer.masksToBounds = YES;
    
    [backButton addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    backButton.tag=101;
    [view2 addSubview:backButton];
    
    UILabel*backLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, backButton.frame.size.height+5, view2.frame.size.width, 15)];
    backLabel.text=@"点击拍摄身份证反面(国徽面)";
    backLabel.font=[UIFont systemFontOfSize:15];
    backLabel.textColor=[UIColor whiteColor];
    backLabel.textAlignment=NSTextAlignmentCenter;
    [view2 addSubview:backLabel];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self createHeaderView];
    
    //纯代码布局页面
    [self creatView];
    
    [self clearCache];
}

#pragma mark
#pragma mark----------- backToHomeViewController   返回上一层界面
/**
 *  @brief 返回上一层界面
 *
 *  @param sender 返回按钮
 */

-(void)backToHomeViewController:(id)sender{
    
    //释放资源
    [[CloudwalkIDCardOCR sharInstance]cwDestroyIdCardRecog];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  @brief 清空上一次的缓存
 */
-(void)clearCache{
    isFront = NO;
    isBack = NO;
    frontBaseStr = nil;
    backBaseStr = nil;
    frontDictionary = nil;
    backDictionary = nil;
}

#pragma
#pragma mark-----------  selectPhoto 选择照片
/**
 *  @brief 选择照片
 *
 *  @param sender 身份证正反面按钮
 */
-(void)selectPhoto:(UIButton *)sender{
    
    buttonTag = sender.tag;

    //身份证扫描自动检测 无需拍照
    CWIDCardCaptureController  * cvctrl = [[CWIDCardCaptureController alloc]init];
    
    cvctrl.lisenceStr = self.licenseStr;
    
    cvctrl.delegate = self;
    
    if (buttonTag == 100) {
        cvctrl.type = CWIDCardTypeFront;
    }else{
        cvctrl.type = CWIDCardTypeBack;
    }
    //设置图片清晰度阈值
    cvctrl.cardQualityScore = 0.62f;
    
    [self presentViewController:cvctrl animated:YES completion:nil];
}

-(void)setDefaultImage{
    if (buttonTag == 100) {
        [self setSelectImage:[UIImage imageNamed:@"zhengmian"]];
    }else{
        [self setSelectImage:[UIImage imageNamed:@"beimian"]];
    }
}

-(void)setSelectImage:(UIImage *)image{
    if (buttonTag == 100) {
        [frontButton setImage:image forState:UIControlStateNormal];
        [frontButton setImage:image forState:UIControlStateSelected];
    }else{
        [backButton setImage:image forState:UIControlStateNormal];
        [backButton setImage:image forState:UIControlStateSelected];
    }
}

/**
 *  @brief 相机拍照代理方法
 *
 *  @param cardImage 拍摄的身份证图片
 */

-(void)cwIdCardDetectionCardImage:(UIImage *)cardImage imageScore:(double)score{
    
    if(cardImage!=nil){
        
#warning UIImageWriteToSavedPhotosAlbum 仅作为测试查看图片，正式集成时可以去掉
        UIImageWriteToSavedPhotosAlbum(cardImage, nil, nil, nil);
        
        NSData * imageData = UIImageJPEGRepresentation(cardImage, .8f);
        
        if (buttonTag == 100) {
            frontBaseStr = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        }else{    //身份证反面
            backBaseStr = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        }
        [self setSelectImage:cardImage];
    }
}

#pragma mark
#pragma mark----------- recognition //身份证识别
/**
 *  @brief 识别
 *
 *  @param sender 识别按钮
 */
-(void)recognition:(id)sender{

    frontDictionary = nil;
    
    backDictionary = nil;
    
    if (frontBaseStr == nil && backBaseStr == nil) {
        [[CWMBProgressHud sharedClient] showHudModel:NO message:@"请选择正确的身份证图片!" hudMode:CWMBProgressHudModeCustomView];
    }else{
       
//        [[CWMBProgressHud sharedClient] showHudModel:NO message:@"身份证识别中...." hudMode:CWMBProgressHudModeIndeterminate];
        
        isFront = NO;
        
        isBack = NO;
        
        if (frontBaseStr != nil) {
            //发送身份证正面进行识别
           
        }
        if (backBaseStr != nil) {
            isBack = YES;
            //发送身份证背面进行识别
            
        }
    }
}

/**
 *  @brief 身份证识别结果显示
 */
-(void)setRecognitionResultInfo{
        
    if (isFront == YES && isBack == YES && ( (frontDictionary != nil && backDictionary != nil ))) {
        if( [[frontDictionary objectForKey:@"result"] integerValue] == 0 && [[backDictionary objectForKey:@"result"] integerValue] == 0){
            [self setResult];
        }else{
            [[CWMBProgressHud sharedClient] showHudModel:NO message:@"身份证识别失败!" hudMode:CWMBProgressHudModeCustomView];
        }
    }
    else if (isFront == YES && isBack== YES &&(frontDictionary == nil && backDictionary == nil)){
        [[CWMBProgressHud sharedClient] showHudModel:NO message:@"身份证识别失败!" hudMode:CWMBProgressHudModeCustomView];
    }
    else if (isFront == YES && isBack == NO){
        if ((frontDictionary != nil && [[frontDictionary objectForKey:@"result"] integerValue] == 0)) {
            [self setResult];
        }else{
            [[CWMBProgressHud sharedClient] showHudModel:NO message:@"身份证识别失败!" hudMode:CWMBProgressHudModeCustomView];
        }
    }else if (isBack==YES && isFront ==NO){
        if ((backDictionary != nil && [[backDictionary objectForKey:@"result"] integerValue] == 0)) {
            [self setResult];
        }else{
            [[CWMBProgressHud sharedClient] showHudModel:NO message:@"身份证识别失败!" hudMode:CWMBProgressHudModeCustomView];
        }
    }
}

-(void)setResult{
    
    [[CWMBProgressHud sharedClient] hideHud];
    
    CWOCRInfoController  * ocvctrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"CWOCRInfoController"];
    
    ocvctrl.frontInfoDictionary = frontDictionary;
    
    ocvctrl.backInfoDictionary = backDictionary;
    
    [self.navigationController pushViewController:ocvctrl animated:YES];
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
