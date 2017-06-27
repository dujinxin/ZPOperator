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

    var traceSource : TraceSource?
    
    var dataArray = [TraceSourceRecord]()
    
    func loadMainData(traceBatchId:NSNumber,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.traceSDetail.rawValue, param: ["traceBatchId":traceBatchId,"pageNo":1,"pageSize":20], success: { (data, message) in
            
            
            guard let dict = data as? Dictionary<String, Any>,
                  let traceBatch = dict["traceBatch"] as? Dictionary<String,Any>
                else{
                    return
            }
            self.traceSource = TraceSource()
            self.traceSource?.setValuesForKeys(traceBatch)
            
            let traceProcessRecords = dict["traceProcessRecords"] as? Array<Dictionary<String,Any>> ?? []
            
            self.dataArray.removeAll()
            
            for i in 0..<traceProcessRecords.count{
                let model = TraceSourceRecord()
                model.setValuesForKeys(traceProcessRecords[i])
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
        
        let request = JXRequest.init()
        request.requestUrl = ApiString.saveTS.rawValue
        request.param = ["goods.id":goodId]
        request.success = { (data, message) in
            completion(data, message, true)
        }
        request.failure = { (message, code) in
            completion(nil, message, false)
        }
        request.construct = {
            return { (formData) in
                let str = NSHomeDirectory() + "/Documents/userImage.jpg"
                let url = URL.init(fileURLWithPath: str)
                let data = try? Data.init(contentsOf: url)
                formData.appendPart(withFileData: data!, name: "image", fileName: "userImage.jpg", mimeType: "image/jpeg")
            }
        }
        request.startRequest()
        
        
        JXRequest.request(url: ApiString.saveTS.rawValue, param: ["goods.id":goodId], success: { (data, message) in
            
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
}
