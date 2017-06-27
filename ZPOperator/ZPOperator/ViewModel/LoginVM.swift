//
//  LoginVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/23.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

class LoginVM {

    //var isLogin : Bool
    static let loginVMManager = LoginVM()
    
    lazy var userModel = UserModel()
    
    
    var dataArray = [[String:AnyObject]]()
    
    
    func login(userName:String, password:String, completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())){
        
        
        JXRequest.request(url: ApiString.userLogin.rawValue, param: ["phone":userName,"pwd":password], success: { (data, message) in
            
            guard let dict = data as? Dictionary<String, Any>
                else{
                    completion(nil,message,false)
                    return
            }
            var mDict = dict
            //print("保存登录信息成功：\(self.userModel.saveAccound(dict: dict))")
            self.loadSet(completion: { (data, msg, isSuccess) in
                guard let dict = data as? Dictionary<String, Any>
                    else{
                        completion(nil,message,true)
                        return
                }
                for (key,value) in dict {
                    mDict[key] = value
                }
                
                print("保存（登录-设置）信息成功：\(self.userModel.saveAccound(dict: mDict))")
                completion(data,message,true)
            })
            
            
        }) { (message, code) in
            completion(nil,message,false)
        }
    }

    func loadSet(completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())){
        JXRequest.request(url: ApiString.setting.rawValue, param: Dictionary(), success: { (data, message) in
            
            completion(data,message,true)
            
        }) { (message, code) in
            completion(nil,message,false)
        }
        
    }
}
