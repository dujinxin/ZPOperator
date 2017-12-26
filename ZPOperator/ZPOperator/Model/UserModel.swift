//
//  UserModel.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/23.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

private let userPath = NSHomeDirectory() + "/Documents/userAccound.json"


class UserModel: BaseModel {
    
    //登录接口获取
    var sid : String?
    var type : Int = 1 //操作员类型:1无网点2有网点
    var isAuthed : Int = 0 //是否经过人脸身份证认证:0未认证1已认证
    
    
    //设置接口获取
    var mobile : String?
    var stationName : String?
    var userName : String?
    
    
//    override init() {
//        super.init()
//
//        let pathUrl = URL.init(fileURLWithPath: userPath)
//
//        guard let data = try? Data(contentsOf: pathUrl),
//              let dict = try? JSONSerialization.jsonObject(with: data, options: [])else {
//            print("用户地址不存在：\(userPath)")
//            return
//        }
//        self.setValuesForKeys(dict as! [String : Any])
//        print("用户地址：\(userPath)")
//
//    }
//
//
//    func saveAccound(dict:Dictionary<String, Any>) -> Bool {
//
//        setValuesForKeys(dict)
//
//        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
//         else {
//            return false
//        }
//        try? data.write(to: URL.init(fileURLWithPath: userPath))
//        print("保存地址：\(userPath)")
//
//        return true
//    }
//    func removeAccound() {
//        let fileManager = FileManager.default
//        try? fileManager.removeItem(atPath: userPath)
//    }
}
