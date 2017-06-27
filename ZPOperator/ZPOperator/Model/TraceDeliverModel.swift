//
//  TraceDeliverModel.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/26.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class TraceDeliverModel: NSObject {

    var id : NSNumber?
    var Batch : String?
    var batchStatus : NSNumber?
    var goodsName : String?
    var counts : String?
    var stationName : String?
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
