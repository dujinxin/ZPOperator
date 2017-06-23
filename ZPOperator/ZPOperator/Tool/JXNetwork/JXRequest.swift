
//
//  JXRequest.swift
//  ShoppingGo
//
//  Created by 杜进新 on 2017/6/12.
//  Copyright © 2017年 杜进新. All rights reserved.
//

import UIKit

class JXRequest: JXBaseRequest {
    
//    override init(with url: String, param: [String : String], success: @escaping successCompletion, failure: @escaping failureCompletion) {
//        super.init(with: url, param: param, success: success, failure: failure)
//    }
    
//    override func requestSuccess(responseData: Any) {
//        super.requestSuccess(responseData: responseData)
//        guard let success = self.success else {
//            return
//        }
//        success(responseData,"123")
//        print(responseData)
//    }
//    override func requestFailure(responseData: Any) {
//        super.requestFailure(responseData: responseData)
//        print(responseData)
//    }
//    
//    
//    override func requestSuccess(responseData: Any) {
//        //print("请求成功")
//        print(responseData)
//        
//        var isSuccess = false
//        
//        let isJson = JSONSerialization.isValidJSONObject(responseData)
//        print(isJson)
//        guard let data = responseData as? Data,
//            let jsonData = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers),
//            let jsonDict = jsonData as? Dictionary<String, Any>
//            else{
//                handleResponseResult(result: nil, message: "数据解析失败", code: 202, isSuccess: false)
//                return
//        }
//        
//        print("responseData = \(jsonDict)")
//        //print("code = \(jsonDict["code"]) message = \(jsonDict["msg"])")
//        
//        
//        guard let code = jsonDict["code"] as? NSNumber,
//            let message = jsonDict["message"] as? String,
//            let result = jsonDict["result"]
//            else {
//                return
//        }
//        if (code == 200){
//            isSuccess = true
//            print("请求成功")
//            handleResponseResult(result: result, message: message, code: 200, isSuccess: true)
//            
//        }else{
//            print("请求失败")
//            handleResponseResult(result: nil, message: message, code: 202, isSuccess: false)
//        }
//        
//        
//    }
//    override func requestFailure(responseData: Any) {
//        print("请求失败")
//        print(responseData)
//        handleResponseResult(result: nil, message: "失败message", code: 202, isSuccess: false)
//        
//    }
//    
//    override func handleResponseResult(result:Any?,message:String,code:Int,isSuccess:Bool) {
//        guard let success = self.success,
//            let failure = self.failure
//            else {
//                return
//        }
//        
//        if isSuccess {
//            success(result,message)
//        }else{
//            failure(message,code)
//        }
//    }

}
