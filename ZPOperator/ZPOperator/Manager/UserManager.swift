//
//  UserManager.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/12/5.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

private let userPath = NSHomeDirectory() + "/Documents/userAccound.json"

class UserManager : NSObject{
    /// UserManager
    static let manager = UserManager()
    /// 用户信息model
    var userAccound = UserModel()
    /// 用户信息Dictionary
    var userDict = Dictionary<String, Any>()
    /// 是否登录
    var isLogin : Bool {
        return UserManager.manager.userAccound.sid != nil
    }
    
    override init() {
        super.init()
        
        let pathUrl = URL.init(fileURLWithPath: userPath)
        
        guard
            let data = try? Data(contentsOf: pathUrl),
            let dict = try? JSONSerialization.jsonObject(with: data, options: []) as! [String : Any] else {
                print("用户地址不存在：\(userPath)")
                return
        }
        self.userDict = dict
        self.userAccound.setValuesForKeys(dict)

        print("用户地址：\(userPath)")
    }
    /// 保存用户信息
    ///
    /// - Parameter dict: 用户信息
    /// - Returns: 结果
    func saveAccound(dict:Dictionary<String, Any>){

        self.userAccound.setValuesForKeys(dict)
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
            return
        }
        do {
            try data.write(to: URL.init(fileURLWithPath: userPath))
        } catch  {
            print("保存用户文件出错")
        }
    }
    /// 删除用户信息
    func removeAccound() {
        self.userAccound = UserModel()
        
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: userPath)
        } catch {
            print("删除用户文件出错")
        }
    }
}
