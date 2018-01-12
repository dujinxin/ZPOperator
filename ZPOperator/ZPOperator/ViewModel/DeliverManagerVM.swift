//
//  DeliverManagerVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/26.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

class DeliverManagerVM {
    
    var deliverManagerModel = DeliverManagerModel()
    
    func deliveringManagerSubmit(id:Int,traceBatchId:Int,startCode:String,endCode:String,counts:Int,codeSpecId:Int,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        let param : [String:Any]
        if traceBatchId >= 0 {
            param = ["id":id,"traceBatchId":traceBatchId,"startCode":startCode,"endCode":endCode,"counts":counts,"codeSpecId":codeSpecId]
        }else{
            param = ["id":id,"startCode":startCode,"endCode":endCode,"counts":counts,"codeSpecId":codeSpecId]
        }
        
        JXRequest.request(url: ApiString.deliver.rawValue, param: param, success: { (data, message) in
            
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
    
    func loadDeliveringBatch(batchId:Int,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool,_ code:JXNetworkError)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.deliveringManager.rawValue, param: ["batchId":batchId], success: { (data, message) in
            
            guard
                let dict = data as? Dictionary<String,Any>,
                let array = dict["traceBatches"] as? Array<Dictionary<String,Any>>,
                let codeSpecList = dict["codeSpecList"]
                else{
                    completion(data, message, false,JXNetworkError.kResponseUnknow)
                    return
            }
            self.deliverManagerModel.setValuesForKeys(dict)
            self.deliverManagerModel.traceBatches.removeAll()
            self.deliverManagerModel.codeSpecList.removeAll()
            for d in array{
                let model = MainSubModel()
                model.setValuesForKeys(d)
                self.deliverManagerModel.traceBatches.append(model)
            }
            if let codeList = codeSpecList as? Array<Dictionary<String,Any>> {
                for d in codeList{
                    let model = DeliverDirectCodeSizeModel()
                    model.setValuesForKeys(d)
                    self.deliverManagerModel.codeSpecList.append(model)
                }
            }
            completion(data, message, true, JXNetworkError.kResponseSuccess)
            
        }) { (message, code) in
            
            completion(nil, message, false ,code)
        }
    }
    func fetchDeliveryCode(batchId:Int,codeSpecId:Int,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) {
        JXRequest.request(url: ApiString.deliveringCode.rawValue, param: ["batchId":batchId,"codeSpecId":codeSpecId], success: { (data, message) in
            
            guard
                let dict = data as? Dictionary<String,Any>,
                let startCode = dict["startCode"] as? String,
                let endCode = dict["endCode"] as? String
                else{
                    completion(data, message, false)
                    return
            }
            self.deliverManagerModel.startCode = startCode
            self.deliverManagerModel.endCode = endCode
            
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
}
