
//
//  JXRequest.swift
//  ShoppingGo
//
//  Created by 杜进新 on 2017/6/12.
//  Copyright © 2017年 杜进新. All rights reserved.
//

import UIKit

class JXRequest: JXBaseRequest {
    

    var construct : constructingBlock? {
        set{
            self.construct = newValue
        }
        get{
            return nil
        }
    }
    override func customConstruct() ->constructingBlock?  {
        return nil
    }
    
    override func requestSuccess(responseData: Any) {
        super.requestSuccess(responseData: responseData)
        
        let isJson = JSONSerialization.isValidJSONObject(responseData)
        if isJson == true {
            print("responseData is Dictionary or Array")
            if responseData is Dictionary<String,Any> {
                
            }else {
                
            }
        }else {
            print("responseData is Data")
            guard let data = responseData as? Data
                else{
                    handleCallBack(result: nil, message: "数据解析失败", code: JXNetworkError.kResponseUnknow, isSuccess: false)
                    return
            }
            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) {
                handleResponseResult(result: jsonData)
            }else{
                if let responseStr = String.init(data: data, encoding: .utf8) {
                    handleResponseResult(result: responseStr)
                }else{
                    handleCallBack(result: nil, message: "数据解析失败", code: JXNetworkError.kResponseUnknow, isSuccess: false)
                }
            }
        }
    }
    override func requestFailure(error: Error) {
        print("请求失败:\(error)")
        handleResponseResult(result: error)
    }
    func handleResponseResult(result:Any?) {
        
        var msg = "请求失败"
        var netCode : JXNetworkError = .kResponseUnknow
        var data : Any? = nil
        var isSuccess : Bool = false
        
        print("requestParam = \(String(describing: param))")
        print("requestUrl = \(String(describing: requestUrl))")
        
        if result is Dictionary<String, Any> {
            let jsonDict = result as! Dictionary<String, Any>
            print("responseData = \(jsonDict)")
            
            guard let codeNum = jsonDict["code"] as? NSNumber,
                let code = JXNetworkError(rawValue: codeNum.intValue)
                else {
                    msg = "状态码未知"
                    handleCallBack(result: nil, message: msg, code: .kResponseDataError, isSuccess: isSuccess)
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
                self.handleTokenDisabled()
            }else{
                print("请求失败")
                msg = message ?? "请求失败"
            }
            
        }else if result is Array<Any>{
            isSuccess = true
        }else if result is String{
            data = result
            msg = result as! String
            isSuccess = true
        }else if result is Error{
            guard let error = result as? NSError,
                let code = JXNetworkError(rawValue: error.code)
                else {
                    handleCallBack(result: data, message: "Error", code: .kResponseUnknow, isSuccess: isSuccess)
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
        handleCallBack(result: data, message: msg, code: netCode, isSuccess: isSuccess)
    }
    func handleCallBack(result:Any?,message:String,code:JXNetworkError,isSuccess:Bool) {
        guard
            let success = self.success,
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
    /// 处理token失效
    func handleTokenDisabled(){
//        JXNetworkManager.manager.userAccound?.removeAccound()
//        JXNetworkManager.manager.userAccound = nil
        
        if let rootVc = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
            let vc = rootVc.topViewController{
            
            if rootVc.viewControllers.count > 1 {
                vc.navigationController?.popToRootViewController(animated: false)
            }
            print("rootVc = \(rootVc)")
            print("rootVc.viewControllers = \(rootVc.viewControllers)")
            print("vc = \(String(describing: vc))")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationLoginStatus), object: false)
    }
}
