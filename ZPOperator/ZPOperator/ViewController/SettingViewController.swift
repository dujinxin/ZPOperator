//
//  SettingViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/24.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController ,JXSelectViewDataSource {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!

    var select : JXSelectView?
    var alert : JXAlertView?
    
    
    @IBAction func lougouAction(_ sender: UIButton) {
        
        //alert?.show()
        
        select?.show()
        //select?.show(inView: nil, animate: true)
        
//        let alert = UIAlertController(title: "正品溯源", message: "message", preferredStyle: .actionSheet)
//        for i in 0..<5 {
//            let action = UIAlertAction(title: "\(i)", style: .destructive, handler: { (action) in
//                //
//            })
//            alert.addAction(action)
//            
//        }
//        //alert.addTextField { (textField) in}//.alert
//        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (action) in
//            //
//            alert.dismiss(animated: true, completion: nil)
//        }))
//        self.present(alert, animated: true) { 
//            //
//        }
        
        
    }
    func jxSelectView(_: JXSelectView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func jxSelectView(_: JXSelectView, contentForRow row: Int, InSection section: Int) -> String {
        return "测试\(row)"
    }
    func jxSelectView(_: JXSelectView, heightForRowAt row: Int) -> CGFloat {
        return 44
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let view1 = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 260))
        view1.backgroundColor = UIColor.orange
        
        select = JXSelectView.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.width, height: 300), customView: view1)
        select?.isUseTopBar = true
        select?.dataSource = self
        //select?.customView = view1
        
        
        alert = JXAlertView.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 200), style: .list)
        alert?.actions = ["1","2","3","4","5"]
        alert?.topBarView = view1
        alert?.isUseTopBar = true
        alert?.topBarHeight = 50
        alert?.isSetCancelView = true
        alert?.position = .bottom
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
