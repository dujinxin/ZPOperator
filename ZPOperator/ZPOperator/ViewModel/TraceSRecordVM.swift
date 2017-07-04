//
//  TraceSRecordVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/27.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

class TraceSRecordVM {
    
    lazy var traceSourceProgress = TraceSourceProgress()
    lazy var traceSourceModify = TraceSourceModify()//详情 进入
    lazy var traceSourceWholeModify = TraceSourceRecordWholeModify()//全程
    
    
    func loadProgress(goodsId:NSNumber,traceBatchId:NSNumber, completion:@escaping ((_ data:Any?,_ msg:String,_ isSuccess:Bool)->()))  {
        
        JXRequest.request(url: ApiString.addTSRecord.rawValue, param: ["goodsId":goodsId,"traceBatchId":traceBatchId], success: { (data, msg) in
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
    ///新增和修改 -- 详情进入
    func updateTraceSourceRecord(id:NSNumber?, traceTemplateBatchId:NSNumber, traceProcessId:NSNumber, location:String, file:String?, contents:String?, completion:@escaping ((_ data:Any?,_ msg:String, _ isSuccess:Bool)->())) {
        
        let param : Dictionary<String,Any>
        if let id = id {
            param = ["id":id,"traceTemplateBatch.id":traceTemplateBatchId,"traceProcess.id":traceProcessId,"location":location,"file":file ?? "","contents":contents ?? ""]
        }else{
            param = ["traceTemplateBatch.id":traceTemplateBatchId,"traceProcess.id":traceProcessId,"location":location,"file":file ?? "","contents":contents ?? ""]
        }
        
        JXRequest.request(url: ApiString.saveTSRecord.rawValue, param: param, success: { (data, msg) in
            completion(data,msg,true)
        }) { (msg, error) in
            completion(nil,msg,false)
        }
    }
    //删除     --- 详情进入
    func deleteTraceSourceRecord(id:NSNumber,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.deleteTSRecord.rawValue, param: ["id":id], success: { (data, message) in
            
            completion(data, message, true)
            
        }) { (message, code) in
  
            completion(nil, message, false)
        }
        
    }
    
    //获取要修改的信息   --- 详情进入
    func fetchTraceSourceRecord(id:NSNumber,goodsId:NSNumber,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.modifyTSRecord.rawValue, param: ["id":id,"goodsId":goodsId], success: { (data, msg) in
            
            
            guard let dict = data as? Dictionary<String,Any> else{
                completion(nil,msg,false)
                return
            }
            self.traceSourceModify.setValuesForKeys(dict)
            self.traceSourceModify.traceProcesses = Array<MainSubModel>()
            self.traceSourceModify.traceProcessRecord = TraceSourceRecordModify()
            if let array = dict["traceProcesses"] as? Array<Any>{
                for d in array{
                    let model = MainSubModel()
                    model.setValuesForKeys(d as! [String : Any])
                    self.traceSourceProgress.traceProcesses.append(model)
                }
            }
            if let subDict = dict["traceProcessRecord"] as? Dictionary<String, Any> {
            
                self.traceSourceModify.traceProcessRecord?.setValuesForKeys(subDict)
            }
            
            completion(data, msg, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
        
    }
//MARK -- 全程溯源
    
    
    //获取要修改的信息
    func fetchTraceSourceWholeRecord(batchId:NSNumber,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.deliveredWholeFetchRecord.rawValue, param: ["batchId":batchId], success: { (data, msg) in
            
            
            guard let dict = data as? Dictionary<String,Any>,
                  let array = dict["traceProcesses"] as? Array<Any>,
                  let Operator = dict["operator"] as? Dictionary<String, Any>,
                  let batch = dict["batch"] as? Dictionary<String, Any>
            else{
                completion(nil,msg,false)
                return
            }
            self.traceSourceWholeModify.Operator.setValuesForKeys(Operator)
            self.traceSourceWholeModify.traceSourceWholeProduct.setValuesForKeys(batch)
            self.traceSourceWholeModify.traceProcesses = Array<MainSubModel>()
    
            for d in array{
                let model = MainSubModel()
                model.setValuesForKeys(d as! [String : Any])
                self.traceSourceWholeModify.traceProcesses.append(model)
            }
            
            completion(data, msg, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
        
    }
    
    ///新增和修改 -- 全程进入
    func updateTraceSourceWholeRecord(id:NSNumber?, traceTemplateBatchId:NSNumber, traceProcessId:NSNumber, location:String, file:String?, contents:String?, completion:@escaping ((_ data:Any?,_ msg:String, _ isSuccess:Bool)->())) {
        
        let param : Dictionary<String,Any>
        if let id = id {
            param = ["id":id,"batch.id":traceTemplateBatchId,"traceProcess.id":traceProcessId,"location":location,"file":file ?? "","contents":contents ?? ""]
        }else{
            param = ["batch.id":traceTemplateBatchId,"traceProcess.id":traceProcessId,"location":location,"file":file ?? "","contents":contents ?? ""]
        }
        
        JXRequest.request(url: ApiString.deliveredWholeUpdateRecord.rawValue, param: param, success: { (data, msg) in
            completion(data,msg,true)
        }) { (msg, error) in
            completion(nil,msg,false)
        }
    }
}
