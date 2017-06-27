//
//  TraceDeliverVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/26.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

class TraceDeliverVM {
    
    var dataArray = Array<TraceDeliverModel>()
    
    
    /// 发货列表
    ///
    /// - Parameters:
    ///   - batchStatus: 0未发货，1已发货
    ///   - completion: 请求完成回调闭包
    func loadMainData(batchStatus:Int,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.deliverList.rawValue, param: ["batchStatus":batchStatus], success: { (data, message) in
            
            guard let array = data as? Array<Dictionary<String,Any>>
                else{
                    return
            }
            for dict in array{
                let model = TraceDeliverModel()
                model.setValuesForKeys(dict)
                self.dataArray.append(model)
            }
            
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
}
