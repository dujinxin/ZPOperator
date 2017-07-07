//
//  String+Extension.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/29.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    
    static func validateTelephone(tel:String) -> Bool {
        //手机号以13， 15，18开头，八个 \d 数字字符
        //NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
        //只做1开头，11位的校验，其他详细的交给后台来做
        let phoneRegex = "^1\\d{10}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return predicate.evaluate(with: tel)
    }
    //用户名 6-16位只含有汉字、数字、字母、下划线，下划线位置不限
//    func validateUserName(name:String) -> Bool {
//        let userNameRegex = "^[a-zA-Z0-9_\u4e00-\u9fa5]{2,12}+$"
//        let predicate = NSPredicate(format: "SELF MATCHES %@", userNameRegex)
//        return predicate.evaluate(with: name)
//    }
    //密码  8-16位数字或字母 ^[a-zA-Z0-9]{8,16}+$
    // 数字和密码的组合，不能纯数字或纯密码 ^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,16}$
    static func validatePassword(passWord:String) -> Bool {
        
        let passWordRegex = "^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,16}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passWordRegex)
        return predicate.evaluate(with: passWord)
    }
    static func validateVerficationCode(code:String) -> Bool {
        
        let passWordRegex = "^[0-9]{6}+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passWordRegex)
        return predicate.evaluate(with: code)
    }
    static func validateCode(code:String) -> Bool {
        
        let passWordRegex = "^[0-9]{12}+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passWordRegex)
        return predicate.evaluate(with: code)
    }
}

extension String {
    
    func calculate(width: CGFloat,fontSize:CGFloat,lineSpace:CGFloat = -1) -> CGSize {
        
        if self.isEmpty {
            return CGSize()
        }
        
        let ocText = self as NSString
        var attributes : Dictionary<String, Any>
        let paragraph = NSMutableParagraphStyle.init()
        paragraph.lineSpacing = lineSpace
        
        if lineSpace < 0 {
            attributes = [NSFontAttributeName:UIFont.systemFont(ofSize: fontSize)]
        }else{
            attributes = [NSFontAttributeName:UIFont.systemFont(ofSize: fontSize),NSParagraphStyleAttributeName:paragraph]
        }
        
        let rect = ocText.boundingRect(with: CGSize.init(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin,.usesFontLeading,.usesDeviceMetrics], attributes: attributes, context: nil)
        
        let height : CGFloat
        if rect.origin.x < 0 {
            height = abs(rect.origin.x) + rect.height
        }else{
            height = rect.height
        }
        
        return CGSize(width: width, height: height)
    }
}
