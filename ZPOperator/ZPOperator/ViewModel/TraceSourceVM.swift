//
//  TraceSourceVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/23.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

class TraceSourceVM {

    var dataArray = [MainSubModel]()
    
    func loadMainData(append:Bool = false,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.traceSources.rawValue, param: ["pageNo":1,"pageSize":20], success: { (data, message) in
            
            guard let array = data as? Array<Dictionary<String, Any>>
                else{
                    return
            }
        
            self.dataArray.removeAll()
            
            for i in 0..<array.count{
                let model = MainSubModel()
                model.setValuesForKeys(array[i])
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
}
