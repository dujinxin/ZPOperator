//
//  DeliveredManagerVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/30.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

class DeliveredManagerVM {
    var deliveringBatches = Array<MainSubModel>()
    
    func deliveringManagerSubmit(id:Int,traceBatchId:Int,startCode:String,endCode:String,counts:Int,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.deliverList.rawValue, param: ["id":id,"traceBatchId":traceBatchId,"startCode":startCode,"endCode":endCode,"counts":counts], success: { (data, message) in
            
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
}
