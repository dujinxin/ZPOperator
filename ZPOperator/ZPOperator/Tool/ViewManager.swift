//
//  ViewManager.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/29.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation

class ViewManager {
    
    class func showNotice(notice:String) {
        let noticeView = JXNoticeView.init(text: notice)
        noticeView.show()
    }
}
