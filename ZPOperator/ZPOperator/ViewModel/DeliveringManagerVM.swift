//
//  DeliveringManagerVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/26.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

class DeliveringManagerVM {
    
    var deliveringManagerModel = DeliveringManagerModel()
    
    func deliveringManagerSubmit(id:Int,traceBatchId:Int,startCode:String,endCode:String,counts:Int,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        let param : [String:Any]
        if traceBatchId >= 0 {
            param = ["id":id,"traceBatchId":traceBatchId,"startCode":startCode,"endCode":endCode,"counts":counts]
        }else{
            param = ["id":id,"startCode":startCode,"endCode":endCode,"counts":counts]
        }
        
        JXRequest.request(url: ApiString.deliver.rawValue, param: param, success: { (data, message) in
            
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
    
    func loadDeliveringBatch(batchId:Int,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.deliveringManager.rawValue, param: ["batchId":batchId], success: { (data, message) in
            
            guard
                let dict = data as? Dictionary<String,Any>,
                let array = dict["traceBatches"] as? Array<Dictionary<String,Any>>
                else{
                    completion(data, message, false)
                    return
            }
            self.deliveringManagerModel.setValuesForKeys(dict)
            self.deliveringManagerModel.traceBatches.removeAll()
            for d in array{
                let model = MainSubModel()
                model.setValuesForKeys(d)
                self.deliveringManagerModel.traceBatches.append(model)
            }
            
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
}
