//
//  TraceSourceModel.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/24.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class TraceSourceModel: NSObject {
    var traceBatch : TraceSource?
    var traceProcessRecords : Array<TraceSourceRecord>?
}

//溯源记录
class TraceSourceRecord: NSObject {
    
    var id : NSNumber?
    var createBy : String?
    var contents : String?
    var traceProcess : String?
    var location : String?
    var isMine : Bool = false
    var operationTime :String?
    var images : Array<Any>?
    
}
//
class TraceSource: NSObject {
    
    var goodsId : NSNumber?
    var traceBatchId : NSNumber?
    var traceBatchName : String?
    var traceBatchCreateBy : String?
}
