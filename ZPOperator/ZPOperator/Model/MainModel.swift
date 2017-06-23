//
//  MainModel.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/23.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class MainModel: NSObject {
    
    var orderCount : String?
    
    var traceBatchList : Array<Dictionary<String, Any>>?
    

}

class MainSubModel: NSObject {
    var name : String?
    var id : NSNumber?
}
