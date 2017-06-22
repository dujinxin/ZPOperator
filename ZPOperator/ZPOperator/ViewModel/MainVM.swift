//
//  MainVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/21.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class MainVM: NSObject {
    
    var dataArray = [[String:AnyObject]]()
    
    func loadMainData(append:Bool = false) -> Array<Dictionary<String, AnyObject>> {
        
        for i in 1..<9 {
            var dict = Dictionary<String, AnyObject>()
            dict["title"] = "大连暖棚樱桃苹果20170\(i)" as AnyObject
            dataArray.append(dict)
        }
        if append {
            dataArray.append(["title":"更多溯源批次" as AnyObject])
        }
        return dataArray
    }

}
