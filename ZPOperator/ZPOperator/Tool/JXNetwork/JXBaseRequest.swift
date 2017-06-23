//
//  JXBaseRequest.swift
//  ShoppingGo
//
//  Created by 杜进新 on 2017/6/12.
//  Copyright © 2017年 杜进新. All rights reserved.
//

import UIKit

enum JXRequestMethod : NSInteger{
    case get
    case post
    case put
    case head
    case delete
}


class JXBaseRequest: NSObject {

    ///请求URL
    var requestUrl : String?
    ///请求参数
    var param : Dictionary<String, Any>?
    ///请求方式
    var method : JXRequestMethod = .post
    
    var sessionTask : URLSessionTask?
    
    
    ///开始请求
    func startRequest() {
        //
        JXNetworkManager.manager.buildRequest(request: self)
    }
    ///停止请求
    func stopRequest() {
        //
        JXNetworkManager.manager.cancelRequest(request: self)
    }
    
    typealias successCompletion = ((_ data:Any?, _ message:String?) -> ())
    
    typealias failureCompletion = ((_ message:String?,_ code:JXNetworkError?) -> ())
    
    var success : successCompletion?
    
    var failure : failureCompletion?
    
    
    
//    ///
//    class func request(with method:JXRequestMethod = .post, url:String, param:[String:String],completion:(_ task:URLSessionDataTask, _ data:Any?, _ error:Error?) -> ()) {
//        let request = JXBaseRequest(url: url, param: param) { (task:URLSessionDataTask, data:Any?, error:Error?) in
//            //
//        }
//        
//        request.startRequest()
//    }
    
    ///
    class func request(with method:JXRequestMethod = .post, url:String, param:Dictionary<String, Any>,success:@escaping successCompletion,failure:@escaping failureCompletion) {
        
        
        
        let request = JXBaseRequest()

        request.requestUrl = url
        request.param = param
        request.success = success
        request.failure = failure
        
        //let request = self.init(with: url, param: param, success: success, failure: failure)
        
        request.startRequest()
    }
    
    override init() {
        super.init()
    }
    
//    init(with url:String ,param:[String:String],success:@escaping successCompletion,failure:@escaping failureCompletion) {
//        
//        
//        self.requestUrl = url
//        self.param = param
//        
//        self.success = success
//        self.failure = failure
//        
//        super.init()
//    }
    
   
    
//    func requestSuccess(responseData:Any) {
//        
//    }
//    func requestFailure(responseData:Any) {
//        
//    }
    
    func requestSuccess(responseData: Any) {
        //print("请求成功")
        
        let isJson = JSONSerialization.isValidJSONObject(responseData)
        print(isJson)
        guard let data = responseData as? Data,
              let jsonData = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
//            ,
//              let jsonDict = jsonData as? Dictionary<String, Any>
            else{
                handleResponseResult(result: nil, message: "数据解析失败", code: JXNetworkError.kResponseUnknow, isSuccess: false)
                return
        }
        
        handleResponseResult(result: jsonData)
        
        
//        guard let code = jsonDict["code"] as? NSNumber,
//              let result = jsonDict["result"]
//        else {
//            return
//        }
//        
//        if result is Dictionary<String, Any> {
//            print("Dictionary")
//        }else if result is Array<Any>{
//            print("Array")
//        }else if result is String{
//            print("String")
//        }else{
//            print("未知")
//        }
//        
//        let message = jsonDict["message"] as? String
//        if (code == 200){
//            print("请求成功")
//            handleResponseResult(result: result, message: message ?? "请求成功", code: 200, isSuccess: true)
//            
//        }else{
//            print("请求失败")
//            handleResponseResult(result: nil, message: message ?? "请求失败", code: 202, isSuccess: false)
//        }
        
        
    }
    func requestFailure(error: Error) {
        print("请求失败:\(error)")
        handleResponseResult(result: error)
        //handleResponseResult(result: error, message: "失败message", code: JXNetworkError.kResponseUnknow, isSuccess: false)
        
    }
    func handleResponseResult(result:Any?) {
        var msg = ""
        //var code : JXNetworkError
        
        print("requestUrl = \(String(describing: requestUrl))")
        
        
        if result is Dictionary<String, Any> {
            print("Dictionary")
            let jsonDict = result as! Dictionary<String, Any>
            print("responseData = \(jsonDict)")
            
            guard let codeNum = jsonDict["code"] as? NSNumber,
                  let code = JXNetworkError(rawValue: codeNum.intValue)
                else {
                handleResponseResult(result: nil, message: "状态码未知", code: .kResponseUnknow, isSuccess: false)
                return
            }
            
            let message = jsonDict["message"] as? String
            let data = jsonDict["result"]
            
            if (code == .kResponseSuccess){
                print("请求成功")
                handleResponseResult(result: data, message: message ?? "请求成功", code: .kResponseSuccess, isSuccess: true)
                
            }else if code == .kResponseFailed{
                print("请求失败")
                handleResponseResult(result: nil, message: message ?? "请求失败", code: .kResponseFailed, isSuccess: false)
            }else{
                print("请求失败")
                handleResponseResult(result: nil, message: message ?? "请求失败", code: .kResponseUnknow, isSuccess: false)
            }
            
        }else if result is Array<Any>{
            print("Array")
        }else if result is String{
            print("String")
        }else if result is Error{
            print("Error")
            guard let error = result as? NSError,
                  let code = JXNetworkError(rawValue: error.code)
                else {
                    handleResponseResult(result: nil, message: "Error", code: .kResponseUnknow, isSuccess: false)
                    return
            }
            
            
            switch code {
            case .kRequestErrorCannotConnectToHost,
                 .kRequestErrorCannotFindHost,
                 .kRequestErrorNotConnectedToInternet,
                 .kRequestErrorNetworkConnectionLost,
                 .kRequestErrorUnknown:
                msg = kRequestNotConnectedDomain;
                break;
            case .kRequestErrorTimedOut:
                msg = kRequestTimeOutDomain;
                break;
            case .kRequestErrorResourceUnavailable:
                msg = kRequestResourceUnavailableDomain;
                break;
            case .kResponseDataError:
                msg = kRequestResourceDataErrorDomain;
                break;
            default:
                msg = error.localizedDescription;
                break;
            }
            handleResponseResult(result: nil, message: msg, code: code, isSuccess: false)
            
        }else{
            print("未知数据类型")
        }
    }
    func handleResponseResult(result:Any?,message:String,code:JXNetworkError,isSuccess:Bool) {
        
        
        if result is Dictionary<String, Any> {
            print("Dictionary")
            
        }else if result is Array<Any>{
            print("Array")
        }else if result is String{
            print("String")
        }else{
            print("未知数据类型")
        }
        
        
        
        
        
        guard let success = self.success,
              let failure = self.failure
            else {
                return
        }
        
        if isSuccess {
            success(result,message)
        }else{
            failure(message,code)
        }
    }
}

extension JXBaseRequest {
    func responseHeaders() -> [AnyHashable : Any]{
        guard let response = self.sessionTask?.response as? HTTPURLResponse else {
            return [AnyHashable : Any]()
        }
        //let response = self.sessionTask?.response as! HTTPURLResponse
        return response.allHeaderFields 
    }
    
    func statusCode() -> Int {
        guard let response = self.sessionTask?.response as? HTTPURLResponse else {
            return 404
        }
        return response.statusCode
    }
    
    func statusCodeValidate() -> Bool {
        let code = self.statusCode()
        
        if code >= 200 && code <= 299 {
            return true
        } else {
            return false
        }
    }
    
}
