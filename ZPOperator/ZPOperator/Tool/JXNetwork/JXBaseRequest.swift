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
    
    case unknow
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
    class func request(tag:Int = 0, method:JXRequestMethod = .post, url:String, param:Dictionary<String, Any>?,success:@escaping successCompletion,failure:@escaping failureCompletion) {
        
        let request = self.init(tag: tag, method: method, url: url, param: param, success: success, failure: failure)
        
        request.startRequest()
    }
    
    override init() {
        super.init()
    }
    
    required init(tag:Int,method:JXRequestMethod,url:String ,param:Dictionary<String, Any>?,success:@escaping successCompletion,failure:@escaping failureCompletion) {
        
        self.tag = tag
        self.method = method
        self.requestUrl = url
        self.param = param
        
        self.success = success
        self.failure = failure
        
        super.init()
    }
    
   
    //子类实现
    func customConstruct() ->constructingBlock? {
        return nil
    }
    func buildCustomUrlRequest() -> URLRequest?{
        return nil
    }
    func requestSuccess(responseData:Any) {
        
    }
    func requestFailure(error: Error) {
        
    }
    
}

extension JXBaseRequest {
    func responseHeaders() -> [AnyHashable : Any]{
        guard let response = self.sessionTask?.response as? HTTPURLResponse else {
            return [AnyHashable : Any]()
        }
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
