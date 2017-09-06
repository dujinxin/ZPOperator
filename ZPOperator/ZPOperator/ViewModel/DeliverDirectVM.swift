//
//  DeliverDirectVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/8/21.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

class DeliverDirectVM {
    
    var deliverDirectModel = DeliverNewBatchModel()
    
    var batchs = Array<MainSubModel>()
    var deliverDirectCodeModel = DeliverDirectCodeModel()
    
    
    
    func fetchDeliverInfo(completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) {
        JXRequest.request(url: ApiString.deliverDirectInfo.rawValue, param: nil, success: { (data, message) in
            guard
                let dict = data as? Dictionary<String,Any>,
                let Operator = dict["operator"] as? Dictionary<String,Any>,
                let goodsList = dict["goodsList"] as? Array<Dictionary<String,Any>>,
                let provinceList = dict["provinceList"] as? Array<Dictionary<String,Any>>
                else{
                    completion(data, message, false)
                    return
            }
            self.deliverDirectModel.Operator.setValuesForKeys(Operator)
            for d in goodsList{
                let model = MainSubModel()
                model.setValuesForKeys(d)
                self.deliverDirectModel.goodsList.append(model)
            }
            for d in provinceList{
                let model = MainSubModel()
                model.setValuesForKeys(d)
                self.deliverDirectModel.provinceList.append(model)
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
                self.deliverDirectModel.cityList.removeAll()
                self.deliverDirectModel.areaList.removeAll()
            }else{
                self.deliverDirectModel.areaList.removeAll()
            }
            for d in array{
                let model = MainSubModel()
                model.setValuesForKeys(d)
                if isCity {
                    self.deliverDirectModel.cityList.append(model)
                }else{
                    self.deliverDirectModel.areaList.append(model)
                }
            }
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
    
    func fetchBatchs(goodsId:Int,completion:@escaping ((_ data:Any?,_ msg:String,_ isSuccess:Bool)->())) {
        JXRequest.request(url: ApiString.deliverDirectBatchs.rawValue, param: ["goodsId":goodsId], success: { (data, msg) in
            guard
                let array = data as? Array<Dictionary<String,Any>>
                else{
                    completion(data, msg, false)
                    return
            }
            self.batchs.removeAll()
            for d in array{
                let model = MainSubModel()
                model.setValuesForKeys(d)
                self.batchs.append(model)
            }
            completion(data, msg, true)
        }) { (msg, code) in
            completion(nil, msg, false)
        }
    }
    func fetchCode(counts:Int,codeType:Int = 1/*1表示自定义2表示通用（以后会用到）*/,completion:@escaping ((_ data:Any?,_ msg:String,_ isSuccess:Bool)->())) {
        JXRequest.request(url: ApiString.deliverDirectCode.rawValue, param: ["counts":counts,"codeType":codeType], success: { (data, msg) in
            guard
                let dict = data as? Dictionary<String,Any>
                else{
                    completion(data, msg, false)
                    return
            }
            self.deliverDirectCodeModel.setValuesForKeys(dict)
            completion(data, msg, true)
        }) { (msg, code) in
            completion(nil, msg, false)
        }
    }
    func deliverSave(goodsId:Int,counts:String,provinceId:Int,cityId:Int,countyId:Int,province:String,city:String,county:String,address:String,remarks:String,startCode:String,endCode:String,traceBatchId:Int,codeType:Int = 1,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        JXRequest.request(url: ApiString.deliverSave.rawValue, param: ["goods.id":goodsId,"counts":counts,"provinceId":provinceId,"cityId":cityId,"countyId":countyId,"province":province,"city":city,"county":county,"address":address,"remarks":remarks,"startCode":startCode,"endCode":endCode,"traceBatchId":traceBatchId,"codeType":codeType], success: { (data, message) in
            
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
}
