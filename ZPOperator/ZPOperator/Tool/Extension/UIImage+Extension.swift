
//
//  UIImage+Extension.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/7/1.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// 依据宽度等比例对图片重新绘制
    ///
    /// - Parameters:
    ///   - originalImage: 原图
    ///   - scaledWidth: 将要缩放或拉伸的宽度
    /// - Returns: 新的图片
    class func image(originalImage:UIImage? ,to scaledWidth:CGFloat) -> UIImage? {
        guard let image = originalImage else {
            return UIImage.init()
        }
        let imageWidth = image.size.width
        let imageHeigth = image.size.height
        let width = scaledWidth
        let height = image.size.height / (image.size.width / width)
        
        let widthScale = imageWidth / width
        let heightScale = imageHeigth / height
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        
        if widthScale > heightScale {
            image.draw(in: CGRect(x: 0, y: 0, width: imageWidth / heightScale, height: heightScale))
        } else {
            image.draw(in: CGRect(x: 0, y: 0, width: width, height: imageHeigth / widthScale))
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
