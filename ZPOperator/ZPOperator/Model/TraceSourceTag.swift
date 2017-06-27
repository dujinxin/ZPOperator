//
//  TraceSourceTag.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/26.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class TraceSourceTag: NSObject {

    var code : NSNumber?
    var status : NSNumber?
    var goodsName : String?
    var batchCode : String?
    var remarks : String?
    var traceRecords = Array<TraceSourceTagRecord>()
    
}

//溯源标签记录
class TraceSourceTagRecord: NSObject {
    
    var Operator : String?
    var contents : String?
    var traceProcess : String?
    var location : String?
    var operationTime :String?
    var file : String?
    
}

