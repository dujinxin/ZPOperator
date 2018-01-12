//
//  ConstantHeader.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/7/3.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation
import UIKit

//MARK:设备
let deviceModel = UIScreen.main.modelSize

//MARK:尺寸类
let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height
let kScreenBounds = UIScreen.main.bounds

let kStatusBarHeight = (deviceModel == .iPhoneX) ? CGFloat(44) : CGFloat(20)
let kNavBarHeight = CGFloat(44)
let kNavStatusHeight = kStatusBarHeight + kNavBarHeight
let kTabBarHeight = CGFloat(49)

let kHWPercent = (kScreenHeight / kScreenWidth)//高宽比例
let kPercent = kScreenWidth / 375.0

//MARK:颜色

let JX333333Color = UIColor.rgbColor(rgbValue: 0x333333)
let JX666666Color = UIColor.rgbColor(rgbValue: 0x666666)
let JX999999Color = UIColor.rgbColor(rgbValue: 0x999999)
let JXEeeeeeColor = UIColor.rgbColor(rgbValue: 0xeeeeee)
let JXFfffffColor = UIColor.rgbColor(rgbValue: 0xffffff)
let JXF1f1f1Color = UIColor.rgbColor(rgbValue: 0xf1f1f1)

let JXMainColor = UIColor.rgbColor(rgbValue: 0x0469c8)
let JXGrayColor = UIColor.rgbColor(from: 177, 178, 177)
let JXOrangeColor = UIColor.rgbColor(from: 219, 80, 8)

//tableView SeparatorView backgroundColor R:0.78 G:0.78 B:0.8 A:1
let JXSeparatorColor = UIColor.init(red: 0.78, green: 0.78, blue: 0.8, alpha: 1)

//MARK:字体
//let JXFontNormarl










		
