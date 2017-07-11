//
//  TraceSourceDetailVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/24.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation
import AFNetworking

class TraceSourceDetailVM {

    ///溯源详情模型
    var traceSourceDetail = TraceSourceDetailModel()
    ///溯源全程模型
    var traceSourceWhole = TraceSourceWholeModel()
    
    ///标签查询结果模型
    var traceSourceTag = TraceSourceTagModel()
    //详情、全程溯源与查询结果的公共数组
    var dataArray = [TraceSourceRecord]()
    
    /// 溯源详情
    ///
    /// - Parameters:
    ///   - traceBatchId: 溯源批次id
    ///   - completion: 闭包
    func traceSourceDetail(page:Int,traceBatchId:NSNumber,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.traceSDetail.rawValue, param: ["traceBatchId":traceBatchId,"pageNo":page,"pageSize":5], success: { (data, message) in
            
            
            guard let dict = data as? Dictionary<String, Any>,
                  let traceBatch = dict["traceBatch"] as? Dictionary<String,Any>
                else{
                    return
            }
            self.traceSourceDetail.traceBatch = TraceSourceDetailSubModel()
            self.traceSourceDetail.traceBatch?.setValuesForKeys(traceBatch)
            
            let traceProcessRecords = dict["traceProcessRecords"] as? Array<Dictionary<String,Any>> ?? []
            
            if page == 1 {
                self.dataArray.removeAll()
            }
            
            for d in traceProcessRecords{
                let model = TraceSourceRecord()
                model.setValuesForKeys(d)
                self.dataArray.append(model)
            }
            
            completion(data, message, true)
            
            
            //self.isLogin = true
            
        }) { (message, code) in
            //
            //self.isLogin = false
            completion(nil, message, false)
        }
        
    }
    
    /// 标签查询
    ///
    /// - Parameters:
    ///   - code: 查询码
    ///   - completion: 结果闭包
    func traceSourceTag(page:Int,code:String,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        //["code":code,"pageNo":page,"pageSize":5]
        JXRequest.request(url: ApiString.codeSearch.rawValue, param: ["code":code], success: { (data, message) in
            
            guard let dict = data as? Dictionary<String, Any>
                else{
                    return
            }
            self.traceSourceTag.setValuesForKeys(dict)
            
            //let traceBatch = dict["traceBatch"] as? Dictionary<String,Any>
            let traceRecords = dict["traceRecords"] as? Array<Dictionary<String,Any>> ?? []
            
            if page == 1{
                self.dataArray.removeAll()
            }
            
            
            for d in traceRecords{
                let model = TraceSourceRecord()
                model.setValuesForKeys(d)
                self.dataArray.append(model)
            }
            
            completion(data, message, true)
            
            
            //self.isLogin = true
            
        }) { (message, code) in
            //
            //self.isLogin = false
            completion(nil, message, false)
        }
        
    }
    func traceSourceWholeTrace(page:Int,batchId:NSNumber,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.deliveredWholeTrace.rawValue, param: ["batchId":batchId,"pageNo":page,"pageSize":5], success: { (data, message) in
            
            
            guard let dict = data as? Dictionary<String, Any>,
                let Operator = dict["operator"] as? Dictionary<String,Any>,
                let batch = dict["batch"] as? Dictionary<String,Any>
                else{
                    return
            }
            self.traceSourceWhole.batch = TraceSourceWholeProduct()
            self.traceSourceWhole.Operator = TraceDeliverOperatorModel()
            self.traceSourceWhole.batch.setValuesForKeys(batch)
            self.traceSourceWhole.Operator.setValuesForKeys(Operator)
            self.traceSourceWhole.count = dict["count"] as? Int ?? 0
            
            let traceProcessRecords = dict["traceProcessRecords"] as? Array<Dictionary<String,Any>> ?? []
            
            if page == 1 {
                self.dataArray.removeAll()
            }
            
            for d in traceProcessRecords{
                let model = TraceSourceRecord()
                model.setValuesForKeys(d)
                self.dataArray.append(model)
            }
            
            completion(data, message, true)
            
            
            //self.isLogin = true
            
        }) { (message, code) in
            //
            //self.isLogin = false
            completion(nil, message, false)
        }
        
    }
    func submitTS2222(goodId:String,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
//        let request = JXRequest.init(tag: 0, url: ApiString.saveTS.rawValue, param: ["goods.id":goodId], success: { (responseData, msg) in
//            //
//        }) { (msg, errorCode) in
//            //
//        }
//        request.requestUrl = ApiString.saveTS.rawValue
//        request.param = ["goods.id":goodId]
//        request.success = { (data, message) in
//            completion(data, message, true)
//        }
//        request.failure = { (message, code) in
//            completion(nil, message, false)
//        }
//        request.construct = {
//            return { (formData) in
//                let str = NSHomeDirectory() + "/Documents/userImage.jpg"
//                let url = URL.init(fileURLWithPath: str)
//                let data = try? Data.init(contentsOf: url)
//                formData.appendPart(withFileData: data!, name: "image", fileName: "userImage.jpg", mimeType: "image/jpeg")
//            }
//        }
//        request.startRequest()
        
        
        JXRequest.request(url: ApiString.saveTS.rawValue, param: ["goods.id":goodId], success: { (data, message) in
            
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
    
}
