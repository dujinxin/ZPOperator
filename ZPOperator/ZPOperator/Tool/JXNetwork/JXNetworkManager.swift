//
//  JXNetworkManager.swift
//  ShoppingGo
//
//  Created by 杜进新 on 2017/6/12.
//  Copyright © 2017年 杜进新. All rights reserved.
//

import UIKit

import AFNetworking

class JXNetworkManager: NSObject {
    
    var afmanager = AFHTTPSessionManager()
    
    var requestCache = [String:JXBaseRequest]()
    
    var networkStatus : AFNetworkReachabilityStatus = .reachableViaWiFi
    
    lazy var userAccound = UserModel()
    
    var isLogin : Bool {
        return userAccound.sid != nil
    }
    
    var sid : String? {
        return ""
    }
    
    
    static let manager = JXNetworkManager()
    
    override init() {
        super.init()
        
        afmanager.responseSerializer = AFHTTPResponseSerializer.init()
        afmanager.responseSerializer.acceptableContentTypes = NSSet(objects: "text/html","application/json") as? Set<String>
        
        afmanager.operationQueue.maxConcurrentOperationCount = 5
        afmanager.requestSerializer.timeoutInterval = 10
        
        
        //afmanager.requestSerializer.setValue("", forHTTPHeaderField: "")
        
        afmanager.reachabilityManager = AFNetworkReachabilityManager.shared()
        afmanager.reachabilityManager.startMonitoring()
        afmanager.reachabilityManager.setReachabilityStatusChange { (status:AFNetworkReachabilityStatus) in
            print("网络状态变化 == \(status.rawValue)")
            self.networkStatus = AFNetworkReachabilityStatus(rawValue: status.rawValue)!
        }
    }

    func buildRequest(request:JXBaseRequest) {

        ///网络判断
        if networkStatus == .unknown || networkStatus == .notReachable {
            print("网络不可用")
            return
        }
        
        ///获取URL
        let url = buildUrl(url: request.requestUrl)
        
        if isLogin == true,
           let sid = userAccound.sid {
            afmanager.requestSerializer.setValue("sid=\(sid)", forHTTPHeaderField: "Cookie")
        }
        
        
        switch request.method {
        case .get:
            request.sessionTask = afmanager.get(url, parameters: request.param, progress: nil, success: { (task:URLSessionDataTask, responseData:Any?) in
                self.handleTask(task: task, data: responseData, error: nil)
            }, failure: { (task:URLSessionDataTask?, error:Error) in
                self.handleTask(task: task!, data: nil, error: error)
            })
        case .post:
//            if request. {
//                <#code#>
//            }
//            afmanager.post(url, parameters: request.param, constructingBodyWith: { (formdata) in
//                //
//                
//                let str = NSHomeDirectory() + "/Documents/userImage.jpg"
//                let url = URL.init(fileURLWithPath: str)
//                let data = try? Data.init(contentsOf: url)
//                formdata.appendPart(withFileData: data!, name: "image", fileName: "userImage.jpg", mimeType: "image/jpeg")
//                
//            }, progress: nil, success: { (task, res) in
//                //
//            }, failure: { (task, error) in
//                //
//            })
            request.sessionTask = afmanager.post(url, parameters: request.param, progress: nil, success: { (task:URLSessionDataTask, responseData:Any?) in
                self.handleTask(task: task, data: responseData)
            }, failure: { (task:URLSessionDataTask?, error:Error) in
                self.handleTask(task: task!, error: error)
            })
        default: break
            //
        }
        
        addRequest(request: request)
    }
    
}

extension JXNetworkManager {
    
    /// 缓存request
    ///
    /// - Parameter request: 已经包装好含有URL，param的request
    func addRequest(request:JXBaseRequest) {
        
        guard let task = request.sessionTask
               else {
            return
        }
        let key = requestHashKey(task: task)
        requestCache[key] = request
    }
    
    /// 删除缓存中request
    ///
    /// - Parameter request: 已经包装好含有URL，param的request
    func removeRequest(request:JXBaseRequest) {
        guard let task = request.sessionTask
            else {
                return
        }
        let key = requestHashKey(task: task)
        requestCache.removeValue(forKey: key)
    }
    
    /// 取消request
    ///
    /// - Parameter request: 已经包装好含有URL，param的request
    func cancelRequest(request:JXBaseRequest) {
        guard (request.sessionTask as? URLSessionDataTask) != nil
            else {
                return
        }
        request.sessionTask?.cancel()
        removeRequest(request: request)
    }
    /// 取消所有request
    func cancelRequests() {
        for (_,value) in requestCache {
            let request = value as JXBaseRequest
            cancelRequest(request: request)
        }
    }
    /// 重发request
    ///
    /// - Parameter request: 已经包装好含有URL，param的request
    func resumeRequest(request:JXBaseRequest) {
        buildRequest(request: request)
    }
    /// 重发所有缓冲中的request
    ///
    /// - Parameter request: 已经包装好含有URL，param的request
    func resumeRequests(request:JXBaseRequest) {
        for (_,value) in requestCache {
            let request = value as JXBaseRequest
            
            removeRequest(request: request)
            resumeRequest(request: request)
        }
    }
    
}

extension JXNetworkManager{
    /// 对请求任务hash处理
    ///
    /// - Parameter task: 当前请求task
    /// - Returns: hash后的字符串
    func requestHashKey(task:URLSessionTask) -> String {
        return String(format: "%lu", task.hash)
    }
}

extension JXNetworkManager {
    
    func buildUrl(url:String?) -> String {
        
        guard url != nil else {
            return ""
        }
        
        if url?.hasPrefix("http") == true{
            afmanager.requestSerializer.setValue("AppStore", forHTTPHeaderField: "ua")
            return url!
        }
       
        let ssss = "http://192.168.10.12:8086\(url!)"
        let sssss = ssss.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        return sssss!
    }
}
//MARK: 结果处理
extension JXNetworkManager {
    
    func handleTask(task:URLSessionDataTask, data:Any? = nil, error:Error? = nil) {
        //
        let key = requestHashKey(task: task)
        ///
        
        guard let request = requestCache[key] else {
            return
        }
        let succeed = checkResult(request: request)
        
        if succeed && error == nil{
            request.requestSuccess(responseData: data!)
        } else {
            request.requestFailure(error: error!)
        }
        
        
//        if error == nil {
//            request.requestSuccess(responseData: data!)
//        } else {
//            request.requestFailure(responseData: error!)
//        }
        
        requestCache.removeValue(forKey: key)
    }
    
    func checkResult(request:JXBaseRequest) -> Bool {
        let result = request.statusCodeValidate()
        return result
    }
    
    
    
}

extension JXNetworkManager {
    
}
