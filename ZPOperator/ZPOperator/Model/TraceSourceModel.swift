//
//  TraceSourceModel.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/24.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

//溯源-详情
class TraceSourceDetailModel: BaseModel {
    var traceBatch : TraceSourceDetailSubModel?
    var traceProcessRecords = Array<TraceSourceRecord>()
}
class TraceSourceDetailSubModel: BaseModel {
    
    var goodsId : Int = -1
    var traceBatchId : Int = -1
    var traceBatchName : String?
    var traceBatchCreateBy : String?
}
//溯源-标签查询
class TraceSourceTagModel: BaseModel {
    
    var code : NSNumber?
    var status : Int = -1 //1:正常,2:未绑定,3:停用,4:废弃
    var goodsName : String?
    var batchCode : String?
    var remarks : String?
    
    var traceRecords = Array<TraceSourceRecord>()
    
}
//溯源-全程
class TraceSourceWholeModel:BaseModel {
    var Operator = TraceDeliverOperatorModel()
    
    var count : Int = 0
    var batch = TraceSourceWholeProduct()
    
    var traceProcessRecords = Array<TraceSourceRecord>()
}

class TraceSourceWholeProduct: BaseModel {
    
    var id : Int = -1
    var goodsName : String?
    var code : String?
    var traceBatch:String?
}

//溯源记录
class TraceSourceRecord: BaseModel {
    
    var id : NSNumber?
    var createBy : String?
    var contents : String?
    var traceProcess : String?
    var traceProcessId : Int = -1//全程
    var location : String?
    var isMine : Bool = false
    var operationTime :String?
    var images : Array<String>?
    
    var canEdit : Bool = false //是否可以编辑,只在全程溯源中有
    
    
}


//MARK: 详情

//获取溯源过程
class TraceSourceProgress: BaseModel {
    var stationLocation :String?
    var traceBatchId : Int = -1
    
    var traceProcesses = Array<MainSubModel>()
}

//获取要修改的溯源信息
class TraceSourceModify: BaseModel {
    var stationLocation :String?
    var traceProcessRecord : TraceSourceRecordModify?
    
    var traceProcesses = Array<MainSubModel>()
}


//要修改的溯源记录
class TraceSourceRecordModify: BaseModel {
    
    var id : Int = -1
    var contents : String?
    var traceProcessId : Int = -1
    var location : String?
    var isMine : Bool = false
    var operationTime :String?
    var images : Array<String>?
    
}

//MARK: 全程
//要修改的溯源记录
class TraceSourceRecordWholeModify: BaseModel {
    
    var Operator = TraceDeliverOperatorModel()
    var traceSourceWholeProduct = TraceSourceWholeProduct()
    var traceProcesses = Array<MainSubModel>()
}




