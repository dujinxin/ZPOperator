
//
//  ApiEnum.swift
//  ShoppingGo
//
//  Created by 杜进新 on 2017/6/9.
//  Copyright © 2017年 杜进新. All rights reserved.
//

import Foundation

enum ApiString : String {

    case userLogin     = "/login"
    case logout        = "/logout"
    case modifiyPwd    = "/user/updatePassword"
    case setting       = "/user/setting"
    case home          = "/index"
    case traceSources  = "/traceBatch/list"
    case addTS         = "/traceBatch/addTraceBatch"
    case saveTS        = "/traceBatch/saveTraceBatch"
    
    case traceSDetail  = "/traceBatch/viewTraceBatchInfo"
    case addTSRecord   = "/traceBatch/addTraceProcessRecord"
    case saveTSRecord  = "/traceBatch/saveTraceProcessRecord"
    case modifyTSRecord = "/traceBatch/editTraceProcessRecord"
    case deleteTSRecord = "/traceBatch/deleteTraceProcessRecord"
    
    case deliverList   = "/batch/list"
    
    case deliverList_chicken = "/do/list"                     //跑步鸡   订单列表
    case deliveringInfo_chicken = "/do/deliverPage"           //跑步鸡   发货信息
    case deliveringCode_chicken = "/do/getSjyCode"            //跑步鸡   获取开始结束编码
    case deliverSubmit_chicken  = "/do/deliver"               //跑步鸡   发货
    
    case deliveredWholeTrace = "/batch/allTrace"
    case deliveredWholeFetchRecord = "/batch/traceProcess"
    case deliveredWholeUpdateRecord = "/batch/saveTrace"
    
    case deliveringBatch = "/batch/traceList" //发货产品相关联的 批次列表       //暂时废弃
    case deliveringManager = "/batch/deliverPage"
    case deliveringCode  = "/batch/getCodeBySpec" //获取开始结束编码
    case deliver       = "/batch/deliver"
    
    case deliverNewBatchInfo = "/batch/new" //新增发货批次，信息
    case deliverNewBatchSave = "/batch/save" //新增发货批次，保存
    case deliverAddress = "/common/getAreaByPid" //三级地址获取
    
    case deliverDirectInfo = "/batch/directPage" //直接发货，信息
    case deliverDirectBatchs = "/batch/getTracesByGoods"//直接发货，获取产品溯源批次
    case deliverDirectCode = "/batch/getStartAndEndCode"//直接发货，获取标签
    case deliverSave = "/batch/directDeliver"//直接发货，发货
    //batch/directDeliver
    
    case codeSearch    = "/code/search"
    
    case uploadGetToken = "/user/upload/getToken"
    
    case identifyInfo  = "/identityAuth" //人脸识别
    
}
