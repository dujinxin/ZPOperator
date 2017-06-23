//
//  MainVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/21.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

class MainVM{
    
    var orderCount : Int = 0

    var dataArray = [MainSubModel]()
    
    func loadMainData(append:Bool = false,completion:@escaping ((_ data:Any?, _ msg:String?,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.home.rawValue, param: Dictionary(), success: { (data, message) in
            
            guard let dict = data as? Dictionary<String, Any>,
                  let count = dict["orderCount"] as? NSNumber,
                  let array = dict["traceBatchList"] as? NSArray
            else{
                return
            }
            self.orderCount = Int(count)
            
            for i in 0..<array.count{
                let model = MainSubModel()
                model.setValuesForKeys(array[i] as! [String : Any])
                self.dataArray.append(model)
            }
            
            completion(data, message, true)
            
            
            //self.isLogin = true
            
        }) { (message, code) in
            //
            //self.isLogin = false
            completion(nil, message, false)
        }
        
        
        
//        JXNetworkManager.manager.dataRequest(url: ApiString.home.rawValue, param: Dictionary()) { (data, msg, isSuccess) in
//            
//            completion(data,msg,isSuccess)
//            //dataArray = data
//            
//        }
        
        
        
//        for i in 1..<9 {
//            var dict = Dictionary<String, AnyObject>()
//            dict["title"] = "大连暖棚樱桃苹果20170\(i)" as AnyObject
//            dataArray.append(dict)
//        }
//        if append {
//            dataArray.append(["title":"更多溯源批次" as AnyObject])
//        }
//        return dataArray
    }

}
