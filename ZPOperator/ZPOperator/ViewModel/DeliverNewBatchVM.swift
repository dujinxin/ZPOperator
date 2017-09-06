//
//  DeliverNewBatchVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/8/14.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

class DeliverNewBatchVM {
    
    var deliverNewBatchModel = DeliverNewBatchModel()
   
    func deliverNewBatchInfo(completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        JXRequest.request(url: ApiString.deliverNewBatchInfo.rawValue, param: nil, success: { (data, message) in
            guard
                let dict = data as? Dictionary<String,Any>,
                let Operator = dict["operator"] as? Dictionary<String,Any>,
                let goodsList = dict["goodsList"] as? Array<Dictionary<String,Any>>,
                let provinceList = dict["provinceList"] as? Array<Dictionary<String,Any>>
                else{
                    completion(data, message, false)
                    return
            }
            self.deliverNewBatchModel.Operator.setValuesForKeys(Operator)
            for d in goodsList{
                let model = MainSubModel()
                model.setValuesForKeys(d)
                self.deliverNewBatchModel.goodsList.append(model)
            }
            for d in provinceList{
                let model = MainSubModel()
                model.setValuesForKeys(d)
                self.deliverNewBatchModel.provinceList.append(model)
            }
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
    func deliverAddress(pid:Int,isCity:Bool,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        JXRequest.request(url: ApiString.deliverAddress.rawValue, param: ["pid":pid], success: { (data, message) in
            guard
                let array = data as? Array<Dictionary<String,Any>>
                else{
                    completion(data, message, false)
                    return
            }
            if isCity {
                self.deliverNewBatchModel.cityList.removeAll()
                self.deliverNewBatchModel.areaList.removeAll()
            }else{
                self.deliverNewBatchModel.areaList.removeAll()
            }
            for d in array{
                let model = MainSubModel()
                model.setValuesForKeys(d)
                if isCity {
                    self.deliverNewBatchModel.cityList.append(model)
                }else{
                    self.deliverNewBatchModel.areaList.append(model)
                }
            }
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
    func deliverNewBatchSave(goodsId:Int,counts:String,provinceId:Int,cityId:Int,countyId:Int,province:String,city:String,county:String,address:String,remarks:String,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        JXRequest.request(url: ApiString.deliverNewBatchSave.rawValue, param: ["goods.id":goodsId,"counts":counts,"provinceId":provinceId,"cityId":cityId,"countyId":countyId,"province":province,"city":city,"county":county,"address":address,"remarks":remarks], success: { (data, message) in
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
}
