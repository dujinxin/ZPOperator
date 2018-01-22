//
//  DeliverVM_Chicken.swift
//  ZPOperator
//
//  Created by 杜进新 on 2018/1/19.
//  Copyright © 2018年 dujinxin. All rights reserved.
//

import Foundation

class DeliverListVM_Chicken {
    
    var deliverListModel = DeliverListChickenModel()
    
    /// 订单列表-跑步鸡
    ///
    /// - Parameters:
    ///   - deliverStatus: 0未发货，1已发货
    ///   - completion: 请求完成回调闭包
    func deliverList(page: Int,deliverStatus:Int,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.deliverList_chicken.rawValue, param: ["deliverStatus":deliverStatus], success: { (data, message) in
            
            guard let dict = data as? Dictionary<String,Any>,
                let Operator = dict["operator"] as? Dictionary<String,Any>,
                let array = dict["orderList"] as? Array<Dictionary<String,Any>>
                else{
                    return
            }
            self.deliverListModel.Operator.setValuesForKeys(Operator)
            self.deliverListModel.count = dict["count"] as! Int
            if page == 1 {
                self.deliverListModel.orderList.removeAll()
            }
            for d in array{
                let model = DeliverChickenSubModel()
                model.setValuesForKeys(d)
                
                self.deliverListModel.orderList.append(model)
            }
            
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
}
class DeliverVM_Chicken {
    
    var deliverInfoModel = DeliverChickenInfoModel()
    
    var codeSn : Int = 0 //标签明码
    
    
    func deliveringInfo(deliverOrderId:Int,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool,_ code:JXNetworkError)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.deliveringInfo_chicken.rawValue, param: ["deliverOrderId":deliverOrderId], success: { (data, message) in
            
            guard
                let dict = data as? Dictionary<String,Any>,
                let array = dict["traceBatches"] as? Array<Dictionary<String,Any>>,
                let codeSpecList = dict["codeSpecList"],
                let deviceAssetList = dict["deviceAssetList"],
                let Operator = dict["operator"] as? Dictionary<String,Any>
                else{
                    completion(data, message, false,JXNetworkError.kResponseUnknow)
                    return
            }
            //self.deliverInfoModel.setValuesForKeys(dict)
            self.deliverInfoModel.operatorModel.setValuesForKeys(Operator)
            self.deliverInfoModel.traceBatchArray.removeAll()
            self.deliverInfoModel.codeSpecArray.removeAll()
            for d in array{
                let model = MainSubModel()
                model.setValuesForKeys(d)
                self.deliverInfoModel.traceBatchArray.append(model)
            }
            if let codeList = codeSpecList as? Array<Dictionary<String,Any>> {
                for d in codeList{
                    let model = DeliverDirectCodeSizeModel()
                    model.setValuesForKeys(d)
                    self.deliverInfoModel.codeSpecArray.append(model)
                }
            }
            if let deviceList = deviceAssetList as? Array<Dictionary<String,Any>> {
                for d in deviceList{
                    let model = DeviceNumModel()
                    model.setValuesForKeys(d)
                    //self.deliverInfoModel.deviceAssetList.
                    self.deliverInfoModel.deviceAssetArray.append(model)
                }
            }
            completion(data, message, true, JXNetworkError.kResponseSuccess)
            
        }) { (message, code) in
            
            completion(nil, message, false ,code)
        }
    }
    
    func deliveryCode(codeSpecId:Int,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) {
        JXRequest.request(url: ApiString.deliveringCode_chicken.rawValue, param: ["codeSpecId":codeSpecId], success: { (data, message) in
            
            guard
                let dict = data as? Dictionary<String,Any>,
                let code = dict["codeSn"] as? String,
                let codeNum = Int(code)
                
                else{
                    completion(data, message, false)
                    return
            }
            self.codeSn = codeNum
            
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
    func deliveringSubmit(deliverOrderId:Int,traceBatchId:Int,deviceNum:String,codeSpecId:Int,codeSn:String,expressName:String,expressNumber:String,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        let param = ["deliverOrderId":deliverOrderId,"traceBatchId":traceBatchId,"deviceNum":deviceNum,"codeSpecId":codeSpecId,"codeSn":codeSn,"expressName":expressName,"expressNumber":expressNumber] as [String : Any]
        
        JXRequest.request(url: ApiString.deliverSubmit_chicken.rawValue, param: param, success: { (data, message) in
            
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
}
