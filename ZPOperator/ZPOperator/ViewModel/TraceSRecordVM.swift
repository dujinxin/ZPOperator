//
//  TraceSRecordVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/27.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

class TraceSRecordVM {
    
    var traceSourceProgress = TraceSourceProgress()
    
    
    func loadProgress(goodsId:NSNumber ,completion:@escaping ((_ data:Any?,_ msg:String,_ isSuccess:Bool)->()))  {
        
        JXRequest.request(url: ApiString.addTSRecord.rawValue, param: ["goodsId":goodsId], success: { (data, msg) in
            //
            guard let dict = data as? Dictionary<String,Any> else{
                completion(nil,msg,false)
                return
            }
            self.traceSourceProgress.setValuesForKeys(dict)
            self.traceSourceProgress.traceProcesses = Array<MainSubModel>()
            if let array = dict["traceProcesses"] as? Array<Any>{
                for d in array{
                    let model = MainSubModel()
                    model.setValuesForKeys(d as! [String : Any])
                    self.traceSourceProgress.traceProcesses.append(model)
                }
            }
            
            
            completion(data,msg,true)
        }) { (msg, error) in
            completion(nil,msg,false)
        }
    }
    
    func saveTraceSourceRecord(id:NSNumber, traceTemplateBatchId:NSNumber, traceProcessId:NSNumber, location:String, file:String?, contents:String?, completion:@escaping ((_ data:Any?,_ msg:String, _ isSuccess:Bool)->())) {
        
        JXRequest.request(url: ApiString.saveTSRecord.rawValue, param: ["id":id,"traceTemplateBatch.id":traceTemplateBatchId,"traceProcess.id":traceProcessId,"location":location,"file":file ?? "","contents":contents ?? ""], success: { (data, msg) in
            completion(data,msg,true)
        }) { (msg, error) in
            completion(nil,msg,false)
        }
    }
}
