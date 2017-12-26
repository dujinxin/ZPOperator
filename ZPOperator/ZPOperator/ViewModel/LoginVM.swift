//
//  LoginVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/23.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit
import AFNetworking

class LoginVM: JXRequest {


    lazy var userModel = UserModel()
    
    var dataArray = [[String:AnyObject]]()
    
    func login(userName:String, password:String, completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())){
        
        
        JXRequest.request(url: ApiString.userLogin.rawValue, param: ["phone":userName,"pwd":password], success: { (data, message) in
            
            guard let dict = data as? Dictionary<String, Any>
                else{
                    completion(nil,message,false)
                    return
            }
            
            UserManager.manager.userAccound.setValuesForKeys(dict)
            var mDict = dict

            self.loadSet(completion: { (data, msg, isSuccess) in
                guard let dict = data as? Dictionary<String, Any>
                    else{
                        UserManager.manager.userAccound = UserModel()
                        completion(nil,message,true)
                        return
                }
                for (key,value) in dict {
                    mDict[key] = value
                }
                UserManager.manager.saveAccound(dict: mDict)
                
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
    
    func identifyAuth(completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())){
        //邮箱：service@izheng.org
        //密码：izheng6666
        guard let base64Str = Base64.stringEncode("service@izheng.org:izheng6666") else {
            return
        }
        JXNetworkManager.manager.afmanager.requestSerializer.setValue("Basic \(base64Str)", forHTTPHeaderField: "Authorization")
        print("base64Str = \(base64Str)")
        
        JXRequest.request(method: .get, url: "https://data-customs-api.mana.com/hello", param: Dictionary(), success: { (data, message) in
            
            completion(data,message,true)
            
        }) { (message, code) in
            completion(nil,message,false)
        }
        
    }
    //识别
    func identifyFaceInfo(param:Dictionary<String,Any> ,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())){
        
        guard let base64Str = Base64.stringEncode("service@izheng.org:izheng6666") else {
            return
        }
        JXNetworkManager.manager.afmanager.requestSerializer.setValue("Basic \(base64Str)", forHTTPHeaderField: "Authorization")
        print("base64Str = \(base64Str)")
        
        JXRequest.request(url: "https://data-customs-api.mana.com/face_liveness_detection", param: param, success: { (data, message) in
            
            completion(data,message,true)
            
        }) { (message, code) in
            completion(nil,message,false)
        }
        
    }
    //识别身份证信息
    func identifyInfo(param:Dictionary<String,Any> ,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())){
        
        guard let base64Str = Base64.stringEncode("service@izheng.org:izheng6666") else {
            return
        }
        JXNetworkManager.manager.afmanager.requestSerializer.setValue("Basic \(base64Str)", forHTTPHeaderField: "Authorization")
        print("base64Str = \(base64Str)")
        
        JXRequest.request(url: "https://data-customs-api.mana.com/identity_ocr", param: param, success: { (data, message) in
            
            completion(data,message,true)
            
        }) { (message, code) in
            completion(nil,message,false)
        }
        
    }
    
    func modifyPassword(old:String,new:String,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) {
        JXRequest.request(url: ApiString.modifiyPwd.rawValue, param: ["oldPassword":old,"newPassword":new], success: { (data, message) in
            
            completion(data,message,true)
            
        }) { (message, code) in
            completion(nil,message,false)
        }
        
    }
    func logout(completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) {
        JXRequest.request(url: ApiString.logout.rawValue, param: Dictionary(), success: { (data, message) in
            
            completion(data,message,true)
            
            
        }) { (message, code) in
            completion(nil,message,false)
        }
    }
}

class IdentifyVM: JXRequest {
    
    var userData = Data()
    var frontImage = UIImage()
    var backImage = UIImage()
    
    var imageArray : Array<String> = ["facePhoto","idCardFront","idCardBack"]
    
    
    //识别
    func zpsyIdentifyInfo(param:Dictionary<String,Any> ,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())){
        
        IdentifyVM.request(url: ApiString.identifyInfo.rawValue, param: param, success: { (data, message) in
            completion(data,message,true)
            
        }) { (message, code) in
            completion(nil,message,false)
        }
    }
    override func customConstruct() -> JXBaseRequest.constructingBlock? {
        return {(_ formData : AFMultipartFormData) -> () in
            let format = DateFormatter()
            format.dateFormat = "yyyyMMddHHmmss"
            let timeStr = format.string(from: Date.init())
            
            for obj in self.imageArray {
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let path = paths[0] + "/\(obj)"
                if obj == "facePhoto"{
                    
                    let pathUrl = URL.init(fileURLWithPath: path)
                    guard let data = try? Data(contentsOf: pathUrl) else{
                        return
                    }
                    let stream = InputStream.init(data: data)
                    formData.appendPart(with: stream, name: obj, fileName: "\(obj)\(timeStr)", length: Int64(data.count), mimeType: "image/jpeg")
                    print(data)
                }else{
                    let pathUrl = URL.init(fileURLWithPath: path + ".jpg")
                    guard let data = try? Data(contentsOf: pathUrl) else{
                        return
                    }
                    let stream = InputStream.init(data: data)
                    formData.appendPart(with: stream, name: obj, fileName: "\(obj)\(timeStr).jpg", length: Int64(data.count), mimeType: "image/jpeg")
                    print(data)
                }
                
            }
            
        }
    }
}
