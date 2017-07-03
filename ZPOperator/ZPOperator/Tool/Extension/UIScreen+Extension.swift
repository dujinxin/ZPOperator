//
//  UIScreen+Extension.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/7/3.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

extension UIScreen {
    
    var screenSize : CGSize {
        get{
            return bounds.size
        }
    }
    var screenWidth : CGFloat {
        get{
            return bounds.width
        }
    }
    var screenHeight : CGFloat {
        get{
            return bounds.height
        }
    }
    
}
