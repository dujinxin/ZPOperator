//
//  MainModel.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/23.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class MainModel: BaseModel {
    
    var orderCount : String?
    
    var traceBatchList : Array<Dictionary<String, Any>>?
    

}

class MainSubModel: BaseModel {
    var name : String?
    var id : Int = -1
}
