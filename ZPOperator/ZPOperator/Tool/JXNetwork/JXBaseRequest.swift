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
    var param : [String:String]?
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
    
    typealias successCompletion = ((_ data:Any?, _ message:String?,_ alertType:String) -> ())
    
    typealias failureCompletion = ((_ task:URLSessionDataTask, _ error:Error?) -> ())
    
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
    class func request(with method:JXRequestMethod = .post, url:String, param:[String:String],success:@escaping successCompletion,failure:@escaping failureCompletion) {
        
        
        
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
        print(responseData)
        guard let success = self.success else {
            return
        }
        success(responseData,"123","34")
        
    }
    func requestFailure(responseData: Any) {
        print(responseData)
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
