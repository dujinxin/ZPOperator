//
//  JXBaseRequest.swift
//  ShoppingGo
//
//  Created by 杜进新 on 2017/6/12.
//  Copyright © 2017年 杜进新. All rights reserved.
//

import UIKit
import AFNetworking

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
    ///标记不同的解析方式
    var tag : Int = 0
    
    
    var sessionTask : URLSessionTask?
    //func constructingBlock< T : AFMultipartFormData >(formData : [T]) -> T
    
    typealias constructingBlock = ((_ formData : AFMultipartFormData) -> Void)?
    typealias successCompletion = ((_ data:Any?, _ message:String) -> ())
    typealias failureCompletion = ((_ message:String,_ code:JXNetworkError) -> ())
    
    var construct : (()->(constructingBlock))?
    var success : successCompletion?
    var failure : failureCompletion?
    
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
    
    

    /// 网络请求
    ///
    /// - Parameters:
    ///   - tag: 暂时用来标记 来源，区别不同的域名，导致不同的数据格式
    ///   - method: 请求方式
    ///   - url: 请求URL
    ///   - param: 请求参数
    ///   - success: 成功回调
    ///   - failure: 失败回调
    class func request(tag:Int = 0, method:JXRequestMethod = .post, url:String, param:Dictionary<String, Any>,success:@escaping successCompletion,failure:@escaping failureCompletion) {
        
        
        
        let request = JXBaseRequest()
        
        request.tag = tag
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
        if responseData is Dictionary<String,Any> {
            print("responseData is Dictionary")
        }else if responseData is Data{
            print("responseData is Data")
        }else if responseData is String{
            print("responseData is String")
        }
        guard let data = responseData as? Data,
              let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])
            else{
                handleResponseResult(result: nil, message: "数据解析失败", code: JXNetworkError.kResponseUnknow, isSuccess: false)
                return
        }
        
        handleResponseResult(result: jsonData)
        
    }
    func requestFailure(error: Error) {
        print("请求失败:\(error)")
        handleResponseResult(result: error)
    }
    func handleResponseResult(result:Any?) {
        if tag != 0{
            handleUploadToken(result: result)
            return
        }
        var msg = "请求失败"
        var netCode : JXNetworkError = .kResponseUnknow
        var data : Any? = nil
        var isSuccess : Bool = false
        
        print("requestParam = \(String(describing: param))")
        print("requestUrl = \(String(describing: requestUrl))")
        
        if result is Dictionary<String, Any> {
            //print("Dictionary")
            let jsonDict = result as! Dictionary<String, Any>
            print("responseData = \(jsonDict)")
            
            guard let codeNum = jsonDict["code"] as? NSNumber,
                  let code = JXNetworkError(rawValue: codeNum.intValue)
                else {
                msg = "状态码未知"
                handleResponseResult(result: nil, message: msg, code: .kResponseDataError, isSuccess: isSuccess)
                return
            }
            
            let message = jsonDict["message"] as? String
            netCode = code
            
            if (code == .kResponseSuccess){
                print("请求成功")
                data = jsonDict["result"]
                msg = message ?? "请求成功"
                isSuccess = true
            }else if code == .kResponseTokenDisabled{
                JXNetworkManager.manager.userAccound?.removeAccound()
                JXNetworkManager.manager.userAccound = nil
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationLoginStatus), object: false)
            }else{
                print("请求失败")
                msg = message ?? "请求失败"
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
                    handleResponseResult(result: data, message: "Error", code: .kResponseUnknow, isSuccess: isSuccess)
                    return
            }
            netCode = code
            
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
            
        }else{
            print("未知数据类型")
        }
        handleResponseResult(result: data, message: msg, code: netCode, isSuccess: isSuccess)
    }
    func handleResponseResult(result:Any?,message:String,code:JXNetworkError,isSuccess:Bool) {
        
        
        if result is Dictionary<String, Any> {
            print("Dictionary")
            
        }else if result is Array<Any>{
            print("Array")
        }else if result is String{
            print("String")
        }else if result is NSNull{
            print("NULL")
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
    
    func handleUploadToken(result:Any?) {
        var msg = "请求失败"
        var netCode : JXNetworkError = .kResponseUnknow
        var data : Any? = nil
        var isSuccess : Bool = false
        
        print("requestParam = \(String(describing: param))")
        print("requestUrl = \(String(describing: requestUrl))")
        
        if result is Dictionary<String, Any> {
            //print("Dictionary")
            let jsonDict = result as! Dictionary<String, Any>
            //print("responseData = \(jsonDict)")
            
            guard let codeNum = jsonDict["errorCode"] as? NSString,
                let code = JXNetworkError(rawValue: Int(codeNum.intValue))
                else {
                    msg = "状态码未知"
                    handleResponseResult(result: nil, message: msg, code: .kResponseDataError, isSuccess: isSuccess)
                    return
            }
            
            let message = jsonDict["reason"] as? String
            netCode = code
            
            if (code == .kResponseSuccessForUploadToken){
                print("请求成功")
                data = jsonDict["result"]
                msg = message ?? "请求成功"
                isSuccess = true
            }else{
                print("请求失败")
                msg = message ?? "请求失败"
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
                    handleResponseResult(result: data, message: "Error", code: .kResponseUnknow, isSuccess: isSuccess)
                    return
            }
            netCode = code
            
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
            
        }else{
            print("未知数据类型")
        }
        handleResponseResult(result: data, message: msg, code: netCode, isSuccess: isSuccess)
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
