//
//  UserModel.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/23.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

private let userPath = NSHomeDirectory() + "/Documents/userAccound.json"


class UserModel: NSObject {
    
    var sid : String?
    
    override init() {
        super.init()
        
        let pathUrl = URL.init(fileURLWithPath: userPath)
        
        guard let data = try? Data(contentsOf: pathUrl),
              let dict = try? JSONSerialization.jsonObject(with: data, options: [])else {
            print("用户地址不存在：\(userPath)")
            return
        }
        self.setValuesForKeys(dict as! [String : Any])
        print("用户地址：\(userPath)")
        
    }
    

    func saveAccound(dict:Dictionary<String, Any>) -> Bool {
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
         else {
            return false
        }
        try? data.write(to: URL.init(fileURLWithPath: userPath))
        print("保存地址：\(userPath)")
 
        return true
    }
}
