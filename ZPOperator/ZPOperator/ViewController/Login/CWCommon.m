//
//  CloudWalkCommon.m
//  DinnerGuestCloud
//
//  Created by Dfond on 14-9-16.
//  Copyright (c) 2014年 zdsoft. All rights reserved.
//

#import "CWCommon.h"
#import "sys/utsname.h"
#import <Commoncrypto/CommonDigest.h>
#include <math.h>

#define MainScreen [[UIScreen mainScreen] bounds]

#define BoxWidth 52

#define ActivitySize 50

#define CLOUDWALK_IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]


@implementation CWCommon

+ (instancetype)sharedClient{
    static CWCommon *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[CWCommon alloc]initSingle];
    });
    return _sharedClient;
}

-(id)initSingle{
    
    self = [super init];
    
    if(self){
        
    }
    return self;
}

-(id)init{
    return [self initSingle];
}

+ (UIColor *)colorWithFloatRed:(float)r green:(float)g blue:(float)b alpha:(float)a{
    return [UIColor colorWithRed:(r / 255.0f)
                           green:(g / 255.0f)
                            blue:(b / 255.0f)
                           alpha:a];
}

// 16进制字符串转换颜色

+ (UIColor *)colorWithHexString:(NSString *)colorString WithAlpha:(float)alpha{
    //删除字符串中的空格
    NSString *cString = [[colorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    if ([cString hasPrefix:@"0x"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [self colorWithFloatRed:r green:g blue:b alpha:alpha];
}

#pragma mark
#pragma mark----------- getViewControllerFromstoryboard  //从storyBoard中获取viewController
+ (UIViewController *)getViewControllerFromstoryboard:(NSString *)story WithRestorationID:(NSString *)identifier{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:story bundle:nil];
    return [storyBoard instantiateViewControllerWithIdentifier:identifier];
}

+ (void)saveKey:(NSString *)key withObject:(id)strO {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:strO forKey:key];
    [user synchronize];
}

+ (id)getValueForKey:(NSString *)key{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    return [user objectForKey:key];
}

//压缩图片
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size {
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}

//递归缩放图片
+(UIImage *)recureScaleImage:(UIImage *)oldImage{
   
    float  maxSize = oldImage.size.width > oldImage.size.height ? oldImage.size.width : oldImage.size.height;
    
    if (maxSize <=1200) {
        return oldImage;
    }else{
        
        float scale = maxSize/1200;
        
        UIImage * newImage = [CWCommon scaleToSize:oldImage size:CGSizeMake(oldImage.size.width/scale, oldImage.size.height/scale)];
        
        return newImage;
    }
}

//裁剪图片
+(UIImage *)getImageFromImage:(UIImage*) superImage  subImageRect:(CGRect)subImageRect
{
    
    CGImageRef imageRef = superImage.CGImage;
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, subImageRect);
    UIGraphicsBeginImageContext(subImageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, subImageRect, subImageRef);
    UIImage* returnImage = [UIImage imageWithCGImage:subImageRef];
    CFRelease(subImageRef);
    UIGraphicsEndImageContext();
    return returnImage;
}

//照片旋转90度处理
+(UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,CGImageGetBitsPerComponent(aImage.CGImage), 0,CGImageGetColorSpace(aImage.CGImage),CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;  
    }  
    
    // And now we just create a new UIImage from the drawing context  
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);  
    UIImage *img = [UIImage imageWithCGImage:cgimg];  
    CGContextRelease(ctx);  
    CGImageRelease(cgimg);  
    return img;  
}

@end
