
//
//  JXNetworkManager+Extention.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/23.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

extension JXNetworkManager{
    
    
    func dataRequest(url: String, param:Dictionary<String, Any>,completion:@escaping (_ data:Any?,_ msg:String?,_ isSuccess:Bool)->()) {
        JXRequest.request(url: url, param: param, success: { (data, message) in
            
            
            completion(data, message, true)
            
            
            //self.isLogin = true
            
        }) { (message, code) in
            //
            //self.isLogin = false
            completion(nil, message, false)
        }
    }
    
    func login(url: String,param:Dictionary<String, Any>, completion:@escaping ((_ data:Any?, _ msg:String?,_ isSuccess:Bool)->())){
        JXRequest.request(url: url, param: param, success: { (data, message) in
            
            completion(data, message, true)
            
            //let userModel = UserModel()
            
            guard let dict = data as? Dictionary<String, Any>
            
                else{
                return
            }
           UserManager.manager.saveAccound(dict: dict)
           
            //self.isLogin = true
            
        }) { (message, code) in
            //
            //self.isLogin = false
            completion(nil, message, false)
        }
    }
}
