
//
//  UIImageView+Extension.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/7/18.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit
import SDWebImage

extension UIImageView {
    
    func jx_setImage(with urlStr:String, placeholderImage: UIImage?,isRound:Bool = false){
        
        guard let url = URL(string: urlStr) else {
            self.image = placeholderImage
            return
        }
        self.sd_setImage(with: url, placeholderImage: placeholderImage, options: [], progress: nil) { (image, error, _, url) in
            if
                let image = image,
                isRound == true{
                
                //self.image.
            }
        }
    }
    
}
