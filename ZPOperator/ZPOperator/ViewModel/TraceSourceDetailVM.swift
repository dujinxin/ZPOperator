//
//  TraceSourceDetailVM.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/24.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

class TraceSourceDetailVM {

    var traceSource : TraceSource?
    
    var dataArray = [TraceSourceRecord]()
    
    func loadMainData(traceBatchId:String,completion:@escaping ((_ data:Any?, _ msg:String,_ isSuccess:Bool)->())) -> Void{
        
        
        JXRequest.request(url: ApiString.traceSources.rawValue, param: ["traceBatchId":traceBatchId,"pageNo":1,"pageSize":20], success: { (data, message) in
            
            
           let data = [
                "traceBatch": [
                    "goodsId": 10,
                    "traceBatchId": 6,
                    "traceBatchName": "20170605001大鸭梨",
                    "traceBatchCreateBy": "王大锤444"
                ],
                "traceProcessRecords": [
                    [
                    "createBy": "王大锤444",
                    "images": [
                                "http://img.izheng.org/ceccm/20170606/1496717365656"
                              ],
                    "contents": "大大大大大大大大大大大大大大大", "traceProcess": "出库",
                    "location": "山东青岛",
                    "id": 7,
                    "isMine": true,
                    "operationTime": "2017-06-06 10:52"
                    ],
                    [
                        "createBy": "王大锤444",
                        "images": [
                            "http://img.izheng.org/ceccm/20170606/1496717365656"
                        ],
                        "contents": "大大大大大大大大大大大大大大大", "traceProcess": "出库",
                        "location": "山东青岛",
                        "id": 7,
                        "isMine": true,
                        "operationTime": "2017-06-06 10:52"
                    ],
                    [
                        "createBy": "王大锤444",
                        "images": [
                            "http://img.izheng.org/ceccm/20170606/1496717365656"
                        ],
                        "contents": "大大大大大大大大大大大大大大大", "traceProcess": "出库",
                        "location": "山东青岛",
                        "id": 7,
                        "isMine": true,
                        "operationTime": "2017-06-06 10:52"
                    ],
                    [
                        "createBy": "王大锤444",
                        "images": [
                            "http://img.izheng.org/ceccm/20170606/1496717365656"
                        ],
                        "contents": "大大大大大大大大大大大大大大大", "traceProcess": "出库",
                        "location": "山东青岛",
                        "id": 7,
                        "isMine": true,
                        "operationTime": "2017-06-06 10:52"
                    ],
                    [
                        "createBy": "王大锤444",
                        "images": [
                            "http://img.izheng.org/ceccm/20170606/1496717365656"
                        ],
                        "contents": "大大大大大大大大大大大大大大大", "traceProcess": "出库",
                        "location": "山东青岛",
                        "id": 7,
                        "isMine": true,
                        "operationTime": "2017-06-06 10:52"
                    ],
                ]
            ] as [String : Any]
            
            guard let dict = data as? Dictionary<String, Any>,
                  let traceBatch = dict["traceBatch"] as? Dictionary<String,Any>
                else{
                    return
            }
            self.traceSource = TraceSource()
            self.traceSource?.setValuesForKeys(traceBatch)
            
            let traceProcessRecords = dict["traceProcessRecords"] as? Array<Dictionary<String,Any>> ?? []
            
            self.dataArray.removeAll()
            
            for i in 0..<traceProcessRecords.count{
                let model = TraceSourceRecord()
                model.setValuesForKeys(traceProcessRecords[i])
                self.dataArray.append(model)
            }
            
            completion(data, message, true)
            
            
            //self.isLogin = true
            
        }) { (message, code) in
            //
            //self.isLogin = false
            completion(nil, message, false)
        }
        
    }
}
