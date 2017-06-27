//
//  TraceSourceTagVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/26.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

class TraceSourceTagVM {
    
    var traceSourceTag = TraceSourceTag()
    
    func loadMainData(code:String,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.codeSearch.rawValue, param: ["code":code,"pageNo":1,"pageSize":20], success: { (data, message) in
            
            guard let dict = data as? Dictionary<String, Any>
                else{
                    return
            }
            self.traceSourceTag = TraceSourceTag()
            self.traceSourceTag.setValuesForKeys(dict)
            
            //let traceBatch = dict["traceBatch"] as? Dictionary<String,Any>
            let traceRecords = dict["traceRecords"] as? Array<Dictionary<String,Any>> ?? []
            
            self.traceSourceTag.traceRecords.removeAll()
            
            for d in traceRecords{
                let model = TraceSourceRecord()
                model.setValuesForKeys(d)
                model.setValue(d["Operator"], forKey: "Operator")
                self.traceSourceTag.traceRecords.append(model)
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
