//
//  JXRequest.swift
//  ShoppingGo
//
//  Created by 杜进新 on 2017/6/12.
//  Copyright © 2017年 杜进新. All rights reserved.
//

import UIKit

class JXRequest: JXBaseRequest {
    
//    override init(with url: String, param: [String : String], success: @escaping successCompletion, failure: @escaping failureCompletion) {
//        super.init(with: url, param: param, success: success, failure: failure)
//    }
    
    override func requestSuccess(responseData: Any) {
        super.requestSuccess(responseData: responseData)
        guard let success = self.success else {
            return
        }
        success(responseData,"123","34")
        print(responseData)
    }
    override func requestFailure(responseData: Any) {
        super.requestFailure(responseData: responseData)
        print(responseData)
    }
    
    

}
