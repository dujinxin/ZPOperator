
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
    
    case deliveredWholeTrace = "/batch/allTrace"
    case deliveredWholeFetchRecord = "/batch/traceProcess"
    case deliveredWholeUpdateRecord = "/batch/saveTrace"
    
    case deliveringBatch = "/batch/traceList" //发货产品相关联的 批次列表 //暂时废弃
    case deliveringManager = "/batch/deliverPage"
    case deliver       = "/batch/deliver"
    case codeSearch    = "/code/search"
    
}
