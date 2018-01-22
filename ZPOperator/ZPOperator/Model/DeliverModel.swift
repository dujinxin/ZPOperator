//
//  TraceDeliverModel.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/26.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit


/// 发货列表model
class DeliverListModel: BaseModel {
    var Operator = OperatorModel()
    var count : Int = 0
    var batches = Array<DeliverSubModel>()
}

class DeliverSubModel: BaseModel {

    var id : NSNumber?
    var Batch : String?
    var batchStatus : NSNumber?
    var goodsName : String?
    var counts : NSNumber?     //改为Int
    var stationName : String?
    var batchCode:String?
    var traceBatch :String?
    
    //联系人信息
    var province : String?
    var city : String?
    var county : String?
    var address : String?
    var contact : String?
    var mobile : String?
    var remarks : String?
    //已发货
    
    var spec : String?         //标签规格
    var startCode : String?    //开始编码
    var endCode : String?      //结束编码
    var totalCount : NSNumber? //
    var operatorName : String? //
    var operateTime : String?  //
    
}

class DeliverManagerModel: BaseModel {
    var startCode : String?
    var endCode : String?
    var counts : Int = 0
    var traceBatches = Array<MainSubModel>()
    var codeSpecList = Array<DeliverDirectCodeSizeModel>()
    
}

class DeliverNewBatchModel: BaseModel {
    var Operator = OperatorModel()
    var goodsList = Array<MainSubModel>()
    //省市区
    var provinceList = Array<MainSubModel>()
    var cityList = Array<MainSubModel>()
    var areaList = Array<MainSubModel>()
    //标签规格
    var codeSpecList = Array<DeliverDirectCodeSizeModel>()
}
class DeliverDirectCodeModel: BaseModel {
    var startCode : String?
    var endCode : String?
}

