//
//  TraceDeliverModel.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/26.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit


class TraceDeliverModel: BaseModel {
    var Operator = TraceDeliverOperatorModel()
    
    var count : Int = 0
    
    var batches = Array<TraceDeliverSubModel>()
}

class TraceDeliverOperatorModel: BaseModel {
    var name : String?
    var station : String?
    
    var stationLocation : String? //全程溯源中独有
}

class TraceDeliverSubModel: BaseModel {

    var id : NSNumber?
    var Batch : String?
    var batchStatus : NSNumber?
    var goodsName : String?
    var counts : String?
    var stationName : String?
    var batchCode:String?
    //联系人信息
    var province : String?
    var city : String?
    var county : String?
    var address : String?
    var contact : String?
    var mobile : String?
    var remarks : String?
    //已发货
    var startCode : String?
    var endCode : String?
    var totalCount : NSNumber?
    var operatorName : String?
    var operateTime : NSNumber?
    
    
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        print("undefinedKey:\(key) Value:\(String(describing: value))")
    }
}
