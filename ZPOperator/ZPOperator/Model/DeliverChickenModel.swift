//
//  DeliverChickenModel.swift
//  ZPOperator
//
//  Created by 杜进新 on 2018/1/18.
//  Copyright © 2018年 dujinxin. All rights reserved.
//

import UIKit

/// 发货列表model
class DeliverListChickenModel: BaseModel {
    var Operator = OperatorModel()
    var count : Int = 0
    var orderList = Array<DeliverChickenSubModel>()
}

class DeliverChickenSubModel: BaseModel {
    
    var id : Int = 0
    var orderNum : String? //订单编号
    var counts : Int = 0   //发货数量
    var deliverStatus : Int = 0 //发货状态，0未发货，1已发货
    var title : String?    // 产品名称
    var subtitle : String? //产品名称，副标题
    var images : String?   //产品图片,多张逗号隔开
    var stationName : String?//发货网点
    
    //联系人信息
    var province : String?
    var city : String?
    var county : String?
    var detailAddress : String?
    var receiver : String?
    var receiverPhone : String?
    var remarks : String = ""
    //已发货
    var batchId : Int = 0       //贴码批次
    var traceBatchName : String?//溯源批次
    
    var expressName : String?   //快递名称
    var expressNumber : String? //快递单号
    var deviceNum : String?     //脚环编码
    var codeSn : String?        //标签明码
    var deliverBy : String?     //发货员姓名
    var deliverDate : String?   //发货时间
    
}

class DeliverChickenInfoModel: BaseModel {
    
    var deliverOrderId : Int = 0       //发货订单id
    var counts : Int = 0               //发货数量
    var name : String?
    var operatorModel = OperatorModel()
    var traceBatchArray = Array<MainSubModel>()
    var deviceAssetArray = Array<DeviceNumModel>()
    //标签规格
    var codeSpecArray = Array<DeliverDirectCodeSizeModel>()
}
class DeviceNumModel: BaseModel {
    var deviceNum : String?
    //var id : String?
    var id : Int = 0
}
