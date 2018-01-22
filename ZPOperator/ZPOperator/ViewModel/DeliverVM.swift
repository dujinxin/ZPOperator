//
//  DeliverVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/26.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

class DeliverListVM {
    
    var deliverListModel = DeliverListModel()
    
    
    /// 发货列表
    ///
    /// - Parameters:
    ///   - batchStatus: 0未发货，1已发货
    ///   - completion: 请求完成回调闭包
    func deliverList(page: Int,batchStatus:Int,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.deliverList.rawValue, param: ["batchStatus":batchStatus,"pageNo":page,"pageSize":20], success: { (data, message) in
            
            guard let dict = data as? Dictionary<String,Any>,
                  let Operator = dict["operator"] as? Dictionary<String,Any>,
                  let array = dict["batches"] as? Array<Dictionary<String,Any>>
                else{
                    return
            }
            self.deliverListModel.Operator.setValuesForKeys(Operator)
            self.deliverListModel.count = dict["count"] as! Int
            if page == 1 {
                self.deliverListModel.batches.removeAll()
            }
            for d in array{
                let model = DeliverSubModel()
                model.setValuesForKeys(d)
                self.deliverListModel.batches.append(model)
            }
            
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
}
