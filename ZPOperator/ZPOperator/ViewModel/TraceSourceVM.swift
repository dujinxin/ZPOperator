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
    
    func loadMainData(append:Bool = false,page:Int,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.traceSources.rawValue, param: ["pageNo":page,"pageSize":18], success: { (data, message) in
            
            guard let array = data as? Array<Dictionary<String, Any>>
                else{
                    return
            }
        
            if page == 1 {
                self.dataArray.removeAll()
            }
            
            
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
