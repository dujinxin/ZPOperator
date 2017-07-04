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
    
    func loadMainData(append:Bool = false,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.home.rawValue, param: Dictionary(), success: { (data, message) in
            
            guard let dict = data as? Dictionary<String, Any>,
                  let count = dict["orderCount"] as? NSNumber,
                  let array = dict["traceBatchList"] as? NSArray
            else{
                return
            }
            self.orderCount = Int(count)
            
            let endIndex : Int
            
            if append == true && array.count > 5{
                endIndex = 5
            }else{
                endIndex = array.count
            }
            
            
            for i in 0..<endIndex{
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
    }

}
