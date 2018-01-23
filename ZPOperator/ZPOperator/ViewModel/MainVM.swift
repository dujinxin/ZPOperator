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
    var dataArray_new = [MainModel_New]()
    
    
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
            
            self.dataArray.removeAll()
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
    
    func loadNewMainData(append:Bool = false,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.home.rawValue, param: Dictionary(), success: { (data, message) in
            
            guard let array = data as? Array<Dictionary<String, Any>>
                else{
                    return
            }
            self.dataArray_new.removeAll()
            for i in 0..<array.count{
                let model = MainModel_New()
                model.setValuesForKeys(array[i])
                self.dataArray_new.append(model)
            }
            
            completion(data, message, true)
            
        }) { (message, code) in
            completion(nil, message, false)
        }
    }

}
