//
//  UIScreen+Extension.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/7/3.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

enum Model:String {
    case iPhoneSE
    case iPhone8
    case iPhone8p
    case iPhoneX
}

extension UIScreen {
    
    var modelSize: Model {
        get{
            guard let mode = self.currentMode
                else {
                    return .iPhoneSE
            }
            switch mode.size {
            case CGSize(width: 640.0, height: 1136.0):
                return .iPhoneSE
            case CGSize(width: 750.0, height: 1334.0):
                return .iPhone8
            case CGSize(width: 1242.0, height: 2208.0):
                return .iPhone8p
            case CGSize(width: 1125.0, height: 2436.0):
                return .iPhoneX
            default:
                return .iPhoneSE
            }
        }
    }
    
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
    
//    var model : Model {
//        get{
//            switch self.modelName {
//            case "iPhone X":
//                return .iPhoneX
//            default:
//                return .iPhone8p
//            }
//        }
//    }
    var modelName : String {
        get{
            var systemInfo = utsname()
            uname(&systemInfo)
            
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard
                    let value = element.value as? Int8, value != 0
                    else {
                        return identifier
                }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            
            switch identifier {
            case "iPod1,1":  return "iPod Touch 1"
            case "iPod2,1":  return "iPod Touch 2"
            case "iPod3,1":  return "iPod Touch 3"
            case "iPod4,1":  return "iPod Touch 4"
            case "iPod5,1":  return "iPod Touch (5 Gen)"
            case "iPod7,1":  return "iPod Touch 6"
                
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":  return "iPhone 4"
            case "iPhone4,1":  return "iPhone 4s"
            case "iPhone5,1":  return "iPhone 5"
            case "iPhone5,2":  return "iPhone 5 (GSM+CDMA)"
            case "iPhone5,3":  return "iPhone 5c (GSM)"
            case "iPhone5,4":  return "iPhone 5c (GSM+CDMA)"
            case "iPhone6,1":  return "iPhone 5s (GSM)"
            case "iPhone6,2":  return "iPhone 5s (GSM+CDMA)"
            case "iPhone7,2":  return "iPhone 6"
            case "iPhone7,1":  return "iPhone 6 Plus"
            case "iPhone8,1":  return "iPhone 6s"
            case "iPhone8,2":  return "iPhone 6s Plus"
            case "iPhone8,4":  return "iPhone SE"
            case "iPhone9,1":  return "国行、日版、港行iPhone 7"
            case "iPhone9,2":  return "港行、国行iPhone 7 Plus"
            case "iPhone9,3":  return "美版、台版iPhone 7"
            case "iPhone9,4":  return "美版、台版iPhone 7 Plus"
            case "iPhone10,1","iPhone10,4":   return "iPhone 8"
            case "iPhone10,2","iPhone10,5":   return "iPhone 8 Plus"
            case "iPhone10,3","iPhone10,6":   return "iPhone X"
                
            case "iPad1,1":   return "iPad"
            case "iPad1,2":   return "iPad 3G"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":   return "iPad 2"
            case "iPad2,5", "iPad2,6", "iPad2,7":  return "iPad Mini"
            case "iPad3,1", "iPad3,2", "iPad3,3":  return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":  return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":  return "iPad Air"
            case "iPad4,4", "iPad4,5", "iPad4,6":  return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":  return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":  return "iPad Mini 4"
            case "iPad5,3", "iPad5,4":  return "iPad Air 2"
            case "iPad6,3", "iPad6,4":  return "iPad Pro 9.7"
            case "iPad6,7", "iPad6,8":  return "iPad Pro 12.9"
            case "AppleTV2,1":  return "Apple TV 2"
            case "AppleTV3,1","AppleTV3,2":  return "Apple TV 3"
            case "AppleTV5,3":   return "Apple TV 4"
            case "i386", "x86_64":   return "Simulator"
            default:  return identifier
            }
        }
    }
}
