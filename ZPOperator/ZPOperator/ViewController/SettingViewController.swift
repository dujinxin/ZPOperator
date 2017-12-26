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
                self.navigationController?.popToRootViewController(animated: false)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationLoginStatus), object: false)
            }
        }
    }
    func jxSelectView(jxSelectView: JXSelectView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func jxSelectView(jxSelectView: JXSelectView, contentForRow row: Int, InSection section: Int) -> String {
        return "测试\(row)"
    }
    func jxSelectView(jxSelectView: JXSelectView, heightForRowAt row: Int) -> CGFloat {
        return 44
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameLabel.text = UserManager.manager.userAccound.userName
        self.phoneLabel.text = UserManager.manager.userAccound.mobile
        self.addressLabel.text = UserManager.manager.userAccound.stationName
        
        self.versionLabel.text = kVersion
        
        //logoutButton.layer.cornerRadius = 5
        //logoutButton.backgroundColor = JXOrangeColor
        
        
//        let group = DispatchGroup()
//        let queue = DispatchQueue(label: "label")
//        DispatchQueue.global().async(group: group, qos: .default, flags: .detached) {
//            print("download1 \(Thread.current)")
//        }
//        DispatchQueue.global().async(group: group, qos: .default, flags: .detached) {
//            Thread.sleep(forTimeInterval: 1)
//            print("download2 \(Thread.current)")
//        }
//        group.notify(queue: queue) {
//            print("done \(Thread.current)")
//        }
        
        //1.正品溯源，单从名字上来看，有两点：一是我们对正追求，二是建立溯源过程。如果说追求是目标，是理想的话，那么建立溯源过程则是我们当前要做的事情。正品溯源的成立有其特殊背景和使命，我觉得与其他溯源性质的公司不同，我们更应该有一种使命感和责任感，那么我们所做的就是一个更有意义的事情。虽然过程会很艰难，未来也不明朗，但是我依然很乐观，我相信有梦想谁都了不起，谁都可以走向成功。
        //2.周末听了胡总的分享，感触很多，很多问题：公司的、个人的，工作状态，工作方式等等，感觉每一个环节都在拖后腿。不同于成熟企业，每个企业在其发展过程中都有不同的问题，但是通过类似这种分享会，讲座，我们能更快的发现问题，正视问题，解决问题，并将实现弯道超车。还有我们的产品一定要早日走向市场，由市场来检验我们的成果，根据市场来调整和优化产品，这才是走向成功的捷径！
        
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
            return 10
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            if indexPath.row == 0 {
                
            }else if indexPath.row == 1 {
             
            }else if indexPath.row == 2{
                performSegue(withIdentifier: "AboutUs", sender: nil)
            }else{
                performSegue(withIdentifier: "modifyPassword", sender: nil)
            }
        }
    }
}
