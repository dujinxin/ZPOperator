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
    
    var dataArray = [[String:AnyObject]]()
    
    
    
    func login(userName:String, password:String, completion:@escaping ((_ data:Any?, _ msg:String?,_ isSuccess:Bool)->())){
        
        JXNetworkManager.manager.login(url: ApiString.userLogin.rawValue, param: ["phone":userName,"pwd":password]) { (data, msg, isSuccess) in
            
            completion(data,msg,isSuccess)
            //dataArray = data
            
        }
        
//        JXRequest.request(url: ApiString.userLogin.rawValue, param: ["phone":userName,"pwd":password], success: { (data, message) in
//            //
//            
//            //self.isLogin = true
//            
//        }) { (message, code) in
//            //
//            //self.isLogin = false
//        }
    }
//    JXNetworkManager.manager.dataRequest(url: ApiString.userLogin.rawValue, param: ["phone":userTextField.text!,"pwd":passwordTextField.text!]) { (data, msg, isSuccess) in
//    //
//    }
//    
    func loadMainData(append:Bool = false) -> Array<Dictionary<String, AnyObject>> {
        
        for i in 1..<9 {
            var dict = Dictionary<String, AnyObject>()
            dict["title"] = "大连暖棚樱桃苹果20170\(i)" as AnyObject
            dataArray.append(dict)
        }
        if append {
            dataArray.append(["title":"更多溯源批次" as AnyObject])
        }
        return dataArray
    }
}
