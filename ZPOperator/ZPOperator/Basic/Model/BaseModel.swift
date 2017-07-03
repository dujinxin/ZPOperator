//
//  BaseModel.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/29.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class BaseModel: NSObject {

    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        print("undefinedKey:\(key) Value:\(String(describing: value))")
    }
}
