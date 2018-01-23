//
//  MainReusableView.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/20.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class MainReusableView: UICollectionReusableView {

    
    @IBOutlet weak var mainActionButton: UIButton!
    
    ///多个xib共用一个父类时，不是公共的view一定要设置成可选的
    @IBOutlet weak var moreActionButton: UIButton?
    
    @IBAction func mainAction(_ sender: UIButton) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
