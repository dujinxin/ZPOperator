//
//  TraceSAddVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/23.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

class TraceSAddVM {
    
    var station : String?
    
    var dataArray = [MainSubModel]()
    
    func loadMainData(append:Bool = false,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.addTS.rawValue, param: Dictionary(), success: { (data, message) in
            
            guard let dict = data as? Dictionary<String, Any>,
                let station = dict["station"] as? String,
                let array = dict["goodses"] as? NSArray
                else{
                    return
            }
            self.station = station
            
            for i in 0..<array.count{
                let model = MainSubModel()
                model.setValuesForKeys(array[i] as! [String : Any])
                self.dataArray.append(model)
            }
            
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
    func submitTS(goodId:NSNumber,goodName:String,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.saveTS.rawValue, param: ["goods.id":goodId,"good.name":goodName], success: { (data, message) in
            
            completion(data, message, true)
            
        }) { (message, code) in
            
            completion(nil, message, false)
        }
    }
    
}
