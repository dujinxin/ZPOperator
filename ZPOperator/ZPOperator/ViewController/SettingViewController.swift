//
//  SettingViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/24.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class SettingViewController: ZPTableViewController ,JXSelectViewDataSource {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!

    var select : JXSelectView?
    var alert : JXAlertView?
    
    var vm = LoginVM()
    
    
    @IBAction func lougouAction(_ sender: UIButton) {
        
        self.vm.logout { (data, msg, isSuccess) in
            if isSuccess {
                JXNetworkManager.manager.userAccound?.removeAccound()
                JXNetworkManager.manager.userAccound = nil
                //JXNetworkManager.manager.userAccound.sid = nil
                let login = LoginViewController()
                self.navigationController?.present(login, animated: false, completion: nil)
            }
        }
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
        
        self.nameLabel.text = LoginVM.loginVMManager.userModel.userName
        self.phoneLabel.text = LoginVM.loginVMManager.userModel.mobile
        self.addressLabel.text = LoginVM.loginVMManager.userModel.stationName
        self.versionLabel.text = "v1.0.0"
        
        logoutButton.layer.cornerRadius = 5
        logoutButton.backgroundColor = UIColor.originColor

        let view1 = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 260))
        view1.backgroundColor = UIColor.orange
        
        select = JXSelectView.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.width, height: //300), customView: view1)
            300), style:.list)
        select?.isUseTopBar = true
        select?.dataSource = self
        //select?.customView = view1
        
        
        alert = JXAlertView.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 200), style: .list)
        alert?.actions = ["1","2","3","4","5"]
        alert?.topBarView = view1
        alert?.isUseTopBar = true
        //alert?.topBarHeight = 50
        alert?.isSetCancelView = true
        alert?.position = .bottom
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }else if section == 1 {
            return 10
        }else{
            return 64
        }
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    //    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        if indexPath.section == 1 && indexPath.row == 2 {
    //            return 180
    //        }else{
    //            return 44
    //        }
    //    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            if indexPath.row == 0 {
                
            }else if indexPath.row == 1{
                var uploadManager = QiNiuUploadManager()
                //TZImagePickerController
//                uploadManager.qiniuUpload(key: "", data: "", options: nil, completion: {()->() in
//                    //
//                })
            }else{
                performSegue(withIdentifier: "modifyPassword", sender: nil)
            }
        }
    }
}
