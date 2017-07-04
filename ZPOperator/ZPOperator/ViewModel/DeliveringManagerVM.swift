//
//  DeliveringManagerVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/26.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

class DeliveringManagerVM {
    
    var deliveringBatches = Array<MainSubModel>()
    
    func deliveringManagerSubmit(id:Int,traceBatchId:Int,startCode:String,endCode:String,counts:Int,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.deliver.rawValue, param: ["id":id,"traceBatchId":traceBatchId,"startCode":startCode,"endCode":endCode,"counts":counts], success: { (data, message) in
            
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
    
    func loadDeliveringBatch(batchId:Int,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.deliveringBatch.rawValue, param: ["batchId":batchId], success: { (data, message) in
            
            guard let array = data as? Array<Dictionary<String,Any>>
                else{
                    return
            }
            self.deliveringBatches.removeAll()
            for d in array{
                let model = MainSubModel()
                model.setValuesForKeys(d)
                self.deliveringBatches.append(model)
            }
            
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
}
